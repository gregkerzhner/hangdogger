//
//  NewPooViewModel.swift
//  Hangdogger
//
//  Created by Greg Kerzhner on 9/13/16.
//  Copyright © 2016 Hangdog. All rights reserved.
//


import UIKit
import ReactiveSwift
import Moya
import ObjectMapper
import RealmSwift
import Swinject
import SwinjectStoryboard

protocol NewPooViewModel {
    func bootstrap()
}

class NewPooViewModelImp: NewPooViewModel {
    fileprivate let syncer: ObjectSyncer
    init(syncer: ObjectSyncer) {
        self.syncer = syncer
    }

    func bootstrap() {
        let realm = SwinjectStoryboard.defaultContainer.resolve(Realm)!

        let result = realm.objects(FecosystemsResult.self)
        let fcs = realm.objects(Fecosystem.self)

        let params: [String: Any]? = [String: Any]()
        let fetcher = SwinjectStoryboard.defaultContainer.resolve(ObjectFetcher.self, name: "FecosystemsObjectFetcher", argument: params)!

        self.syncer.sync(FecosystemsResult.self, fetcher: fetcher).start { (event) -> Void in
            switch event {
            case .value(let response):
               break
            case .failed(let error):
                
                break
            default:
                break
            }
        }
    }
}
