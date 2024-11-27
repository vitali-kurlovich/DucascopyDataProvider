//
//  InstrumetInfo.swift
//  Ducascopy
//
//  Created by Vitali Kurlovich on 25.11.24.
//

import Foundation

public struct InstrumetInfo: Hashable, Sendable {
    public let title: String
    public let name: String
    public let description: String

    public let currency: InstrumetCurrency
    public let pipValue: Double
    public let special: Bool

    public let fileInfo: InstrumetHistoryFileInfo

    public let tags: [String]

    public let unit: String?
}

extension InstrumetInfo {
    init(_ instrumet: Instrumet) {
        let currency = InstrumetCurrency(instrumet)

        let fileInfo = InstrumetHistoryFileInfo(instrumet)

        self.init(
            title: instrumet.title,
            name: instrumet.name,
            description: instrumet.description,
            currency: currency,
            pipValue: instrumet.pipValue,
            special: instrumet.special,
            fileInfo: fileInfo,
            tags: instrumet.tag_list,
            unit: instrumet.unit
        )
    }
}

public struct InstrumetCurrency: Hashable, Sendable {
    public let base: String
    public let quote: String
}

extension InstrumetCurrency {
    init(_ instrumet: Instrumet) {
        self.init(base: instrumet.base_currency, quote: instrumet.quote_currency)
    }
}

public struct InstrumetHistoryFileInfo: Hashable, Sendable {
    public let filename: String
    public let historyDate: InstrumetHistoryDate
}

extension InstrumetHistoryFileInfo {
    init(_ instrumet: Instrumet) {
        precondition(!(instrumet.historical_filename?.isEmpty ?? true))
        let historyDate = InstrumetHistoryDate(instrumet)
        self.init(filename: instrumet.historical_filename ?? "", historyDate: historyDate)
    }
}

public struct InstrumetHistoryDate: Hashable, Sendable {
    public let start_tick: Date
    public let start_10sec: Date
    public let start_60sec: Date
    public let start_60min: Date
    public let start_day: Date
}

extension InstrumetHistoryDate {
    init(_ instrumet: Instrumet) {
        let start_tick = (TimeInterval(instrumet.history_start_tick) ?? 0) / 1000
        let start_10sec = (TimeInterval(instrumet.history_start_10sec) ?? 0) / 1000
        let start_60sec = (TimeInterval(instrumet.history_start_60sec) ?? 0) / 1000
        let start_60min = (TimeInterval(instrumet.history_start_60min) ?? 0) / 1000
        let start_day = (TimeInterval(instrumet.history_start_day) ?? 0) / 1000

        self.init(
            start_tick: Date(timeIntervalSince1970: start_tick),
            start_10sec: Date(timeIntervalSince1970: start_10sec),
            start_60sec: Date(timeIntervalSince1970: start_60sec),
            start_60min: Date(timeIntervalSince1970: start_60min),
            start_day: Date(timeIntervalSince1970: start_day)
        )
    }
}
