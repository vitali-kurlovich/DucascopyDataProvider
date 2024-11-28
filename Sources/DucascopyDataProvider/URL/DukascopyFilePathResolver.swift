//
//  DukascopyFilePathResolver.swift
//  DucascopyDataProvider
//
//  Created by Vitali Kurlovich on 28.11.24.
//

import Foundation

public
struct ResolvedFilePath: Hashable, Sendable {
    let basePath: String
    let file: String
    let dir: String
    let range: DateInterval
}

public
struct DukascopyFilePathResolver: Hashable, Sendable {
    public init() {}
}

public
extension DukascopyFilePathResolver {
    func quotes(format: Format, for filename: String, date: Date) -> ResolvedFilePath {
        let comps = calendar.dateComponents([.year, .month, .day, .hour], from: date)
        return quotes(format: format, for: filename, year: comps.year!, month: comps.month!, day: comps.day!, hour: comps.hour!)
    }
}

public
extension DukascopyFilePathResolver {
    func quotes(format: Format, for filename: String, range: DateInterval) -> [ResolvedFilePath] {
        precondition(!filename.isEmpty, "currency can't be empty")

        let lowerComps = calendar.dateComponents([.year, .month, .day, .hour], from: range.start)
        let upperComps = calendar.dateComponents([.year, .month, .day, .hour], from: range.end)

        let lower = calendar.date(from: lowerComps)!
        let upper = calendar.date(from: upperComps)!

        var filePaths: [ResolvedFilePath] = []

        var current = lower

        switch format {
        case .ticks:
            let quotes = quotes(format: format, for: filename, date: current)
            filePaths.append(quotes)

        case .candles:
            let quotes = quotes(format: format, for: filename, date: current)
            filePaths.append(quotes)
        }

        switch format {
        case .ticks:
            let hour = DateComponents(hour: 1)
            while let next = calendar.date(byAdding: hour, to: current), next < upper {
                current = next

                let quotes = quotes(format: format, for: filename, date: current)
                filePaths.append(quotes)
            }
        case .candles:
            let day = DateComponents(day: 1)
            while let next = calendar.date(byAdding: day, to: current), next < upper {
                current = next

                let quotes = quotes(format: format, for: filename, date: current)
                filePaths.append(quotes)
            }
        }

        return filePaths
    }
}

public
extension DukascopyFilePathResolver {
    func quotes(format: Format, for filename: String, year: Int, month: Int, day: Int, hour: Int = 0) -> ResolvedFilePath {
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

        let basePath = "/\(file_dir)\(file_name)"
        let range = DateInterval(start: lowerDate, end: upperDate)

        return ResolvedFilePath(basePath: basePath, file: file_name, dir: file_dir, range: range)
    }
}

private let calendar: Calendar = {
    var calendar = Calendar(identifier: .gregorian)
    calendar.timeZone = TimeZone.gmt
    return calendar
}()
