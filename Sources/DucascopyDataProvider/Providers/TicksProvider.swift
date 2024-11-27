//
//  TicksProvider.swift
//  DucascopyDataProvider
//
//  Created by Vitali Kurlovich on 27.11.24.
//

import DataProvider
import DukascopyDecoder
import DukascopyModel
import Foundation
import HTTPTypes

public struct TicksRequest: Hashable, Sendable {
    public let filename: String
    public let range: Range<Date>
    public let pipValue: Double

    public init(filename: String, range: Range<Date>, pipValue: Double) {
        self.filename = filename
        self.range = range
        self.pipValue = pipValue
    }
}

public
extension TicksRequest {
    init(_ info: InstrumetInfo, range: Range<Date>) {
        let filename = info.fileInfo.filename
        let pipValue = info.pipValue

        self.init(filename: filename, range: range, pipValue: pipValue)
    }

    init(_ asset: Asset, range: Range<Date>) {
        self.init(asset.info, range: range)
    }
}

public
struct TicksProvider: ParametredDataProvider {
    public typealias ProviderError = Never

    public typealias Params = TicksRequest

    public typealias Result = [Swift.Result<QuoteTicksContainer, DataProviderError>]

    public let quotesProvider: QuotesProvider

    public init(_ quotesProvider: QuotesProvider) {
        self.quotesProvider = quotesProvider
    }

    public func fetch(_ params: TicksRequest) async throws(ProviderError) -> Result {
        let decoder = TicksDecoder()

        let request = QuotesRequest(format: .ticks, filename: params.filename, range: params.range)

        return await quotesProvider.map { results in

            results.map { result -> Result.Element in
                switch result {
                case let .success(quote):
                    do {
                        let ticksContainer = try decoder.decode(in: quote.range, with: quote.data)

                        let container = QuoteTicksContainer(container: ticksContainer, pipValue: params.pipValue)
                        return .success(container)
                    } catch {
                        return .failure(DataProviderError(error: error))
                    }
                case let .failure(error):
                    return .failure(error)
                }
            }

        }.fetch(request)
    }
}
