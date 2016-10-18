//
//  FecosystemsError.swift
//  Hangdogger
//
//  Created by Greg Kerzhner on 10/7/16.
//  Copyright © 2016 Hangdog. All rights reserved.
//

import Foundation
import ObjectMapper
import RealmSwift

protocol FetchErrorResponse: CustomStringConvertible, Mappable {
    var statusCode: Int? {get set}
    init()
}

class BaseFetchErrorResponse: Object, FetchErrorResponse  {
    var statusCode: Int?

    required convenience init?(map: Map) {
        self.init()
    }

    func mapping(map: Map) {
        fatalError("This should be implemented by a subclass")
    }
}

class FecosystemsErrorResponse: BaseFetchErrorResponse {
    dynamic var message: String? = ""
    //Impl. of Mappable protocol
    required convenience init?(map: Map) {
        self.init()
    }


    override func mapping(map: Map) {
        message <- map["error"]
    }

    override var description: String {
        return self.message == nil ? "Something went wrong" : self.message!
    }
}
