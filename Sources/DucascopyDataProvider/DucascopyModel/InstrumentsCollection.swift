//
//  InstrumentsCollection.swift
//  Ducascopy
//
//  Created by Vitali Kurlovich on 15.11.24.
//

public struct InstrumentsCollection: Decodable, Sendable {
    public let instruments: [String: Instrumet]
    public let groups: [String: AssetGroup]
}
