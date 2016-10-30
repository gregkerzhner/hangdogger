//
//  SyncableObject.swift
//  Hangdogger
//
//  Created by Greg Kerzhner on 10/30/16.
//  Copyright © 2016 Hangdog. All rights reserved.
//

import Foundation

protocol SyncableObject {
    var revision: Int {get set}
    //if the object is changed locally
    var dirty: Bool {get set}
    var id: Int {get set}
}
