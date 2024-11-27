//
//  AssetGroup.swift
//  Ducascopy
//
//  Created by Vitali Kurlovich on 14.11.24.
//

public struct AssetGroup: Decodable {
    public let id: String
    public let parent: String?

    public let title: String
    public let instruments: [String]?
}
