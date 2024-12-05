import DataProvider
import Foundation
import HTTPTypes
import OSLog

public
struct InstrumentsCollectionProvider<RequestProvider: HTTPRequestProvider & Sendable>: DataProvider {
    public typealias Result = InstrumentsCollection
    public typealias ProviderError = DataProviderError

    public let requestProvider: RequestProvider
    public let sessionProvider: URLSessionProvider

    public init(_ requestProvider: RequestProvider, sessionProvider: URLSessionProvider) {
        self.requestProvider = requestProvider
        self.sessionProvider = sessionProvider
    }

    public func fetch() async throws(ProviderError) -> Result {
        let dataProvider = sessionProvider.map { data, _ -> Data in
            data.dropFirst("jsonp(".count).dropLast(")".count)
        }.decode(InstrumentsCollection.self)

        let request = requestProvider.request()

        return try await dataProvider.fetch(request)
    }
}
