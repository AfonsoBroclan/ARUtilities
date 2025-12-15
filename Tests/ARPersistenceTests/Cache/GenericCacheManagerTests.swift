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

    await cacheManager.insert(items: values, forKeys: keys)

    for (key, expectedValue) in zip(keys, values) {
      let retrieved = await cacheManager.value(forKey: key)
      #expect(retrieved == expectedValue, "Retrieved value for \(key) should match the inserted value")
    }
  }

  @Test(arguments: [1.0, nil])
  func ttl(for ttl: TimeInterval?) async {

    let cacheManager = GenericCacheManager<String, String>()

    if let ttl {
      await cacheManager.changeTTL(to: ttl)
    }

    let key = "tempKey"
    let value = "tempValue"

    await cacheManager.insert(value, forKey: key)

    let immediateValue = await cacheManager.value(forKey: key)
    #expect(immediateValue == value, "Value should be retrievable immediately after insertion")

    var duration: TimeInterval = 100_000_000 // 100 milliseconds in nanoseconds

    if let ttl {
      duration += ttl * 1_000_000_000 // Convert ttl to nanoseconds
    }

    try? await Task.sleep(nanoseconds: UInt64(duration))

    if ttl != nil {
      let expiredValue = await cacheManager.value(forKey: key)
      #expect(expiredValue == nil, "Value should expire after TTL")
    } else {
      let persistentValue = await cacheManager.value(forKey: key)
      #expect(persistentValue == value, "Value should persist without TTL")
    }
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
}
