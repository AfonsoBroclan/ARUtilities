//
//  URLSessionMock.swift
//  ARUtilities
//
//  Created by Afonso Rosa on 27/01/2026.
//

import Foundation

@testable import ARNetworking

/// Mock implementation of URLSessionProtocol for testing purposes.
final class URLSessionMock: URLSessionProtocol, @unchecked Sendable {

    // MARK: - Properties to configure the mock behaviour
    private var data: Data
    var errorToThrow: Error?
    var statusCode: Int = 200
    var headers: [String: String]?

    init<T: Encodable>(object: T) throws {
        self.data = try JSONEncoder().encode(object)
    }

    init(data: Data) {
        self.data = data
    }

    func setData<T: Encodable>(_ object: T) throws {
        self.data = try JSONEncoder().encode(object)
    }

    func setRawData(_ data: Data) {
        self.data = data
    }

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {

        if let error = errorToThrow {
            throw error
        }

        let response = HTTPURLResponse(
            url: request.url!,
            statusCode: statusCode,
            httpVersion: nil,
            headerFields: headers
        )!

        return (data, response)
    }
}
