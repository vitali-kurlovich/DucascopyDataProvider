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

public struct TicksRequest {
    public let filename: String
    public let range: Range<Date>

    public init(filename: String, range: Range<Date>) {
        self.filename = filename
        self.range = range
    }
}

public
struct TicksProvider: ParametredDataProvider {
    public typealias ProviderError = Never

    public typealias Params = TicksRequest

    public typealias Result = [Swift.Result<TicksContainer, DataProviderError>]

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
                        return .success(ticksContainer)
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
