//
//  DucascopyProvides.swift
//  DucascopyDataProvider
//
//  Created by Vitali Kurlovich on 27.11.24.
//

import DataProvider
import Foundation
import HTTPTypes

public
enum DucascopyProvides: Sendable {}

public
extension DucascopyProvides {
    typealias InstrumentsProvider = InstrumentsCollectionProvider<URLRequestProvider>

    static var instrumentsCollectionProvider: InstrumentsProvider {
        InstrumentsProvider(.init(url: .ducascopyURL), urlSession: URLSession.shared)
    }

    typealias QuotesProvider = CachedQuotesProvider<FileCacheStorage>

    static var quotesProvider: QuotesProvider {
        .init(urlSession: URLSession.shared, cacheStorage: quotesCacheStorage)
    }

    static var ticksProvider: TicksProvider<QuotesProvider> {
        TicksProvider(quotesProvider)
    }

    static var candlesProvider: CandlesProvider<QuotesProvider> {
        CandlesProvider(quotesProvider)
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
