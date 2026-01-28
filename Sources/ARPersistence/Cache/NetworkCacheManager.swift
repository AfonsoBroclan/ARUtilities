//
//  NetworkCacheManager.swift
//  ARUtilities
//
//  Created by Afonso Rosa on 27/01/2026.
//

import Foundation

/// A protocol defining the interface for a cache manager. It's main usage is to cache the API responses.
public protocol NetworkCacheManagerProtocol {

    associatedtype Key: Hashable & Sendable

    /// Removes all objects from cache.
    func clear() async
    /// Retrieves a cached object for the given key.
    func object<T: Sendable>(forKey key: Key) async -> T?
    /// Removes an object from cache with the specified key.
    func removeObject(forKey key: Key) async
    /// Saves an object to the cache with the specified key.
    func saveObject<T: Sendable>(_ object: T, forKey key: Key) async
}

public enum NetworkCacheManagerConstants {
    public static let defaultTTL: TimeInterval = 86400 // 1 day in seconds
}

public final class NetworkCacheManager<Endpoint: Hashable & Sendable>: NetworkCacheManagerProtocol, Sendable {

    /// Internal generic cache manager instance
    private let cache: GenericCacheManager<Endpoint, AnyCacheable>

    public init(ttl: TimeInterval = NetworkCacheManagerConstants.defaultTTL) {
        cache = .init(ttl: ttl)
    }

    public func clear() async {
        await self.cache.clear()
    }

    public func object<T: Sendable>(forKey key: Endpoint) async -> T? {
        guard let entry = await cache.value(forKey: key) else { return nil }
        return entry.base as? T
    }

    public func removeObject(forKey key: Endpoint) async {
        await self.cache.removeValue(forKey: key)
    }

    public func saveObject<T: Sendable>(_ object: T, forKey key: Endpoint) async {
        let wrapped = AnyCacheable(object)
        await self.cache.insert(wrapped, forKey: key)
    }
}

/// Type-erasing wrapper that ensures Sendable conformance.
/// Wraps any Sendable value to be stored in the generic cache.
private struct AnyCacheable: Sendable {
    /// The underlying Sendable value
    let base: any Sendable

    /// Creates a type-erased cacheable wrapper
    /// - Parameter value: The Sendable value to wrap
    init<T: Sendable>(_ value: T) {
        self.base = value
    }
}
