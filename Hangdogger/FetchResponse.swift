//
//  FetchResponse.swift
//  Hangdogger
//
//  Created by Greg Kerzhner on 10/7/16.
//  Copyright © 2016 Hangdog. All rights reserved.
//

import Foundation

public final class FetchResponse: CustomDebugStringConvertible {
    public let statusCode: Int
    public let data: Data
    public let response: URLResponse?

    public init(statusCode: Int, data: Data, response: URLResponse? = nil) {
        self.statusCode = statusCode
        self.data = data
        self.response = response
    }

    public var description: String {
        return "Status Code: \(statusCode), Data Length: \(data.count)"
    }

    public var debugDescription: String {
        return description
    }
}
