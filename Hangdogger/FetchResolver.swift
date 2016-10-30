//
//  FetchResolver.swift
//  Hangdogger
//
//  Created by Greg Kerzhner on 10/30/16.
//  Copyright © 2016 Hangdog. All rights reserved.
//

import Foundation
import ReactiveSwift
import Result

protocol FetchResolver {
    //If doesn't exist, just add it. If does exist, then check if its dirty.  If not dirty, just replace.  if is dirty, then need conflict resolution
    func resolve(querier: SyncerQuerier, response: FetcherResponse) -> SignalProducer<ResolverResponse, NoError>
}

protocol ResolutionStrategy {
    func resolve(client: SyncableObject, server: SyncableObject) -> SignalProducer<SyncableObject, NoError>
}

class ServerWinsResolutionStragy: ResolutionStrategy {
    func resolve(client: SyncableObject, server: SyncableObject) -> SignalProducer<SyncableObject, NoError> {
        return SignalProducer<SyncableObject, NoError>(value: server)
    }
}

protocol ResolverResponse {
    var syncableObjects: [SyncableObject] {get}
}

struct ResolverResponseImpl: ResolverResponse {
    let syncableObjects: [SyncableObject]
}

class FetchResolverImpl: FetchResolver {
    private let resolutionStrategy: ResolutionStrategy

    init(resolutionStrategy: ResolutionStrategy) {
        self.resolutionStrategy = resolutionStrategy
    }

    func resolve(querier: SyncerQuerier, response: FetcherResponse) -> SignalProducer<ResolverResponse, NoError> {
        let oldObjects = querier.objects
        let newObjects = response.syncableObjects

        var signals = [SignalProducer<SyncableObject, NoError>]()

        for object in newObjects {
            if let conflict = oldObjects.first(where: { (obj: SyncableObject) -> Bool in
                return obj.dirty && obj.id == object.id
            }){
                signals.append(self.resolutionStrategy.resolve(client: conflict, server: object))
            }
            else {
                signals.append(SignalProducer<SyncableObject, NoError>(value: object))
            }
        }

        return SignalProducer.combineLatest(signals).flatMap(FlattenStrategy.latest) { (objects: [SyncableObject]) -> SignalProducer<ResolverResponse, NoError> in
            for var obj in objects {
                obj.dirty = false
            }
            let response = ResolverResponseImpl(syncableObjects: objects)
            return SignalProducer(value: response)
        }
    }
}
