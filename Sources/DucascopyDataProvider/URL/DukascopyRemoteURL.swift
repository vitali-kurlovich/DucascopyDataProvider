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

public
struct DukascopyRemoteURL {
    private let baseUrl: String
    private let infoUrl: String

    public
    init(_ baseUrl: String = "https://datafeed.dukascopy.com/datafeed", infoUrl: String = "https://freeserv.dukascopy.com/2.0") {
        self.baseUrl = baseUrl
        self.infoUrl = infoUrl
    }
}

public
extension DukascopyRemoteURL {
    func quotes(format: Format, for filename: String, date: Date) -> (url: URL, info: ResolvedFilePath) {
        let comps = calendar.dateComponents([.year, .month, .day, .hour], from: date)

        return quotes(format: format, for: filename, year: comps.year!, month: comps.month!, day: comps.day!, hour: comps.hour!)
    }
}

public
extension DukascopyRemoteURL {
    func quotes(format: Format, for filename: String, range: DateInterval) -> [(url: URL, info: ResolvedFilePath)] {
        precondition(!filename.isEmpty, "currency can't be empty")

        let lowerComps = calendar.dateComponents([.year, .month, .day, .hour], from: range.start)
        let upperComps = calendar.dateComponents([.year, .month, .day, .hour], from: range.end)

        let lower = calendar.date(from: lowerComps)!
        let upper = calendar.date(from: upperComps)!

        var urls = [(url: URL, info: ResolvedFilePath)]()

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
    func quotes(format: Format, for filename: String, year: Int, month: Int, day: Int, hour: Int = 0) -> (url: URL, info: ResolvedFilePath) {
        let pathResolver = DukascopyFilePathResolver()
        let path = pathResolver.quotes(format: format, for: filename, year: year, month: month, day: day, hour: hour)
        let baseUrl = "\(baseUrl)\(path.basePath)"
        let url = URL(string: baseUrl)!

        return (url: url, info: path)
    }
}

private let calendar: Calendar = {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone.gmt
    return calendar
}()
