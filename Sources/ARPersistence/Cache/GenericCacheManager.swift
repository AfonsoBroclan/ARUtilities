//
//  GenericCacheManager.swift
//  ARUtilities
//
//  Created by Afonso Rosa on 15/12/2025.
//

import Foundation

private enum Constants {
  static let defaultTTL: TimeInterval = 24 * 60 * 60 // 24 hours
}

/// An actor-based generic cache manager that stores key-value pairs with optional TTL expiration.
actor GenericCacheManager<Key: Hashable, Value> {

  /// Main cache entry structure
  private let cache = NSCache<WrappedKey, Entry>()
  /// Default Time-To-Live (TTL) for cache entries
  private var ttl: TimeInterval

  /// Initializes the cache manager with an optional TTL (defaults to 24 hours)
  init(ttl: TimeInterval = Constants.defaultTTL) {
    self.ttl = ttl
  }

  /// Changes the default TTL for new cache entries.
  func changeTTL(to ttl: TimeInterval) {
    self.ttl = ttl
  }

  /// Inserts a value into the cache with the specified key.
  func insert(_ value: Value, forKey key: Key) {
    let entry = Entry(value: value, expirationDate: Date().addingTimeInterval(self.ttl))
    self.cache.setObject(entry, forKey: WrappedKey(key))
  }

  /// Inserts multiple values into the cache with the specified keys. The number of items and their order must match the number of keys and their order.
  func insert(items: [Value], forKeys keys: [Key]) {

    guard items.count == keys.count else {
      assertionFailure("Trying to insert a number of items with a different number of keys")
      return
    }

    for (key, value) in zip(keys, items) {
      insert(value, forKey: key)
    }
  }

  /// Retrieves a value from the cache for the specified key.
  func value(forKey key: Key) -> Value? {

    guard let entry = cache.object(forKey: WrappedKey(key)) else { return nil }

    if let expirationDate = entry.expirationDate, expirationDate < Date() {
      // Remove expired entry
      self.cache.removeObject(forKey: WrappedKey(key))
      return nil
    }

    return entry.value
  }

  /// Removes a value from the cache for the specified key.
  func removeValue(forKey key: Key) {

    self.cache.removeObject(forKey: WrappedKey(key))
  }

  /// Clears all entries from the cache.
  func clear() {

    self.cache.removeAllObjects()
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
  class Entry {

    let value: Value
    let expirationDate: Date?

    init(value: Value, expirationDate: Date?) {

      self.value = value
      self.expirationDate = expirationDate
    }
  }
}
