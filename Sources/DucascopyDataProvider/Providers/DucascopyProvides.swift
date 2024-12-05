//
//  DucascopyProvides.swift
//  DucascopyDataProvider
//
//  Created by Vitali Kurlovich on 27.11.24.
//

import DataProvider
import Foundation
import HTTPTypes
import OSLog

public
enum DucascopyProvides: Sendable {}

public
extension DucascopyProvides {
    typealias InstrumentsProvider = InstrumentsCollectionProvider<URLRequestProvider>

    static var instrumentsCollectionProvider: InstrumentsProvider {
        InstrumentsProvider(.init(url: .ducascopyURL), sessionProvider: instrumentsSessionProvider)
    }

    typealias QuotesProvider = CachedQuotesProvider<FileCacheStorage>

    static var ticksProvider: TicksProvider<QuotesProvider> {
        TicksProvider(quotesProvider)
    }

    static var candlesProvider: CandlesProvider<QuotesProvider> {
        CandlesProvider(quotesProvider)
    }
}

private
extension DucascopyProvides {
    static var instrumentsSessionProvider: URLSessionProvider {
        let logger = Logger(subsystem: "InstrumentsSessionProvider", category: "Network")
        return URLSessionProvider(logger: logger)
    }

    static var quotesSessionProvider: URLSessionProvider {
        let logger = Logger(subsystem: "QuotesSessionProvider", category: "Network")
        return URLSessionProvider(logger: logger)
    }

    static var quotesProvider: QuotesProvider {
        .init(sessionProvider: quotesSessionProvider, cacheStorage: quotesCacheStorage)
    }
}

private
extension DucascopyProvides {
    static var quotesCacheStorage: FileCacheStorage {
        FileCacheStorage(cachePath: "History/Quotes")
    }
}

private extension URL {
    static var ducascopyURL: URL {
        URL(string: "https://freeserv.dukascopy.com/2.0/index.php?path=common%2Finstruments&json")!
    }
}
