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
    var lastRevision: Int {get}
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
    let request: SyncerQuerierRequest
    let realm: Realm
    init(request: SyncerQuerierRequest, realm: Realm) {
        self.request = request
        self.realm = realm
    }

    var objects: [SyncableObject] {
        return Array(self.realm.objects(T.self))
    }

    var lastRevision: Int {
        return 0
    }
}

/*
class SyncerQuerierImpl: SyncerQuerier{
    let request: SyncerQuerierRequest
    let realm: Realm
    init(request: SyncerQuerierRequest, realm: Realm) {
        self.request = request
        self.realm = realm
    }

    var objects: [SyncableObject] {
        return Array(self.realm.objects(self.request.object))
        //self.realm.objects(<#T##type: T.Type##T.Type#>)
        //return [SyncableObject]()
    }

    var lastRevision: Int {
        return 0
    }
}
*/
