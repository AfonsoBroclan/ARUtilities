//
//  NetworkCacheManagerMock.swift
//  ARUtilities
//
//  Created by Afonso Rosa on 27/01/2026.
//

import Foundation

@testable import ARPersistence

/// Mock implementation of NetworkCacheManagerProtocol for testing purposes.
final class NetworkCacheManagerMock<Key: Hashable & Sendable>: NetworkCacheManagerProtocol, @unchecked Sendable {

    // MARK: - Tracking Properties

    private(set) var storage: [Key: Any] = [:]
    var saveCallCount = 0
    private(set) var objectCallCount = 0
    private(set) var removeCallCount = 0
    private(set) var clearCallCount = 0

    // MARK: - Configuration

    var shouldReturnCachedObject = true

    // MARK: - Protocol Implementation

    func object<T: Sendable>(forKey key: Key) async -> T? {
        objectCallCount += 1

        guard shouldReturnCachedObject else { return nil }
        return storage[key] as? T
    }

    func saveObject<T: Sendable>(_ object: T, forKey key: Key) async {
        saveCallCount += 1
        storage[key] = object
    }

    func removeObject(forKey key: Key) async {
        removeCallCount += 1
        storage.removeValue(forKey: key)
    }

    func clear() async {
        clearCallCount += 1
        storage.removeAll()
    }

    // MARK: - Helper Methods

    func reset() {
        storage.removeAll()
        saveCallCount = 0
        objectCallCount = 0
        removeCallCount = 0
        clearCallCount = 0
        shouldReturnCachedObject = true
    }

    func hasCachedObject<T>(forKey key: Key) -> T? {
        storage[key] as? T
    }
}
