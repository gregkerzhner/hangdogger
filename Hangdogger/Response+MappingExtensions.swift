//
//  Response+MappingExtensions.swift
//  Hangdogger
//
//  Created by Greg Kerzhner on 9/27/16.
//  Copyright © 2016 Hangdog. All rights reserved.
//

import Foundation
import Moya
import RealmSwift
import ObjectMapper

extension Response {

    /// Maps data received from the signal into an object which implements the Mappable protocol.
    /// If the conversion fails, the signal errors.
    func mapObjectWithResponse<T: FetcherResponse>(_ type: T.Type) throws -> T {
        guard let object = Mapper<T>().map(JSONObject: try mapJSON()) else {
            throw Error.jsonMapping(self)
        }

        return object
    }
}
