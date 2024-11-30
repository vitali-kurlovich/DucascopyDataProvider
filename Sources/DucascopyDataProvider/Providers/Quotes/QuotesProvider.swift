//
//  QuotesProvider.swift
//  DucascopyDataProvider
//
//  Created by Vitali Kurlovich on 30.11.24.
//

import DataProvider
import Foundation
import HTTPTypes

public
struct QuotesProvider: Hashable, Sendable, ParametredDataProvider {
    public typealias Params = QuotesRequest

    public typealias Result = [Swift.Result<QuoteData, DataProviderError>]

    public typealias ProviderError = Never

    public let urlSession: URLSession

    public init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }

    public func fetch(_ params: QuotesRequest) async throws(ProviderError) -> Result {
        do {
            return try await fetchGroup(params)
        } catch {}

        return []
    }
}

private
extension QuotesProvider {
    func fetchGroup(_ params: QuotesRequest) async throws -> [Swift.Result<QuoteData, DataProviderError>] {
        let remoteURL = DukascopyRemoteURL()
        let results = remoteURL.quotes(format: params.format, for: params.filename, range: params.range)

        return try await withThrowingTaskGroup(of: Result.Element.self) { group in

            for (url, info) in results {
                group.addTask {
                    let requestProvider = BaseHTTPRequestProvider(url)
                    let request = requestProvider.request()
                    let sessionProvider = URLSessionProvider(urlSession: urlSession)

                    do {
                        let data = try await sessionProvider.map { data, _ -> QuoteData in
                            QuoteData(data: data, range: info.range)
                        }.fetch(request)

                        return .success(data)
                    } catch {
                        if let dataProviderError = error as? DataProviderError {
                            return .failure(dataProviderError)
                        }

                        return .failure(DataProviderError(error: error))
                    }
                }
            }

            var storage: Result = []

            for try await (result) in group {
                storage.append(result)
            }

            return storage
        }
    }
}
