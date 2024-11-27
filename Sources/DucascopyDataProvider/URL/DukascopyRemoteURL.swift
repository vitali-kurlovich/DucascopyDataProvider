//
//  DukascopyRemoteURL.swift
//  DucascopyDataProvider
//
//  Created by Vitali Kurlovich on 27.11.24.
//

import DukascopyModel
import Foundation

/*
 https://datafeed.dukascopy.com/datafeed/ACFREUR/2020/03/05/BID_candles_min_1.bi5
 https://datafeed.dukascopy.com/datafeed/ACFREUR/2020/03/18/09h_ticks.bi5
 */

public enum Format: Hashable, Sendable {
    case ticks
    case candles(PriceType)
}

struct DukascopyRemoteURL {
    public
    enum FactoryError: Error {
        case invalidDateRange
    }

    private let baseUrl: String
    private let infoUrl: String

    public
    init(_ baseUrl: String = "https://datafeed.dukascopy.com/datafeed", infoUrl: String = "https://freeserv.dukascopy.com/2.0") {
        self.baseUrl = baseUrl
        self.infoUrl = infoUrl
    }
}

extension DukascopyRemoteURL {
    func quotes(format: Format, for filename: String, date: Date) -> (url: URL, range: DateInterval, file: String, dir: String) {
        let comps = calendar.dateComponents([.year, .month, .day, .hour], from: date)

        return quotes(format: format, for: filename, year: comps.year!, month: comps.month!, day: comps.day!, hour: comps.hour!)
    }
}

extension DukascopyRemoteURL {
    func quotes(format: Format, for filename: String, range: DateInterval) -> [(url: URL, range: DateInterval, file: String, dir: String)] {
        precondition(!filename.isEmpty, "currency can't be empty")

        let lowerComps = calendar.dateComponents([.year, .month, .day, .hour], from: range.start)
        let upperComps = calendar.dateComponents([.year, .month, .day, .hour], from: range.end)

        let lower = calendar.date(from: lowerComps)!
        let upper = calendar.date(from: upperComps)!

        var urls = [(url: URL, range: DateInterval, file: String, dir: String)]()

        var current = lower

        switch format {
        case .ticks:
            let quotes = quotes(format: format, for: filename, date: current)
            urls.append(quotes)

        case .candles:
            let quotes = quotes(format: format, for: filename, date: current)
            urls.append(quotes)
        }

        switch format {
        case .ticks:
            let hour = DateComponents(hour: 1)
            while let next = calendar.date(byAdding: hour, to: current), next < upper {
                current = next

                let quotes = quotes(format: format, for: filename, date: current)
                urls.append(quotes)
            }
        case .candles:
            let day = DateComponents(day: 1)
            while let next = calendar.date(byAdding: day, to: current), next < upper {
                current = next

                let quotes = quotes(format: format, for: filename, date: current)
                urls.append(quotes)
            }
        }

        return urls
    }
}

private
extension DukascopyRemoteURL {
    func quotes(format: Format, for filename: String, year: Int, month: Int, day: Int, hour: Int = 0) -> (url: URL, range: DateInterval, file: String, dir: String) {
        let filename = filename.uppercased()

        var comps = DateComponents()
        comps.year = year
        comps.day = day
        comps.month = month

        let lowerDate: Date
        let upperDate: Date

        let file_name: String

        let file_dir = String(format: "\(filename)/%d/%02d/%02d/", year, month - 1, day)

        switch format {
        case .ticks:

            file_name = String(format: "%02dh_ticks.bi5", hour)

            comps.hour = hour

            lowerDate = calendar.date(from: comps)!

            let hour = DateComponents(hour: 1)
            upperDate = calendar.date(byAdding: hour, to: lowerDate)!

        case let .candles(type):

            switch type {
            case .ask:
                file_name = "ASK_candles_min_1.bi5"

            case .bid:
                file_name = "BID_candles_min_1.bi5"
            }

            lowerDate = calendar.date(from: comps)!

            let day = DateComponents(day: 1)
            upperDate = calendar.date(byAdding: day, to: lowerDate)!
        }

        let baseUrl = "\(baseUrl)/\(file_dir)\(file_name)"
        let url = URL(string: baseUrl)!

        let range = DateInterval(start: lowerDate, end: upperDate)

        return (url: url, range: range, file: file_name, dir: file_dir)
    }
}

private let calendar: Calendar = {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone.gmt
    return calendar
}()
