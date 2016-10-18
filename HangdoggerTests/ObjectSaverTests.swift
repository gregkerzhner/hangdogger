//
//  ObjectSaverTests.swift
//  Hangdogger
//
//  Created by Greg Kerzhner on 10/5/16.
//  Copyright © 2016 Hangdog. All rights reserved.
//

import Foundation
import Quick
import Nimble
import Swinject
import RealmSwift

@testable import Hangdogger
class ObjectSaverTests: QuickSpec {

    override func spec() {
        var saver: ObjectSaver!
        var container: Container!
        beforeEach() {

            container = Container()


            container.register(Realm.self, factory: { _ in
                let config = Realm.Configuration(inMemoryIdentifier: "saverTestRealm")
                return try! Realm(configuration: config)
            }).inObjectScope(.container)

            container.register(ObjectSaver.self, factory: { _ in
                return ObjectSaverImpl(realm: container.resolve(Realm.self)!)
            })

            saver = container.resolve(ObjectSaver.self)
        }

        it("Saves an object") {
            let fecosystem = Fecosystem()
            fecosystem.name = "Woo"
            fecosystem.id = 123
            try! saver.saveOne(fecosystem)

            let fecosystems = container.resolve(Realm.self)!.objects(Fecosystem.self)

            expect(fecosystems.first?.id).to(equal(123))
        }

        it("Updates an object with a primary key") {
            let fecosystems = container.resolve(Realm.self)!.objects(FecosystemsResult.self)

            expect(fecosystems.count).to(equal(0))
            let res = FecosystemsResult()
            res.url = "https://google.com"

            try! saver.saveOne(res)

            let res2 = FecosystemsResult()
            res2.url = "https://google.com"

            try! saver.saveOne(res2)

            let fecosystems3 = container.resolve(Realm.self)!.objects(FecosystemsResult.self)

            expect(fecosystems3.count).to(equal(1))
        }
    }
}
