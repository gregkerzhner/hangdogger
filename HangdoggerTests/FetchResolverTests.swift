//
//  FetchResolverTests.swift
//  Hangdogger
//
//  Created by Greg Kerzhner on 10/30/16.
//  Copyright © 2016 Hangdog. All rights reserved.
//

import Foundation
import Quick
import Nimble
import Swinject
import ReactiveSwift
import Result
import ObjectMapper

@testable import Hangdogger

class FetchResolverTests: QuickSpec {
    override func spec() {
        class BaseMockResponse {

            init() {

            }

            required init?(map: Map) {

            }

            func mapping(map: Map) {
                
            }
        }


        class ExistingObjs: SyncerQuerier {
            var objects: [SyncableObject] {
                return [1,2,3,4].map({(value: Int) -> Fecosystem in
                    let fecosystem = Fecosystem()
                    fecosystem.id = value
                    fecosystem.revision = value

                    return fecosystem
                })
            }
            var lastRevision: Int? {
                return 14
            }
        }

        describe("Resolving") {
            var container: Container!
            beforeEach {
                container = Container()

                container.register(ResolutionStrategy.self, factory: { _ in
                    return ServerWinsResolutionStragy()
                })


                container.register(FetchResolver.self, factory: {c in
                    let strategy = c.resolve(ResolutionStrategy.self)!
                    return FetchResolverImpl(resolutionStrategy: strategy)
                })

            }

            class UpdatedObjectsResponse: BaseMockResponse,  FetcherResponse  {
                var syncableObjects: [SyncableObject] {
                    return [1,2,3,4].map({(value: Int) -> Fecosystem in
                        let fecosystem = Fecosystem()
                        fecosystem.id = value
                        fecosystem.revision = value + 10

                        return fecosystem
                    })
                }
            }

            it("Updates existing objects") {
                let resolver = container.resolve(FetchResolver.self)!

                var response: ResolverResponse?
                resolver.resolve(querier: ExistingObjs(), response: UpdatedObjectsResponse()).start({ event in
                    switch event {
                    case .value(let res):
                        response = res
                    default:
                        break
                    }
                })

                expect(response?.syncableObjects.count).toEventually(equal(4))
                let sorted = response?.syncableObjects.sorted(by: { one, two -> Bool in
                    return one.id < two.id
                })

                expect(sorted?.first?.revision).toEventually(equal(11))
                expect(sorted?.last?.revision).toEventually(equal(14))
            }

            class NewObjectsResponse: BaseMockResponse,  FetcherResponse  {
                var syncableObjects: [SyncableObject] {
                    return [1,2,3,4,5,6].map({(value: Int) -> Fecosystem in
                        let fecosystem = Fecosystem()
                        fecosystem.id = value
                        fecosystem.revision = value + 10

                        return fecosystem
                    })
                }
            }
            it("Adds new objects") {
                let resolver = container.resolve(FetchResolver.self)!

                var response: ResolverResponse?
                resolver.resolve(querier: ExistingObjs(), response: NewObjectsResponse()).start({ event in
                    switch event {
                    case .value(let res):
                        response = res
                    default:
                        break
                    }
                })

                expect(response?.syncableObjects.count).toEventually(equal(6))
                let sorted = response?.syncableObjects.sorted(by: { one, two -> Bool in
                    return one.id < two.id
                })

                expect(sorted?.first?.revision).toEventually(equal(11))
                expect(sorted?.last?.revision).toEventually(equal(16))
            }

            class TestResolutionStrategy: ResolutionStrategy {
                func resolve(client: SyncableObject, server: SyncableObject) -> SignalProducer<SyncableObject, NoError> {
                    return SignalProducer<SyncableObject, NoError>(value: client)
                }
            }

            class DirtyObjs: SyncerQuerier {
                var objects: [SyncableObject] {
                    return [1,2,3,4].map({(value: Int) -> Fecosystem in
                        let fecosystem = Fecosystem()
                        fecosystem.id = value
                        fecosystem.revision = value
                        fecosystem.dirty = true
                        return fecosystem
                    })
                }
                var lastRevision: Int? {
                    return 14
                }
            }

            it("Calls conflict resolution in case of conflict") {
                container.register(ResolutionStrategy.self, factory: { _ in
                    return TestResolutionStrategy()
                })

                let resolver = container.resolve(FetchResolver.self)!

                var response: ResolverResponse?
                resolver.resolve(querier: DirtyObjs(), response: NewObjectsResponse()).start({ event in
                    switch event {
                    case .value(let res):
                        response = res
                    default:
                        break
                    }
                })

                expect(response?.syncableObjects.count).toEventually(equal(6))
                let sorted = response?.syncableObjects.sorted(by: { one, two -> Bool in
                    return one.id < two.id
                })

                expect(sorted?.first?.revision).toEventually(equal(1))
                expect(sorted?[3].revision).toEventually(equal(4))
                expect(sorted?[4].revision).toEventually(equal(15))
                expect(sorted?.last?.revision).toEventually(equal(16))

                let dirty = response!.syncableObjects.contains(where: { (obj: SyncableObject) -> Bool in
                    return obj.dirty
                })

                expect(dirty).toEventually(beFalse())
            }

        }
    }
}
