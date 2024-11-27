import DataProvider
import Foundation
import HTTPTypes

public
struct InstrumentsCollectionProvider<RequestProvider: HTTPRequestProvider & Sendable>: DataProvider {
    public typealias Result = InstrumentsCollection
    public typealias ProviderError = DataProviderError

    public let requestProvider: RequestProvider
    public let urlSession: URLSession

    public init(_ requestProvider: RequestProvider, urlSession: URLSession = .shared) {
        self.requestProvider = requestProvider
        self.urlSession = urlSession
    }

    public func fetch() async throws(ProviderError) -> Result {
        let sessionProvider = URLSessionProvider(urlSession: urlSession)

        let dataProvider = sessionProvider.map { data, _ -> Data in
            data.dropFirst("jsonp(".count).dropLast(")".count)
        }.decode(InstrumentsCollection.self)

        let request = requestProvider.request()

        return try await dataProvider.fetch(request)
    }
}
