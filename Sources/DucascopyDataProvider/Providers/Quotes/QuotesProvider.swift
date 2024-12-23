//
//  QuotesProvider.swift
//  DucascopyDataProvider
//
//  Created by Vitali Kurlovich on 30.11.24.
//

import DataProvider
import Foundation
import HTTPTypes
import OSLog

public
struct QuotesProvider: Sendable, ParametredDataProvider {
    public typealias Params = QuotesRequest

    public typealias Result = [Swift.Result<QuoteData, DataProviderError>]

    public typealias ProviderError = Never

    public let sessionProvider: URLSessionProvider

    let logger: Logger?
    let signposter: OSSignposter?

    public init(sessionProvider: URLSessionProvider, logger: Logger? = nil, signposter: OSSignposter? = nil) {
        self.sessionProvider = sessionProvider
        self.logger = logger
        self.signposter = signposter
    }

    public func fetch(_ params: QuotesRequest) async throws(ProviderError) -> Result {
        do {
            let state = signpostBeginRequest()
            defer {
                signpostEndRequest(state: state)
            }

            logger?.info("\(params.debugDescription)")
            let result = try await fetchGroup(params)
            logger?.debug("\(result)")
            return result
        } catch {
            logger?.error("\(error.localizedDescription)")
        }

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
                    // let sessionProvider = URLSessionProvider(urlSession: urlSession)

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

private
extension QuotesProvider {
    func signpostBeginRequest() -> OSSignpostIntervalState? {
        guard let signposter else { return nil }
        let signpostID = signposter.makeSignpostID()
        return signposter.beginInterval("Fetch quotes", id: signpostID)
    }

    func signpostEndRequest(state: OSSignpostIntervalState?) {
        guard let signposter, let state else { return }
        signposter.emitEvent("Fetch complete.")
        signposter.endInterval("Fetch quotes", state)
    }
}
