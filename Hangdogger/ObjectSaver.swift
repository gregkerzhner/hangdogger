//
//  ObjectSaver.swift
//  Hangdogger
//
//  Created by Greg Kerzhner on 9/18/16.
//  Copyright © 2016 Hangdog. All rights reserved.
//

import Foundation
import RealmSwift

protocol ObjectSaver {
    func saveOne(_ object: Object) throws
}

class ObjectSaverImpl: ObjectSaver {
    fileprivate let realm: Realm

    init(realm: Realm) {
        self.realm = realm
    }

    func saveOne(_ object: Object) throws {
        try realm.write {
            realm.add(object,update: true)
        }
    }
}
