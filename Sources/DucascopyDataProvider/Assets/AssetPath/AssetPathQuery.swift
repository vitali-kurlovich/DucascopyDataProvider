//
//  AssetPathQuery.swift
//  Ducascopy
//
//  Created by Vitali Kurlovich on 17.11.24.
//

public struct AssetPathQuery: Hashable, Sendable {
    public let query: [String: String]

    public init(_ query: [String: String]) {
        precondition(!query.keys.contains(where: { key in key.isEmpty }))
        precondition(!query.values.contains(where: { value in value.isEmpty }))

        self.query = query
    }

    public var isEmpty: Bool {
        query.isEmpty
    }

    public static let empty = AssetPathQuery([:])
}
