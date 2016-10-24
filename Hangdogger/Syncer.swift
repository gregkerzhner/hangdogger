//
//  Syncer.swift
//  Hangdogger
//
//  Created by Greg Kerzhner on 10/20/16.
//  Copyright © 2016 Hangdog. All rights reserved.
//

import Foundation
import ReactiveSwift
import RealmSwift
import Moya
import ObjectMapper

protocol FetcherResponse: Mappable {
    var syncableObjects: [SyncableObject] {get}
}

protocol SyncableObject {
    var revision: Int {get set}
}

protocol Fetcher {
    func fetch(params: [String: Any]?) -> SignalProducer<FetcherResponse, FetchError>
}

class FecosystemFetcher: Fetcher {

    fileprivate let backend: ReactiveCocoaMoyaProvider<HangdoggerBackend>

    init(backend: ReactiveCocoaMoyaProvider<HangdoggerBackend>) {
        self.backend = backend
    }

    internal func fetch(params: [String : Any]?) -> SignalProducer<FetcherResponse, FetchError> {
        return self.backend.objectRequest(.fecosystems, resultType: FecosystemsResult.self, errorDescriptionType: FecosystemsErrorResponse.self)
    }
}

protocol SyncResponse {

}

protocol Syncer {
    func sync() ->  SignalProducer<SyncResponse, SyncError>
}

protocol FetchResolver {
    //If doesn't exist, just add it. If does exist, then check if its dirty.  If not dirty, just replace.  if is dirty, then need conflict resolution
    func resolve(querier: SyncerQuerier, response: FetcherResponse) -> SignalProducer<SyncResponse, SyncError>
}


class SyncerImpl {
    let querier: SyncerQuerier
    let fetcher: Fetcher
    let fetchResolver: FetchResolver

    init(querier: SyncerQuerier, fetcher: Fetcher, fetchResolver: FetchResolver) {
        self.querier = querier
        self.fetcher = fetcher
        self.fetchResolver = fetchResolver
    }

    func sync() {
        let revision = self.querier.lastRevision
        let params = ["revision": revision]

        //the fetcher is going to go to the server and return a list of objects
        let fetch = fetcher.fetch(params: params)
        fetch.mapError { error -> SyncError in
            return SyncError.fetchingError(error)
        }//the fetch resolver is going to compare this new list with the existing list
        .flatMap(.latest) { (response: FetcherResponse) -> SignalProducer<SyncResponse, SyncError> in
            return self.fetchResolver.resolve(querier: self.querier, response: response)
        }//TODO: .uploadChanges().cleanDeleted()

    }
}
