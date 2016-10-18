//
//  ObjectProvider.swift
//  Hangdogger
//
//  Created by Greg Kerzhner on 10/9/16.
//  Copyright © 2016 Hangdog. All rights reserved.
//

import Foundation
import ReactiveSwift
import Result

protocol ObjectProvider {
    func provide<T: BaseResult>(_ resultType: T.Type, fetcher: ObjectFetcher)  -> SignalProducer<T, SyncError>
}

class CachedThenNonCachedObjectProvider: ObjectProvider {
    private let syncer: ObjectSyncer
    private let cacheManager: CacheManager
    init(syncer: ObjectSyncer, cacheManager: CacheManager) {
        self.syncer = syncer
        self.cacheManager = cacheManager
    }

    func provide<T: BaseResult>(_ resultType: T.Type, fetcher: ObjectFetcher)  -> SignalProducer<T, SyncError>{
        let cachedSignal: SignalProducer<T, SyncError> = self.cacheManager.reactiveCachedResponseOfType(type: resultType, url: fetcher.url.absoluteString).promoteErrors(SyncError.self)
        let syncSignal: SignalProducer<T, SyncError> = self.syncer.sync(resultType, fetcher: fetcher)

        return cachedSignal.concat(syncSignal)
    }
}
