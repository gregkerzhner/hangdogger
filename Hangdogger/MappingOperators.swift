//
//  MappingOperators.swift
//  Hangdogger
//
//  Created by Greg Kerzhner on 9/27/16.
//  Copyright © 2016 Hangdog. All rights reserved.
//

import Foundation
import ObjectMapper
import RealmSwift
infix operator <-

/// Object of Realm's List type
public func <- <T: Mappable>(left: List<T>, right: Map) {
    var array: [T]?

    if right.mappingType == .toJSON {
        array = Array(left)
    }

    array <- right

    if right.mappingType == .fromJSON {
        if let theArray = array {
            left.append(objectsIn: theArray)
        }
    }
}
