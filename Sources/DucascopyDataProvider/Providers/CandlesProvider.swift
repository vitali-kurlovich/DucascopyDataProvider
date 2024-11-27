//
//  CandlesProvider.swift
//  DucascopyDataProvider
//
//  Created by Vitali Kurlovich on 28.11.24.
//

import DataProvider
import DukascopyDecoder
import DukascopyModel
import Foundation
import HTTPTypes

public struct CandlesRequest: Hashable, Sendable {
    public let filename: String
    public let range: DateInterval
    public let pipValue: Double
    public let type: PriceType

    public init(filename: String, range: DateInterval, pipValue: Double, type: PriceType) {
        self.filename = filename
        self.range = range
        self.pipValue = pipValue
        self.type = type
    }
}

public
extension CandlesRequest {
    init(_ info: InstrumetInfo, range: DateInterval, type: PriceType) {
        let filename = info.fileInfo.filename
        let pipValue = info.pipValue
        self.init(filename: filename, range: range, pipValue: pipValue, type: type)
    }

    init(_ asset: Asset, range: DateInterval, type: PriceType) {
        self.init(asset.info, range: range, type: type)
    }
}

public
struct CandlesProvider: Hashable, Sendable, ParametredDataProvider {
    public typealias ProviderError = Never

    public typealias Params = CandlesRequest

    public typealias Result = [Swift.Result<QuoteCandlesContainer, DataProviderError>]

    public let quotesProvider: QuotesProvider

    public init(_ quotesProvider: QuotesProvider) {
        self.quotesProvider = quotesProvider
    }

    public func fetch(_ params: CandlesRequest) async throws(ProviderError) -> Result {
        let request = QuotesRequest(format: .candles(params.type), filename: params.filename, range: params.range)

        return await quotesProvider.map { results in
            results.map { result -> Result.Element in
                switch result {
                case let .success(quote):
                    do {
                        let decoder = CandlesDecoder()
                        let candlesContainer = try decoder.decode(in: quote.range, with: quote.data)
                        let container = QuoteCandlesContainer(container: candlesContainer, pipValue: params.pipValue, type: params.type)
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
