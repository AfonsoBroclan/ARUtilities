//
//  NetworkManagerTests.swift
//  ARUtilities
//
//  Created by Afonso Rosa on 27/01/2026.
//

import Foundation
import Testing

@testable import ARNetworking

// MARK: - Test Models

struct TestUser: Codable, Sendable, Equatable {
    let id: Int
    let name: String
    let email: String
}

struct TestPost: Codable, Sendable, Equatable {
    let id: Int
    let title: String
    let body: String
}

struct TestError: Codable, Sendable, Equatable {
    let message: String
    let code: Int
}

// MARK: - Test Endpoints

enum TestEndpoint: Endpoint {
    case users
    case user(id: Int)
    case posts
    case createPost(title: String, body: String)
    case updatePost(id: Int)

    var path: String {
        switch self {
        case .users:
            return "/users"
        case .user(let id):
            return "/users/\(id)"
        case .posts:
            return "/posts"
        case .createPost:
            return "/posts"
        case .updatePost(let id):
            return "/posts/\(id)"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .users, .user, .posts:
            return .get
        case .createPost:
            return .post
        case .updatePost:
            return .put
        }
    }

    var body: Data? {
        switch self {
        case .createPost(let title, let body):
            return try? JSONEncoder().encode(["title": title, "body": body])
        case .updatePost:
            return try? JSONEncoder().encode(["updated": true])
        default:
            return nil
        }
    }

    var headers: [String: String]? {
        switch self {
        case .createPost, .updatePost:
            return ["Content-Type": "application/json"]
        default:
            return nil
        }
    }
}

// MARK: - Network Manager Tests

@Suite("NetworkManager Tests")
struct NetworkManagerTests {

    // MARK: - Successful Request Tests

    @Suite("Successful Requests")
    struct SuccessfulRequestTests {

        @Test("Request successfully decodes and caches response")
        func successfulRequest() async throws {
            // Given
            let expectedUser = TestUser(id: 1, name: "John Doe", email: "john@example.com")
            let mockSession = try URLSessionMock(object: expectedUser)
            let mockCache = NetworkCacheManagerMock<TestEndpoint>()

            let networkManager = NetworkManager(
                baseURL: "https://api.example.com",
                cacheManager: mockCache,
                urlSession: mockSession
            )

            // When
            let result: TestUser = try await networkManager.request(
                endpoint: TestEndpoint.users,
                bypassCache: false
            )

            // Then
            #expect(result == expectedUser, "The decoded object does not match the expected object")
            #expect(mockCache.saveCallCount == 1, "The object was not saved to the cache")
            #expect(mockCache.objectCallCount == 1, "The object was not retrieved from the cache")
            #expect(mockCache.hasCachedObject(forKey: TestEndpoint.users) as TestUser? == expectedUser,
                    "The object was not cached correctly")
        }

        @Test("Request with different HTTP methods", arguments: [
            (TestEndpoint.users, HTTPMethod.get),
            (TestEndpoint.createPost(title: "Test", body: "Body"), HTTPMethod.post),
            (TestEndpoint.updatePost(id: 1), HTTPMethod.put)
        ])
        func requestWithDifferentMethods(endpoint: TestEndpoint, expectedMethod: HTTPMethod) async throws {
            // Given
            let mockUser = TestUser(id: 1, name: "Test", email: "test@example.com")
            let mockSession = try URLSessionMock(object: mockUser)
            let mockCache = NetworkCacheManagerMock<TestEndpoint>()

            let networkManager = NetworkManager(
                baseURL: "https://api.example.com",
                cacheManager: mockCache,
                urlSession: mockSession
            )

            // When
            let _: TestUser = try await networkManager.request(
                endpoint: endpoint,
                bypassCache: false
            )

            // Then
            #expect(endpoint.method == expectedMethod, "The request used a different HTTP method than expected")
        }

