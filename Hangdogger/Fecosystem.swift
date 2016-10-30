//
//  Fecosystem.swift
//  Hangdogger
//
//  Created by Greg Kerzhner on 9/13/16.
//  Copyright © 2016 Hangdog. All rights reserved.
//

import Foundation
import ObjectMapper
import RealmSwift
// MARK: Initializer and Properties
class Fecosystem: Object, Mappable, SyncableObject {
    dynamic var id = 0
    dynamic var name: String!
    dynamic var revision: Int = -1
    var dirty: Bool = false

    //Impl. of Mappable protocol
    required convenience init?(map: Map) {
        self.init()
    }


    func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
    }

    override static func primaryKey() -> String? {
        return "id"
    }
    
}
