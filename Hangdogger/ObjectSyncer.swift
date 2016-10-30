//
//  ObjectSyncer.swift
//  Hangdogger
//
//  Created by Greg Kerzhner on 9/18/16.
//  Copyright © 2016 Hangdog. All rights reserved.
//

import Foundation
import ReactiveSwift
import RealmSwift
import Swinject
import Realm
import ObjectMapper

enum SyncError: Error {
    case fetchingError(FetchError)
    case saveError(Error)
}

