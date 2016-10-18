//
//  ObjectSyncer.swift
//  Hangdogger
//
//  Created by Greg Kerzhner on 9/18/16.
//  Copyright © 2016 Hangdog. All rights reserved.
//

import Foundation
import ReactiveSwift
import RealmSwift
import Swinject
import Realm
import ObjectMapper

protocol ObjectSyncer {
    func sync<T: BaseResult>(_ resultType: T.Type, fetcher: ObjectFetcher) -> SignalProducer<T, SyncError>
}

enum SyncError: Error {
    case fetchingError(FetchError)
    case saveError(Error)
}

class ObjectSyncerImpl: ObjectSyncer {

    fileprivate let objectSaver: ObjectSaver

    init(objectSaver: ObjectSaver) {
        self.objectSaver = objectSaver
    }

    func sync<T: BaseResult>(_ resultType: T.Type, fetcher: ObjectFetcher) -> SignalProducer<T, SyncError> {
        return fetcher.fetch(resultType).mapError { error -> SyncError in
            return SyncError.fetchingError(error)
        }.saveOne(objectSaver)
    }
}

extension SignalProducerProtocol where Value: Mappable, Error == SyncError {
    func saveOne(_ objectSaver: ObjectSaver) -> SignalProducer<Value, SyncError> {
        return producer.flatMap(.latest) { value -> SignalProducer<Value, SyncError> in
            let val = value as! Object

            do {
                try objectSaver.saveOne(val)
                return SignalProducer(value: value)
            } catch {
                let error = SyncError.saveError(error)
                return SignalProducer(error: error)
            }
        }
    }

}

