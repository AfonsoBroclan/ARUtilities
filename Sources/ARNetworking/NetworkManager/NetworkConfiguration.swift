//
//  NetworkConfiguration.swift
//  ARUtilities
//
//  Created by Afonso Rosa on 27/01/2026.
//

import Foundation

// MARK: - Errors

public enum APIError: Error, Equatable {
    case decodingError(DecodingError)
    case clientError(statusCode: Int)
    case invalidResponse
    case invalidURL
    case networkError(Error)
    case rateLimited(retryAfter: TimeInterval?)
    case serverError(statusCode: Int)

    public static func == (lhs: APIError, rhs: APIError) -> Bool{
        switch (lhs, rhs) {
        case (.decodingError(let lhsValue), .decodingError(let rhsValue)):
            return lhsValue as NSError == rhsValue as NSError
        case (.clientError(let lhsValue), .clientError(let rhsValue)):
            return lhsValue == rhsValue
        case (.invalidResponse, .invalidResponse):
            return true
        case (.invalidURL, .invalidURL):
            return true
        case (.networkError(let lhsValue), .networkError(let rhsValue)):
            return lhsValue as NSError == rhsValue as NSError
        case (.rateLimited(let lhsValue), .rateLimited(let rhsValue)):
            return lhsValue == rhsValue
        case (.serverError(let lhsValue), .serverError(let rhsValue)):
            return lhsValue == rhsValue
        default:
            return false
        }
    }
}

// MARK: - Configuration

public enum NetworkConfigurationConstants {
    public static let cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy
    public static let defaultTimeout: TimeInterval = 60 // 1 minute
}

public struct NetworkConfiguration: Sendable {
    let timeoutInterval: TimeInterval
    let cachePolicy: URLRequest.CachePolicy
    let defaultHeaders: [String: String]

    public init(
        timeoutInterval: TimeInterval = NetworkConfigurationConstants.defaultTimeout,
        cachePolicy: URLRequest.CachePolicy = NetworkConfigurationConstants.cachePolicy,
        defaultHeaders: [String: String] = [:]
    ) {
        self.timeoutInterval = timeoutInterval
        self.cachePolicy = cachePolicy
        self.defaultHeaders = defaultHeaders
    }
}
