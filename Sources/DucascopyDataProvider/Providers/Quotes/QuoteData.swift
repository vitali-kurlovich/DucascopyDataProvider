//
//  QuoteData.swift
//  DucascopyDataProvider
//
//  Created by Vitali Kurlovich on 30.11.24.
//

import Foundation

public struct QuoteData: Equatable, Sendable {
    public let data: Data
    public let range: DateInterval

    public init(data: Data, range: DateInterval) {
        self.data = data
        self.range = range
    }
}
