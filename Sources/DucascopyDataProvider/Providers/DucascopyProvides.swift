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
enum DucascopyProvides {
    
}

public
extension DucascopyProvides {
    typealias InstrumentsProvider = InstrumentsCollectionProvider<URLRequestProvider>

    static var instrumentsCollectionProvider: InstrumentsProvider {
        InstrumentsProvider(.init(url: .ducascopyURL))
    }
}



private extension URL {
    static var ducascopyURL: URL {
        URL(string: "https://freeserv.dukascopy.com/2.0/index.php?path=common%2Finstruments&json")!
    }
}
