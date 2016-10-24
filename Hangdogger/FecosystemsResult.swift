//
//  FecosystemsResult.swift
//  Hangdogger
//
//  Created by Greg Kerzhner on 9/25/16.
//  Copyright © 2016 Hangdog. All rights reserved.
//

import Foundation
import ObjectMapper
import RealmSwift

class FecosystemsResult: BaseResult, FetcherResponse {
    let fecosystems = List<Fecosystem>()
    var syncableObjects: [SyncableObject] {
        var objs = [SyncableObject]()

        fecosystems.forEach { obj in
            objs.append(obj)
        }

        return objs
    }

    dynamic var id = UUID().uuidString
    //Impl. of Mappable protocol
    required convenience init?(_ map: Map) {
        self.init()
    }


    override func mapping(map: Map) {
        super.mapping(map: map)
        fecosystems <- map["fecosystems"]
    }
}
