//
//  NetworkCacheManagerProtocol.swift
//  ARUtilities
//
//  Created by Afonso Rosa on 27/01/2026.
//

import Foundation
import Testing

@testable import ARPersistence

@Suite("NetworkCacheManager Tests")
struct NetworkCacheManagerTests {

    // MARK: - Test Types

    private enum TestEndpoint: String, Hashable, Sendable {
        case users = "/users"
        case posts = "/posts"
        case profile = "/profile"
    }

    private struct TestUser: Sendable, Equatable {
        let id: Int
        let name: String
    }

    private struct TestPost: Sendable, Equatable {
        let id: Int
        let title: String
        let content: String
    }

    // MARK: - Basic Functionality Tests

    @Test("Save and retrieve object")
    func saveAndRetrieveObject() async {
        // Given
        let cacheManager = NetworkCacheManager<TestEndpoint>()
        let user = TestUser(id: 1, name: "John Doe")
        let key = TestEndpoint.users

        // When
        await cacheManager.saveObject(user, forKey: key)
        let retrievedUser: TestUser? = await cacheManager.object(forKey: key)

        // Then
        #expect(retrievedUser == user, "Retrieved user matches the saved user")
    }

    @Test("Retrieve non-existent object returns nil")
    func retrieveNonExistentObject() async {
        // Given
        let cacheManager = NetworkCacheManager<TestEndpoint>()
        let key = TestEndpoint.users

        // When
        let retrievedUser: TestUser? = await cacheManager.object(forKey: key)

        // Then
        #expect(retrievedUser == nil, "Retrieving a non-existent object should return nil")
    }

    @Test("Overwrite existing object")
    func overwriteExistingObject() async {
        // Given
        let cacheManager = NetworkCacheManager<TestEndpoint>()
        let user1 = TestUser(id: 1, name: "John Doe")
        let user2 = TestUser(id: 2, name: "Jane Smith")
        let key = TestEndpoint.users

        // When
        await cacheManager.saveObject(user1, forKey: key)
        await cacheManager.saveObject(user2, forKey: key)
        let retrievedUser: TestUser? = await cacheManager.object(forKey: key)

        // Then
        #expect(retrievedUser == user2, "The object in the cache should be the overwritten one")
    }

    // MARK: - Type Safety Tests

    @Suite("Type Safety")
    struct TypeSafetyTests {

        @Test("Different types with same key")
        func differentTypesWithSameKey() async {
            // Given
            let cacheManager = NetworkCacheManager<TestEndpoint>()
            let user = TestUser(id: 1, name: "John Doe")
            let post = TestPost(id: 1, title: "Title", content: "Content")
            let key = TestEndpoint.users

            // When
            await cacheManager.saveObject(user, forKey: key)
            await cacheManager.saveObject(post, forKey: key) // Overwrites with different type

            let retrievedUser: TestUser? = await cacheManager.object(forKey: key)
            let retrievedPost: TestPost? = await cacheManager.object(forKey: key)

            // Then
            #expect(retrievedUser == nil, "User should be nil after being overwritten")
            #expect(retrievedPost == post, "The object in the cache should be the overwritten one")
        }

        @Test("Multiple different keys and types")
        func multipleDifferentKeysAndTypes() async {
            // Given
            let cacheManager = NetworkCacheManager<TestEndpoint>()
            let user = TestUser(id: 1, name: "John Doe")
            let post = TestPost(id: 1, title: "Title", content: "Content")

            // When
            await cacheManager.saveObject(user, forKey: .users)
            await cacheManager.saveObject(post, forKey: .posts)

            let retrievedUser: TestUser? = await cacheManager.object(forKey: .users)
            let retrievedPost: TestPost? = await cacheManager.object(forKey: .posts)

            // Then
            #expect(retrievedUser == user, "Should get the correct user for the users key")
            #expect(retrievedPost == post, "Should get the correct post for the posts key")
        }
    }

    // MARK: - Remove Tests

    @Suite("Remove Operations")
    struct RemoveTests {

        @Test("Remove object")
        func removeObject() async {
            // Given
            let cacheManager = NetworkCacheManager<TestEndpoint>()
            let user = TestUser(id: 1, name: "John Doe")
            let key = TestEndpoint.users
            await cacheManager.saveObject(user, forKey: key)

            // When
            await cacheManager.removeObject(forKey: key)
            let retrievedUser: TestUser? = await cacheManager.object(forKey: key)

            // Then
            #expect(retrievedUser == nil, "Expected to not retrieve the saved object")
        }

