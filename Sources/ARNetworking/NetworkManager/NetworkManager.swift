//
//  NetworkManager.swift
//  ARUtilities
//
//  Created by Afonso Rosa on 27/01/2026.
//

import ARPersistence
import Foundation

// MARK: - Network Manager

/// Manages network requests and caching.
public final class NetworkManager<Cache: NetworkCacheManagerProtocol> where Cache.Key: Endpoint {

    /// Base URL to prefix every endpoint.
    private let baseURL: String
    /// Cache manager for storing and retrieving cached network responses.
    private let cacheManager: Cache
    /// URL session for making network requests.
    private let urlSession: URLSessionProtocol
    /// Network configuration
    private let configuration: NetworkConfiguration

    public init(
        baseURL: String,
        cacheManager: Cache,
        urlSession: URLSessionProtocol = URLSession.shared,
        configuration: NetworkConfiguration = .init()
    ) {
        self.baseURL = baseURL
        self.cacheManager = cacheManager
        self.urlSession = urlSession
        self.configuration = configuration
    }

    /// Makes a network request to the specified endpoint and decodes the response.
    /// - Parameters:
    ///   - endpoint: The API endpoint to request.
    ///   - bypassCache: If true, ignores cached data and fetches fresh data.
    /// - Returns: A decoded object of type `T`.
    public func request<T: Decodable & Sendable>(
        endpoint: Cache.Key,
        bypassCache: Bool = false
    ) async throws(APIError) -> T {

        // Check cache first if not bypassing
        if bypassCache == false,
           let cachedObject: T = await cacheManager.object(forKey: endpoint) {
            return cachedObject
        }

        // Build URLRequest
        guard let url = URL(string: baseURL + endpoint.path) else {
            throw APIError.invalidURL
        }

        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = endpoint.method.rawValue
        urlRequest.httpBody = endpoint.body
        urlRequest.timeoutInterval = configuration.timeoutInterval
        urlRequest.cachePolicy = configuration.cachePolicy

        // Set default headers
        configuration.defaultHeaders.forEach { key, value in
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }

        // Set endpoint-specific headers (overrides defaults)
        endpoint.headers?.forEach { key, value in
            urlRequest.setValue(value, forHTTPHeaderField: key)
        }

        // Perform network request
        do {
            let (data, response) = try await urlSession.data(for: urlRequest)

            // Validate HTTP response
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError.invalidResponse
            }

            try validateHTTPResponse(httpResponse)

            // Decode response
            let decodedObject = try JSONDecoder().decode(T.self, from: data)

            // Save to cache
            await cacheManager.saveObject(decodedObject, forKey: endpoint)
            return decodedObject

        } catch let apiError as APIError {
            throw apiError
        } catch let decodingError as DecodingError {
            throw .decodingError(decodingError)
        } catch {
            throw .networkError(error)
        }
    }

    /// Clears all cached responses
    public func clearCache() async {
        await cacheManager.clear()
    }

    /// Removes a specific cached response
    public func removeCachedResponse(for endpoint: Cache.Key) async {
        await cacheManager.removeObject(forKey: endpoint)
    }
}

// MARK: - Private Helpers

private extension NetworkManager {

    /// Validates the http response and throws the relevant error when needed.
    func validateHTTPResponse(_ response: HTTPURLResponse) throws(APIError) {
        switch response.statusCode {
        case 200...299:
            return  // Success

        case 429:
            let retryAfter = response.value(forHTTPHeaderField: "Retry-After")
                .flatMap { TimeInterval($0) }
            throw .rateLimited(retryAfter: retryAfter)

        case 403:
            // GitHub sometimes uses 403 for rate limiting
            let retryAfter = response.value(forHTTPHeaderField: "X-RateLimit-Reset")
                .flatMap { TimeInterval($0) }
                .map { $0 - Date().timeIntervalSince1970 }
            throw .rateLimited(retryAfter: retryAfter)

        case 400...499:
            throw .clientError(statusCode: response.statusCode)

        case 500...599:
            throw .serverError(statusCode: response.statusCode)

        default:
            throw .invalidResponse
        }
    }
}
