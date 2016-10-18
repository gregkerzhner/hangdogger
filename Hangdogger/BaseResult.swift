//
//  BaseResult.swift
//  Hangdogger
//
//  Created by Greg Kerzhner on 9/27/16.
//  Copyright © 2016 Hangdog. All rights reserved.
//

import Foundation
import Foundation
import ObjectMapper
import Realm
import RealmSwift

class BaseResult: Object, Mappable {
    dynamic var url: String? = ""
    dynamic var createdAt: Date?
    //Impl. of Mappable protocol

    public required init() {
        super.init()
    }

    required init?(map: Map) {
        super.init()
        //super.init()
    }
    
    required init(value: Any, schema: RLMSchema) {
        super.init(value: value, schema: schema)
    }
    
    required init(realm: RLMRealm, schema: RLMObjectSchema) {
        super.init(realm: realm, schema: schema)
    }

    func mapping(map: Map) {
        url <- map["url"]
    }

    override static func primaryKey() -> String? {
        return "url"
    }
}