        @Test("Remove non-existent object does not crash")
        func removeNonExistentObject() async {
            // Given
            let cacheManager = NetworkCacheManager<TestEndpoint>()
            let key = TestEndpoint.users

            // When/Then - Should not crash
            await cacheManager.removeObject(forKey: key)

            let retrievedUser: TestUser? = await cacheManager.object(forKey: key)
            #expect(retrievedUser == nil, "Expected to not retrieve the saved object")
        }

        @Test("Remove one of multiple objects")
        func removeOneOfMultipleObjects() async {
            // Given
            let cacheManager = NetworkCacheManager<TestEndpoint>()
            let user = TestUser(id: 1, name: "John Doe")
            let post = TestPost(id: 1, title: "Title", content: "Content")

            await cacheManager.saveObject(user, forKey: .users)
            await cacheManager.saveObject(post, forKey: .posts)

            // When
            await cacheManager.removeObject(forKey: .users)

            // Then
            let retrievedUser: TestUser? = await cacheManager.object(forKey: .users)
            let retrievedPost: TestPost? = await cacheManager.object(forKey: .posts)

            #expect(retrievedUser == nil, "User should have been removed")
            #expect(retrievedPost == post, "Post should still be available")
        }
    }

    // MARK: - Clear Tests

    @Suite("Clear Operations")
    struct ClearTests {

        @Test("Clear cache removes all objects")
        func clearCache() async {
            // Given
            let cacheManager = NetworkCacheManager<TestEndpoint>()
            let user = TestUser(id: 1, name: "John Doe")
            let post = TestPost(id: 1, title: "Title", content: "Content")

            await cacheManager.saveObject(user, forKey: .users)
            await cacheManager.saveObject(post, forKey: .posts)

            // When
            await cacheManager.clear()

            // Then
            let retrievedUser: TestUser? = await cacheManager.object(forKey: .users)
            let retrievedPost: TestPost? = await cacheManager.object(forKey: .posts)

            #expect(retrievedUser == nil, "Retrieved user should be nil as it was cleared")
            #expect(retrievedPost == nil, "Retrieved post should be nil as it was cleared")
        }

        @Test("Clear empty cache does not crash")
        func clearEmptyCache() async {
            // Given
            let cacheManager = NetworkCacheManager<TestEndpoint>()

            // When/Then - Should not crash
            await cacheManager.clear()

            let retrievedUser: TestUser? = await cacheManager.object(forKey: .users)
            #expect(retrievedUser == nil, "Retrieved user should be nil as the cache is empty")
        }
    }

    // MARK: - TTL Expiration Tests

    @Suite("TTL Expiration")
    struct TTLTests {

        @Test("Object expires after TTL")
        func objectExpiresAfterTTL() async throws {
            // Given
            let shortTTL: TimeInterval = 0.5 // 500ms
            let cacheManager = NetworkCacheManager<TestEndpoint>(ttl: shortTTL)

            let user = TestUser(id: 1, name: "John Doe")
            let key = TestEndpoint.users

            // When
            await cacheManager.saveObject(user, forKey: key)

            // Verify it's there immediately
            let immediateUser: TestUser? = await cacheManager.object(forKey: key)
            #expect(immediateUser != nil)

            // Wait for expiration
            try await Task.sleep(nanoseconds: 600_000_000) // 600ms

            // Then
            let expiredUser: TestUser? = await cacheManager.object(forKey: key)
            #expect(expiredUser == nil, "Object should be nil after TTL expiration")
        }

        @Test("Object does not expire before TTL")
        func objectDoesNotExpireBeforeTTL() async throws {
            // Given
            let longTTL: TimeInterval = 2.0 // 2 seconds
            let cacheManager = NetworkCacheManager<TestEndpoint>(ttl: longTTL)

            let user = TestUser(id: 1, name: "John Doe")
            let key = TestEndpoint.users

            // When
            await cacheManager.saveObject(user, forKey: key)

            // Wait less than TTL
            try await Task.sleep(nanoseconds: 500_000_000) // 500ms

            // Then
            let retrievedUser: TestUser? = await cacheManager.object(forKey: key)
            #expect(retrievedUser == user, "Object should not be nil before TTL expiration")
        }
    }

    // MARK: - Concurrency Tests

    @Suite("Concurrency")
    struct ConcurrencyTests {

