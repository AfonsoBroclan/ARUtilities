//
//  Endpoint.swift
//  ARUtilities
//
//  Created by Afonso Rosa on 27/01/2026.
//

import Foundation

// MARK: - HTTP Method

public enum HTTPMethod: String, Sendable {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case delete = "DELETE"
    case patch = "PATCH"
}

// MARK: - Endpoint

public protocol Endpoint: Hashable & Sendable {
    var body: Data? { get }
    var headers: [String: String]? { get }
    var method: HTTPMethod { get }
    var path: String { get }
}

// Default Implementation
public extension Endpoint {
    var method: HTTPMethod { .get }
    var body: Data? { nil }
    var headers: [String: String]? { nil }
}
