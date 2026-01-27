//
//  URLSessionProtocol.swift
//  ARUtilities
//
//  Created by Afonso Rosa on 27/01/2026.
//

import Foundation

/// A protocol to abstract URLSession for easier testing and dependency injection.
public protocol URLSessionProtocol {
    func data(for request: URLRequest) async throws -> (Data, URLResponse)
}

// Conform URLSession to URLSessionProtocol
extension URLSession: URLSessionProtocol {}
