//
//  SyncerQuerierTests.swift
//  Hangdogger
//
//  Created by Greg Kerzhner on 10/30/16.
//  Copyright © 2016 Hangdog. All rights reserved.
//

import Foundation
import Quick
import Nimble
import Swinject
import RealmSwift

@testable import Hangdogger

class SyncerQuerierTests: QuickSpec {
    override func spec() {

        class NoPredicateQuerierRequest: SyncerQuerierRequest {
            var predicate: NSPredicate? {
                return nil
            }

            var limit: Int? {
                return nil
            }
        }

        class PredicateQuerierRequest: SyncerQuerierRequest {
            var predicate: NSPredicate? {
                return NSPredicate(format: "id < %@", NSNumber(value: 4))
            }

            var limit: Int? {
                return nil
            }
        }



        describe("Syncer querier") {
            var container: Container!
            beforeEach {
                container = Container()
                container.register(Realm.self, factory: { _ in
                    return Realm.fresh()
                }).inObjectScope(.container)

                let fecosystems = [1,2,3,4].map({ (value: Int) -> Fecosystem in
                    let fecosystem = Fecosystem()
                    fecosystem.id = value
                    fecosystem.revision = value
                    return fecosystem
                })

                let realm = container.resolve(Realm.self)!
                try! realm.write {
                    realm.add(fecosystems,update: true)
                }
            }

            describe("Without predicate") {
                beforeEach {
                    container.register(SyncerQuerierRequest.self, factory: {_ in
                        return NoPredicateQuerierRequest()
                    })

                    container.register(SyncerQuerier.self, factory: {container in
                        let request = container.resolve(SyncerQuerierRequest.self)!
                        let realm = container.resolve(Realm.self)!

                        return SyncerQuerierImpl<Fecosystem>(request: request, realm: realm)
                    })
                }

                it("Returns all objects without a predicate"){
                    let querier = container.resolve(SyncerQuerier.self)!
                    expect(querier.objects.count).to(equal(4))
                }

                it("Returns a last revision") {
                    let querier = container.resolve(SyncerQuerier.self)!
                    expect(querier.lastRevision).to(equal(4))
                }
            }

            describe("With a predicate") {
                beforeEach {
                    container.register(SyncerQuerierRequest.self, factory: {_ in
                        return PredicateQuerierRequest()
                    })

                    container.register(SyncerQuerier.self, factory: {container in
                        let request = container.resolve(SyncerQuerierRequest.self)!
                        let realm = container.resolve(Realm.self)!

                        return SyncerQuerierImpl<Fecosystem>(request: request, realm: realm)
                    })
                }

                it("Filters objects by predicate"){
                    let querier = container.resolve(SyncerQuerier.self)!
                    expect(querier.objects.count).to(equal(3))
                }

                it("Returns a last revision") {
                    let querier = container.resolve(SyncerQuerier.self)!
                    expect(querier.lastRevision).to(equal(3))
                }
            }

        }
    }
}
