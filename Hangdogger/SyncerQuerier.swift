//
//  SyncerQuerier.swift
//  Hangdogger
//
//  Created by Greg Kerzhner on 10/30/16.
//  Copyright © 2016 Hangdog. All rights reserved.
//

import Foundation
import RealmSwift

protocol SyncerQuerier {
    var objects: [SyncableObject] {get}
    var lastRevision: Int? {get}
}

protocol SyncerQuerierRequest {
    var predicate: NSPredicate? {get}
    var limit: Int? {get}
}

struct SyncerQuerierRequestImpl: SyncerQuerierRequest {
    let predicate: NSPredicate?
    let limit: Int?
}

class SyncerQuerierImpl<T>: SyncerQuerier where T : SyncableObject, T: Object {
    private let request: SyncerQuerierRequest
    private let realm: Realm
    init(request: SyncerQuerierRequest, realm: Realm) {
        self.request = request
        self.realm = realm
    }

    private var objectsList: Results<T> {
        var objs = self.realm.objects(T.self)
        if let predicate = request.predicate {
            objs = objs.filter(predicate)
        }

        return objs
    }
    var objects: [SyncableObject] {
        return Array(self.objectsList)
    }

    var lastRevision: Int? {
        return self.objectsList.sorted(byProperty: "revision", ascending: false).first?.revision
    }
}
