//
//  QuotesRequest.swift
//  DucascopyDataProvider
//
//  Created by Vitali Kurlovich on 30.11.24.
//

import Foundation

public struct QuotesRequest: Hashable, Sendable {
    public let format: Format
    public let filename: String
    public let range: DateInterval

    public init(format: Format, filename: String, range: DateInterval) {
        self.format = format
        self.filename = filename
        self.range = range
    }
}
