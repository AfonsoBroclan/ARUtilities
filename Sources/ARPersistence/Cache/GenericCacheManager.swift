//
//  GenericCacheManager.swift
//  ARUtilities
//
//  Created by Afonso Rosa on 15/12/2025.
//

import Foundation

/// Constants for GenericCacheManager
public enum GenericCacheManagerConstants {
  /// Default Time-To-Live (TTL) for cache entries: 24 hours
  public static let defaultTTL: TimeInterval = 24 * 60 * 60
}

/// Errors that can occur in GenericCacheManager
public enum GenericCacheManagerError: Error {
  case keyValueCountMismatch
}

/// An actor-based generic cache manager that stores key-value pairs with optional TTL expiration.
public actor GenericCacheManager<Key: Hashable, Value: Sendable> {

  /// Main cache entry structure
  private let cache = NSCache<WrappedKey, Entry>()
  /// Default Time-To-Live (TTL) for cache entries
  private var ttl: TimeInterval

  /// Initializes the cache manager with an optional TTL (defaults to 24 hours)
  public init(ttl: TimeInterval = GenericCacheManagerConstants.defaultTTL) {
    self.ttl = ttl
  }

  /// Changes the default TTL for new cache entries.
  public func changeTTL(to ttl: TimeInterval) async {
    self.ttl = ttl
  }

  /// Inserts a value into the cache with the specified key.
  public func insert(_ value: Value, forKey key: Key) async {
    let entry = Entry(value: value, expirationDate: Date().addingTimeInterval(self.ttl))
    self.cache.setObject(entry, forKey: WrappedKey(key))
  }

  /// Inserts multiple values into the cache with the specified keys. The number of items and their order must match the number of keys and their order.
  public func insert(items: [Value], forKeys keys: [Key]) async throws {

    guard items.count == keys.count else {
      throw GenericCacheManagerError.keyValueCountMismatch
    }

    for (key, value) in zip(keys, items) {
      await insert(value, forKey: key)
    }
  }

  /// Retrieves a value from the cache for the specified key.
  public func value(forKey key: Key) async -> Value? {

    guard let entry = cache.object(forKey: WrappedKey(key)) else { return nil }

    if let expirationDate = entry.expirationDate, expirationDate < Date() {
      // Remove expired entry
      self.cache.removeObject(forKey: WrappedKey(key))
      return nil
    }

    return entry.value
  }

  /// Removes a value from the cache for the specified key.
  public func removeValue(forKey key: Key) async {

    self.cache.removeObject(forKey: WrappedKey(key))
  }

  /// Clears all entries from the cache.
  public func clear() async {

    self.cache.removeAllObjects()
  }

  /// Sets the maximum number of objects the cache should hold.
  /// When the limit is exceeded, NSCache may evict objects automatically.
  /// The system determines eviction policy based on memory pressure.
  public func setCountLimit(_ limit: Int) async {
    self.cache.countLimit = limit
  }
}

// Helper classes for NSCache
private extension GenericCacheManager {

  /// Wrapper for keys to be used in NSCache
  class WrappedKey: NSObject {

    let key: Key

    init(_ key: Key) {

      self.key = key
    }

    override var hash: Int { return key.hashValue }

    override func isEqual(_ object: Any?) -> Bool {

      guard let other = object as? WrappedKey else { return false }

      return other.key == key
    }
  }

  /// Cache entry containing the value and its optional expiration date
  final class Entry {

    let value: Value
    let expirationDate: Date?

    init(value: Value, expirationDate: Date?) {

      self.value = value
      self.expirationDate = expirationDate
    }
  }
}
