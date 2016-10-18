//
//  SwinjectDefenitions.swift
//  Hangdogger
//
//  Created by Greg Kerzhner on 9/14/16.
//  Copyright © 2016 Hangdog. All rights reserved.
//

import Swinject
import SwinjectStoryboard
import Moya
import RealmSwift

extension SwinjectStoryboard {
    class func setup() {
        defaultContainer.register(NewPooViewModel.self) { r in
            let syncer = r.resolve(ObjectSyncer.self)
            let model = NewPooViewModelImp(syncer: syncer!)

            return model
        }

        defaultContainer.register(ObjectFetcher.self, name: "FecosystemsObjectFetcher") {(r, argument: [String: Any]?) in
            let backend = r.resolve(ReactiveCocoaMoyaProvider<HangdoggerBackend>.self)!
            return FecosystemObjectFetcher(backend: backend, params: argument)
        }

        defaultContainer.register(ObjectSaver.self) { r in
            let realm = r.resolve(Realm.self)!
            return ObjectSaverImpl(realm: realm)
        }


        defaultContainer.register(ObjectSyncer.self) { r in
            let saver = r.resolve(ObjectSaver.self)!

            return ObjectSyncerImpl(objectSaver: saver)
        }



        defaultContainer.register(ReactiveCocoaMoyaProvider<HangdoggerBackend>.self) { _ in
            return ReactiveCocoaMoyaProvider<HangdoggerBackend>()
        }

        defaultContainer.registerForStoryboard(NewPooViewController.self) { r,controller in
            controller.viewModel = r.resolve(NewPooViewModel.self)
        }


        defaultContainer.register(Realm.self) { (ResolverType) -> Realm in
                let config = Realm.Configuration(
                    // Set the new schema version. This must be greater than the previously used
                    // version (if you've never set a schema version before, the version is 0).
                    schemaVersion: 5,

                    // Set the block which will be called automatically when opening a Realm with
                    // a schema version lower than the one set above
                    migrationBlock: { migration, oldSchemaVersion in

                })
                
                // Tell Realm to use this new configuration object for the default Realm
                Realm.Configuration.defaultConfiguration = config
                return try! Realm()
        }.inObjectScope(.container)
    }
}
