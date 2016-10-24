//
//  Realm+Testing.swift
//  Hangdogger
//
//  Created by Greg Kerzhner on 10/30/16.
//  Copyright © 2016 Hangdog. All rights reserved.
//

import Foundation
import RealmSwift

extension Realm {
    class func fresh() -> Realm {
        let random = String(Int(arc4random_uniform(123124124)))
        let config = Realm.Configuration(inMemoryIdentifier: random)
        return try! Realm(configuration: config)
    }
}