        @Test("Request with different status codes", arguments: [200, 201, 204, 299])
        func requestWithSuccessStatusCodes(statusCode: Int) async throws {
            // Given
            let expectedUser = TestUser(id: 1, name: "John", email: "john@example.com")
            let mockSession = try URLSessionMock(object: expectedUser)
            mockSession.statusCode = statusCode
            let mockCache = NetworkCacheManagerMock<TestEndpoint>()

            let networkManager = NetworkManager(
                baseURL: "https://api.example.com",
                cacheManager: mockCache,
                urlSession: mockSession
            )

            // When/Then - Should not throw
            let _: TestUser = try await networkManager.request(
                endpoint: TestEndpoint.users,
                bypassCache: false
            )
        }
    }

    // MARK: - Cache Behavior Tests

    @Suite("Cache Behavior")
    struct CacheBehaviorTests {

        @Test("Returns cached object when available and not bypassing cache")
        func returnsCachedObject() async throws {
            // Given
            let cachedUser = TestUser(id: 1, name: "Cached", email: "cached@example.com")
            let networkUser = TestUser(id: 2, name: "Network", email: "network@example.com")

            let mockSession = try URLSessionMock(object: networkUser)
            let mockCache = NetworkCacheManagerMock<TestEndpoint>()

            // Pre-populate cache
            await mockCache.saveObject(cachedUser, forKey: TestEndpoint.users)
            mockCache.saveCallCount = 0 // Reset counter

            let networkManager = NetworkManager(
                baseURL: "https://api.example.com",
                cacheManager: mockCache,
                urlSession: mockSession
            )

            // When
            let result: TestUser = try await networkManager.request(
                endpoint: TestEndpoint.users,
                bypassCache: false
            )

            // Then
            #expect(result == cachedUser, "Should return the cached object")
            #expect(mockCache.objectCallCount == 1, "Should attempt to retrieve from cache")
            #expect(mockCache.saveCallCount == 0, "Should not save when returning cached object")
        }

        @Test("Bypasses cache when bypassCache is true")
        func bypassesCache() async throws {
            // Given
            let cachedUser = TestUser(id: 1, name: "Cached", email: "cached@example.com")
            let networkUser = TestUser(id: 2, name: "Network", email: "network@example.com")

            let mockSession = try URLSessionMock(object: networkUser)
            let mockCache = NetworkCacheManagerMock<TestEndpoint>()

            // Pre-populate cache
            await mockCache.saveObject(cachedUser, forKey: TestEndpoint.users)
            mockCache.saveCallCount = 0

            let networkManager = NetworkManager(
                baseURL: "https://api.example.com",
                cacheManager: mockCache,
                urlSession: mockSession
            )

            // When
            let result: TestUser = try await networkManager.request(
                endpoint: TestEndpoint.users,
                bypassCache: true
            )

            // Then
            #expect(result == networkUser, "Should fetch from network.")
            #expect(mockCache.saveCallCount == 1, "Should save new response")
        }

        @Test("Fetches from network when cache is empty")
        func fetchesFromNetworkWhenCacheEmpty() async throws {
            // Given
            let expectedUser = TestUser(id: 1, name: "John", email: "john@example.com")
            let mockSession = try URLSessionMock(object: expectedUser)
            let mockCache = NetworkCacheManagerMock<TestEndpoint>()

            let networkManager = NetworkManager(
                baseURL: "https://api.example.com",
                cacheManager: mockCache,
                urlSession: mockSession
            )

            // When
            let result: TestUser = try await networkManager.request(
                endpoint: TestEndpoint.users,
                bypassCache: false
            )

            // Then
            #expect(result == expectedUser, "Should fetch from network.")
            #expect(mockCache.objectCallCount == 1, "Should cache the fetched object")
            #expect(mockCache.saveCallCount == 1, "Should save the fetched object")
        }

        @Test("Different endpoints cache separately")
        func differentEndpointsCacheSeparately() async throws {
            // Given
            let user = TestUser(id: 1, name: "John", email: "john@example.com")
            let post = TestPost(id: 1, title: "Title", body: "Body")

            let mockSession = try URLSessionMock(object: user)
            let mockCache = NetworkCacheManagerMock<TestEndpoint>()

            let networkManager = NetworkManager(
                baseURL: "https://api.example.com",
                cacheManager: mockCache,
                urlSession: mockSession
            )

            // When - Request users
            let _: TestUser = try await networkManager.request(
                endpoint: TestEndpoint.users,
                bypassCache: false
            )

            // Change mock to return post
            try mockSession.setData(post)

            // Request posts
            let _: TestPost = try await networkManager.request(
                endpoint: TestEndpoint.posts,
                bypassCache: false
            )

            // Then
            #expect(mockCache.storage.count == 2, "Should have cached objects for both endpoints")
            #expect(mockCache.hasCachedObject(forKey: TestEndpoint.users) as TestUser? == user, "There should be an object for the users endpoint.")
            #expect(mockCache.hasCachedObject(forKey: TestEndpoint.posts) as TestPost? == post, "There should be an object for the posts endpoint.")
        }
    }

    // MARK: - Error Handling Tests

    @Suite("Error Handling")
    struct ErrorHandlingTests {

        @Test("Decoding error throws decodingError",
              arguments: ["{\"invalid\": \"json\"}",
                          "{}",
                          "{\"id\": \"not a number\", \"name\": \"Test\", \"email\": \"test@example.com\"}"
        ])
        func decodingError(invalidJSON: String) async throws {
            // Given
            let mockSession = try URLSessionMock.createWithRawData(invalidJSON.data(using: .utf8)!)
            let mockCache = NetworkCacheManagerMock<TestEndpoint>()

            let networkManager = NetworkManager(
                baseURL: "https://api.example.com",
                cacheManager: mockCache,
                urlSession: mockSession
            )

            // When/Then
            do {
                let _: TestUser = try await networkManager.request(
                    endpoint: TestEndpoint.users,
                    bypassCache: false
                )
                Issue.record("Should have thrown decodingError")
            } catch let error {
                switch error {
                case .decodingError:
                    break // Expected
                default:
                    Issue.record("Wrong APIError type: \(error)")
                }
            }
        }

        @Test("Rate limit errors", arguments: [429, 403])
        func rateLimitErrors(statusCode: Int) async throws {
            // Given
            let mockUser = TestUser(id: 1, name: "Test", email: "test@example.com")
            let mockSession = try URLSessionMock(object: mockUser)
            mockSession.statusCode = statusCode
            let mockCache = NetworkCacheManagerMock<TestEndpoint>()

            let networkManager = NetworkManager(
                baseURL: "https://api.example.com",
                cacheManager: mockCache,
                urlSession: mockSession
            )

            // When/Then
            do {
                let _: TestUser = try await networkManager.request(
                    endpoint: TestEndpoint.users,
                    bypassCache: false
                )
                Issue.record("Should have thrown rateLimited error")
            } catch let error {
                switch error {
                case .rateLimited:
                    break // Expected
                default:
                    Issue.record("Wrong APIError type: \(error)")
                }
            }
        }

        @Test("Client errors", arguments: [400, 401, 404, 422, 499])
        func clientErrors(statusCode: Int) async throws {
            // Given
            let mockUser = TestUser(id: 1, name: "Test", email: "test@example.com")
            let mockSession = try URLSessionMock(object: mockUser)
            mockSession.statusCode = statusCode
            let mockCache = NetworkCacheManagerMock<TestEndpoint>()

            let networkManager = NetworkManager(
                baseURL: "https://api.example.com",
                cacheManager: mockCache,
                urlSession: mockSession
            )

            // When/Then
            do {
                let _: TestUser = try await networkManager.request(
                    endpoint: TestEndpoint.users,
                    bypassCache: false
                )
                Issue.record("Should have thrown clientError")
            } catch let error {
                switch error {
                case .clientError(let code):
                    #expect(code == statusCode, "Incorrect status code")
                default:
                    Issue.record("Wrong APIError type: \(error)")
                }
            }
        }

        @Test("Server errors", arguments: [500, 502, 503, 504, 599])
        func serverErrors(statusCode: Int) async throws {
            // Given
            let mockUser = TestUser(id: 1, name: "Test", email: "test@example.com")
            let mockSession = try URLSessionMock(object: mockUser)
            mockSession.statusCode = statusCode
            let mockCache = NetworkCacheManagerMock<TestEndpoint>()

            let networkManager = NetworkManager(
                baseURL: "https://api.example.com",
                cacheManager: mockCache,
                urlSession: mockSession
            )

            // When/Then
            do {
                let _: TestUser = try await networkManager.request(
                    endpoint: TestEndpoint.users,
                    bypassCache: false
                )
                Issue.record("Should have thrown serverError")
            } catch let error {
                switch error {
                case .serverError(let code):
                    #expect(code == statusCode, "Incorrect status code")
                default:
                    Issue.record("Wrong APIError type: \(error)")
                }
            }
        }

        @Test("Network error when URLSession throws")
        func networkError() async {
            // Given
            let mockUser = TestUser(id: 1, name: "Test", email: "test@example.com")
            let mockSession = try! URLSessionMock(object: mockUser)

            struct CustomNetworkError: Error {}
            mockSession.errorToThrow = CustomNetworkError()

            let mockCache = NetworkCacheManagerMock<TestEndpoint>()

            let networkManager = NetworkManager(
                baseURL: "https://api.example.com",
                cacheManager: mockCache,
                urlSession: mockSession
            )

            // When/Then
            do {
                let _: TestUser = try await networkManager.request(
                    endpoint: TestEndpoint.users,
                    bypassCache: false
                )
                Issue.record("Should have thrown networkError")
            } catch let error {
                switch error {
                case .networkError(let underlyingError):
                    #expect(underlyingError is CustomNetworkError, "Wrong error thrown")
                default:
                    Issue.record("Wrong APIError type: \(error)")
                }
            }
        }

        @Test("Does not cache failed requests")
        func doesNotCacheFailedRequests() async throws {
            // Given
            let mockUser = TestUser(id: 1, name: "Test", email: "test@example.com")
            let mockSession = try URLSessionMock(object: mockUser)
            mockSession.statusCode = 500
            let mockCache = NetworkCacheManagerMock<TestEndpoint>()

            let networkManager = NetworkManager(
                baseURL: "https://api.example.com",
                cacheManager: mockCache,
                urlSession: mockSession
            )

            // When
            do {
                let _: TestUser = try await networkManager.request(
                    endpoint: TestEndpoint.users,
                    bypassCache: false
                )
                Issue.record("Should have thrown error")
            } catch {
                // Expected
            }

            // Then
            #expect(mockCache.saveCallCount == 0, "Request should not be cached")
            #expect(mockCache.storage.isEmpty, "Cache should be empty")
        }
    }

    // MARK: - Cache Management Tests

    @Suite("Cache Management")
    struct CacheManagementTests {

        @Test("Clear cache removes all cached responses")
        func clearCache() async throws {
            // Given
            let mockUser = TestUser(id: 1, name: "Test", email: "test@example.com")
            let mockSession = try URLSessionMock(object: mockUser)
            let mockCache = NetworkCacheManagerMock<TestEndpoint>()

            let networkManager = NetworkManager(
                baseURL: "https://api.example.com",
                cacheManager: mockCache,
                urlSession: mockSession
            )

            // Make some requests to populate cache
            let _: TestUser = try await networkManager.request(endpoint: TestEndpoint.users, bypassCache: false)
            let _: TestUser = try await networkManager.request(endpoint: TestEndpoint.user(id: 1), bypassCache: false)

            #expect(mockCache.storage.count == 2, "Cache should contain two entries")

            // When
            await networkManager.clearCache()

            // Then
            #expect(mockCache.clearCallCount == 1, "Clear Cache should have been called")
            #expect(mockCache.storage.isEmpty, "Cache should be empty after clearing")
        }

        @Test("Remove specific cached response")
        func removeCachedResponse() async throws {
            // Given
            let mockUser = TestUser(id: 1, name: "Test", email: "test@example.com")
            let mockSession = try URLSessionMock(object: mockUser)
            let mockCache = NetworkCacheManagerMock<TestEndpoint>()

            let networkManager = NetworkManager(
                baseURL: "https://api.example.com",
                cacheManager: mockCache,
                urlSession: mockSession
            )

            // Make requests to populate cache
            let _: TestUser = try await networkManager.request(endpoint: TestEndpoint.users, bypassCache: false)
            let _: TestUser = try await networkManager.request(endpoint: TestEndpoint.posts, bypassCache: false)

            #expect(mockCache.storage.count == 2, "Cache should contain two entries")

            // When
            await networkManager.removeCachedResponse(for: TestEndpoint.users)

            // Then
            #expect(mockCache.removeCallCount == 1, "Remove cached response should've been called")
            #expect(mockCache.storage.count == 1, "Cache should contain one entry after removal")
        }
    }

    // MARK: - Configuration Tests

    @Suite("Configuration")
    struct ConfigurationTests {

        @Test("Uses custom configuration")
        func usesCustomConfiguration() async throws {
            // Given
            let config = NetworkConfiguration(
                timeoutInterval: 30,
                cachePolicy: .reloadIgnoringLocalCacheData,
                defaultHeaders: ["Custom-Header": "Custom-Value"]
            )

            let mockUser = TestUser(id: 1, name: "Test", email: "test@example.com")
            let mockSession = try URLSessionMock(object: mockUser)
            let mockCache = NetworkCacheManagerMock<TestEndpoint>()

            let networkManager = NetworkManager(
                baseURL: "https://api.example.com",
                cacheManager: mockCache,
                urlSession: mockSession,
                configuration: config
            )

            // When / Then - Should not throw
            let _: TestUser = try await networkManager.request(
                endpoint: TestEndpoint.users,
                bypassCache: false
            )
        }
    }
}

// MARK: - URLSessionMock Extension

extension URLSessionMock {
    static func createWithRawData(_ data: Data) throws -> URLSessionMock {
        let mock = URLSessionMock.__createEmpty()
        try mock.setData(data)
        return mock
    }

    private static func __createEmpty() -> URLSessionMock {
        let mock = try! URLSessionMock(object: TestUser(id: 0, name: "", email: ""))
        return mock
    }
}
