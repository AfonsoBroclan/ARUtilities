//
//  GenericCacheManagerTests.swift
//  ARUtilities
//
//  Created by Afonso Rosa on 15/12/2025.
//

import Foundation
import Testing

@testable import ARPersistence

struct GenericCacheManagerTests {

  @Test
  func insertAndRetrieve() async {

    let cacheManager = GenericCacheManager<String, String>()

    let key = "testKey"
    let value = "testValue"

    await cacheManager.insert(value, forKey: key)
    let retrievedValue = await cacheManager.value(forKey: key)
    #expect(retrievedValue == value, "Retrieved value should match the inserted value")
    
    let nonExistentValue = await cacheManager.value(forKey: "nonExistentKey")
    #expect(nonExistentValue == nil, "Retrieving a non-existent key should return nil")

    let keys = ["key1", "key2", "key3"]
    let values = ["value1", "value2", "value3"]

    try? await cacheManager.insert(items: values, forKeys: keys)

    for (key, expectedValue) in zip(keys, values) {
      let retrieved = await cacheManager.value(forKey: key)
      #expect(retrieved == expectedValue, "Retrieved value for \(key) should match the inserted value")
    }
  }

  @Test
  func insertMismatchedKeysAndValuesThrows() async {
    let cacheManager = GenericCacheManager<String, String>()

    let keys = ["key1", "key2", "key3"]
    let values = ["value1", "value2"] // Mismatched count

    do {
      try await cacheManager.insert(items: values, forKeys: keys)
      Issue.record("Expected keyValueCountMismatch error to be thrown")
    } catch GenericCacheManagerError.keyValueCountMismatch {
      // Expected error
    } catch {
      Issue.record("Unexpected error thrown: \(error)")
    }
  }

  @Test
  func changeTTL() async {
    let customTTL: TimeInterval = 1.0  // 1 second
    let cacheManager = GenericCacheManager<String, String>()

    await cacheManager.changeTTL(to: customTTL)

    let key = "tempKey"
    let value = "tempValue"

    await cacheManager.insert(value, forKey: key)

    let immediateValue = await cacheManager.value(forKey: key)
    #expect(immediateValue == value, "Value should be retrievable immediately after insertion")

    // Sleep for longer than the custom TTL
    let sleepDuration: TimeInterval = (customTTL + 0.1) * 1_000_000_000  // Add 0.1 seconds buffer
    try? await Task.sleep(nanoseconds: UInt64(sleepDuration))

    let expiredValue = await cacheManager.value(forKey: key)
    #expect(expiredValue == nil, "Value should expire after custom TTL set via changeTTL")
  }

  @Test
  func defaultTTL() async {
    let cacheManager = GenericCacheManager<String, String>()

    let key = "tempKey"
    let value = "tempValue"

    await cacheManager.insert(value, forKey: key)

    let immediateValue = await cacheManager.value(forKey: key)
    #expect(immediateValue == value, "Value should be retrievable immediately after insertion")

    // With default 24-hour TTL, value should still be available after a short wait
    try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds

    let persistentValue = await cacheManager.value(forKey: key)
    #expect(persistentValue == value, "Value should persist with default 24-hour TTL")
  }

  @Test
  func remove() async {

    let cacheManager = GenericCacheManager<String, String>()

    let key = "removeKey"
    let value = "removeValue"

    await cacheManager.insert(value, forKey: key)
    var retrievedValue = await cacheManager.value(forKey: key)
    #expect(retrievedValue == value, "Value should be retrievable before removal")

    await cacheManager.removeValue(forKey: key)
    retrievedValue = await cacheManager.value(forKey: key)
    #expect(retrievedValue == nil, "Value should be nil after removal")

    await cacheManager.removeValue(forKey: "nonExistentKey") // Should not crash
  }

  @Test
  func clear() async {
    let cacheManager = GenericCacheManager<String, String>()

    let items = ["key1": "value1", "key2": "value2", "key3": "value3"]

    for (key, value) in items {
      await cacheManager.insert(value, forKey: key)
    }

    for key in items.keys {
      let retrievedValue = await cacheManager.value(forKey: key)
      #expect(retrievedValue == items[key], "Value for \(key) should be retrievable before clearing")
    }

    await cacheManager.clear()

    for key in items.keys {
      let retrievedValue = await cacheManager.value(forKey: key)
      #expect(retrievedValue == nil, "Value for \(key) should be nil after clearing")
    }
  }

  @Test
  func intKeys() async {
    let cacheManager = GenericCacheManager<Int, String>()

    let key = 42
    let value = "The answer"
    await cacheManager.insert(value, forKey: key)
    let retrievedValue = await cacheManager.value(forKey: key)
    #expect(retrievedValue == value, "Retrieved value should match the inserted value for Int key")
  }

  @Test
  func dataValues() async {
    let cacheManager = GenericCacheManager<String, Data>()

    let key = "dataKey"
    let value = "DataValue".data(using: .utf8)!
    await cacheManager.insert(value, forKey: key)
    let retrievedValue = await cacheManager.value(forKey: key)
    #expect(retrievedValue == value, "Retrieved Data value should match the inserted value")
  }

  @Test
  func concurrentAccess() async {
    let cacheManager = GenericCacheManager<String, String>()

    let keys = (0..<100).map { "key\($0)" }
    let values = (0..<100).map { "value\($0)" }

    // insert values concurrently
    await withTaskGroup(of: Void.self) { group in
      for (key, value) in zip(keys, values) {
        group.addTask {
          await cacheManager.insert(value, forKey: key)
        }
      }
    }

    // retrieve values concurrently
    await withTaskGroup(of: Void.self) { group in
      for (key, expectedValue) in zip(keys, values) {
        group.addTask {
          let retrieved = await cacheManager.value(forKey: key)
          #expect(retrieved == expectedValue, "Retrieved value for \(key) should match the inserted value")
        }
      }
    }
  }

  @Test
  func initializerWithCustomTTL() async {
    let customTTL: TimeInterval = 2.0  // 2 seconds
    let cacheManager = GenericCacheManager<String, String>(ttl: customTTL)

    let key = "customTTLKey"
    let value = "customTTLValue"

    await cacheManager.insert(value, forKey: key)

    let immediateValue = await cacheManager.value(forKey: key)
    #expect(immediateValue == value, "Value should be retrievable immediately after insertion")

    // Sleep for longer than the custom TTL
    try? await Task.sleep(nanoseconds: UInt64((customTTL + 0.5) * 1_000_000_000))

    let expiredValue = await cacheManager.value(forKey: key)
    #expect(expiredValue == nil, "Value should expire after custom TTL")
  }

  @Test
  func setCountLimit() async {
    let cacheManager = GenericCacheManager<Int, String>()

    // Set count limit to 5
    await cacheManager.setCountLimit(5)

    // Insert 10 items
    for i in 0..<10 {
      await cacheManager.insert("value\(i)", forKey: i)
    }

    // NSCache may evict items when limit is exceeded based on system memory pressure
    // We can't guarantee which items will be evicted, but we can verify
    // that at least some items are still cached
    var cachedCount = 0
    for i in 0..<10 {
      if await cacheManager.value(forKey: i) != nil {
        cachedCount += 1
      }
    }

    // With a limit of 5, we expect at most 5 items (but NSCache may evict earlier based on system policy)
    #expect(cachedCount <= 5, "Cache should respect count limit and contain at most 5 items")
  }
}
