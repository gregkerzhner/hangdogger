//
//  FecosystemsObjectFetcher.swift
//  Hangdogger
//
//  Created by Greg Kerzhner on 10/7/16.
//  Copyright © 2016 Hangdog. All rights reserved.
//

import Foundation
import ReactiveSwift
import RealmSwift
import Moya
import ObjectMapper

class FecosystemObjectFetcher: Fetcher {
    fileprivate let backend: ReactiveCocoaMoyaProvider<HangdoggerBackend>
    fileprivate let params: [String: Any]?

    init(backend: ReactiveCocoaMoyaProvider<HangdoggerBackend>, params: [String: Any]? = nil) {
        self.backend = backend
        self.params = params
    }

    //test that this calls object request with the right parameters
    func fetch(params: [String: Any]?) -> SignalProducer<FetcherResponse, FetchError> {
        return self.backend.objectRequest(.fecosystems, resultType: FecosystemsResult.self, errorDescriptionType: FecosystemsErrorResponse.self)
    }
}
