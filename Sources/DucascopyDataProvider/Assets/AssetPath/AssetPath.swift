//
//  AssetPath.swift
//  Ducascopy
//
//  Created by Vitali Kurlovich on 15.11.24.
//

import Foundation

public
struct AssetPath: Hashable, Sendable {
    public let path: [String]
    public let query: AssetPathQuery

    public init(path: [String], query: AssetPathQuery = .empty) {
        precondition(!path.contains(where: { value in value.isEmpty }))

        self.path = path
        self.query = query
    }
}

public
extension AssetPath {
    static let zero = AssetPath(path: [])
}

public
extension AssetPath {
    @inlinable var startIndex: Int {
        path.startIndex
    }

    @inlinable var endIndex: Int {
        path.endIndex
    }
}

public
extension AssetPath {
    func append(_ pathComponent: String) -> AssetPath {
        precondition(!pathComponent.isEmpty)

        var path = self.path
        path.append(pathComponent)

        return .init(path: path)
    }

    func setQuery(_ query: AssetPathQuery) -> AssetPath {
        AssetPath(path: path, query: query)
    }
}

public
extension AssetPath {
    subscript(_ range: Range<Int>) -> Self {
        let startIndex = path.index(path.startIndex, offsetBy: range.lowerBound)
        let endIndex = path.index(path.startIndex, offsetBy: range.upperBound)

        let subpath = path[startIndex ..< endIndex]

        return .init(subpath)
    }
}

extension AssetPath: CustomStringConvertible {
    public var description: String {
        path.joined(separator: "/")
    }
}

public
extension AssetPath {
    func dropLast() -> Self {
        let path = path.dropLast()
        return .init(path)
    }
}

public
extension AssetPath {
    var last: String? {
        path.last
    }
}

public
extension AssetPath {
    var count: Int {
        path.count
    }

    var isEmpty: Bool {
        path.isEmpty
    }
}

extension AssetPath: Comparable {
    public static func < (lhs: AssetPath, rhs: AssetPath) -> Bool {
        for folder in zip(lhs.path, rhs.path) {
            if folder.0 < folder.1 {
                return true
            } else if folder.0 > folder.1 {
                return false
            }
        }

        return lhs.count < rhs.count
    }
}

public
extension AssetPath {
    init<S: Sequence>(_ path: S, query: AssetPathQuery = .empty) where S.Element: StringProtocol {
        self.init(path: path.map { String($0) }, query: query)
    }
}