        @Test("Concurrent writes to different keys")
        func concurrentWrites() async {
            // Given
            let cacheManager = NetworkCacheManager<TestEndpoint>()
            let iterations = 100

            // When - Concurrent writes to different keys
            await withTaskGroup(of: Void.self) { group in
                for i in 0..<iterations {
                    group.addTask {
                        let user = TestUser(id: i, name: "User \(i)")
                        let key: TestEndpoint = i % 2 == 0 ? .users : .posts
                        await cacheManager.saveObject(user, forKey: key)
                    }
                }
            }

            // Then - Should not crash, last write wins for each key
            let usersResult: TestUser? = await cacheManager.object(forKey: .users)
            let postsResult: TestUser? = await cacheManager.object(forKey: .posts)

            #expect(usersResult != nil, "Expected to retrieve a user")
            #expect(postsResult != nil, "Expected to retrieve a user")
        }

        @Test("Concurrent read and write operations")
        func concurrentReadWrite() async {
            // Given
            let cacheManager = NetworkCacheManager<TestEndpoint>()
            let user = TestUser(id: 1, name: "John Doe")
            await cacheManager.saveObject(user, forKey: .users)

            // When - Concurrent reads and writes
            await withTaskGroup(of: TestUser?.self) { group in
                // Add writers
                for i in 0..<50 {
                    group.addTask {
                        let newUser = TestUser(id: i, name: "User \(i)")
                        await cacheManager.saveObject(newUser, forKey: .users)
                        return nil
                    }
                }

                // Add readers
                for _ in 0..<50 {
                    group.addTask {
                        await cacheManager.object(forKey: .users) as TestUser?
                    }
                }
            }

            // Then - Should not crash
            let finalUser: TestUser? = await cacheManager.object(forKey: .users)
            #expect(finalUser != nil, "Expected to retrieve a user")
        }
    }

    // MARK: - Edge Cases

    @Suite("Edge Cases")
    struct EdgeCaseTests {

        @Test("Cache with complex nested types")
        func cacheWithComplexTypes() async {
            // Given
            struct ComplexType: Sendable, Equatable {
                let array: [Int]
                let dictionary: [String: String]
                let optional: String?
                let nested: NestedType

                struct NestedType: Sendable, Equatable {
                    let value: Int
                }
            }

            let cacheManager = NetworkCacheManager<TestEndpoint>()
            let complex = ComplexType(
                array: [1, 2, 3],
                dictionary: ["key": "value"],
                optional: "optional",
                nested: ComplexType.NestedType(value: 42)
            )

            // When
            await cacheManager.saveObject(complex, forKey: .users)
            let retrieved: ComplexType? = await cacheManager.object(forKey: .users)

            // Then
            #expect(retrieved == complex, "The retrieved value should match the cached value")
        }

        @Test("Cache with optional values")
        func cacheWithOptionalValues() async {
            // Given
            let cacheManager = NetworkCacheManager<TestEndpoint>()
            let optionalString: String? = "Hello"
            let nilString: String? = nil

            // When
            await cacheManager.saveObject(optionalString, forKey: .users)
            await cacheManager.saveObject(nilString, forKey: .posts)

            let retrievedOptional: String?? = await cacheManager.object(forKey: .users)
            let retrievedNil: String?? = await cacheManager.object(forKey: .posts)

            // Then
            #expect((retrievedOptional as? String) == "Hello", "The optional should be unwrapped and match")
            #expect(retrievedNil != nil, "The wrapper should exist even though the value is nil")
            #expect((retrievedNil as? String) == nil, "The optional should be nil")
        }

        @Test("Cache with arrays")
        func cacheWithArrays() async {
            // Given
            let cacheManager = NetworkCacheManager<TestEndpoint>()
            let users = [
                TestUser(id: 1, name: "John"),
                TestUser(id: 2, name: "Jane"),
                TestUser(id: 3, name: "Bob")
            ]

            // When
            await cacheManager.saveObject(users, forKey: .users)
            let retrieved: [TestUser]? = await cacheManager.object(forKey: .users)

            // Then
            #expect(retrieved == users, "The retrieved array should match the one we cached")
        }

        @Test("Cache with dictionaries")
        func cacheWithDictionaries() async {
            // Given
            let cacheManager = NetworkCacheManager<TestEndpoint>()
            let userDict = [
                "user1": TestUser(id: 1, name: "John"),
                "user2": TestUser(id: 2, name: "Jane")
            ]

            // When
            await cacheManager.saveObject(userDict, forKey: .users)
            let retrieved: [String: TestUser]? = await cacheManager.object(forKey: .users)

            // Then
            #expect(retrieved == userDict, "The retrieved dictionary should match the one we cached")
        }
    }
}
