//
//  ObjectSyncerTests.swift
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
import ReactiveSwift

@testable import Hangdogger

class ObjectSyncerTests: QuickSpec {

    override func spec() {
        var syncer: ObjectSyncer!
        var container: Container!

        class DummyFetcher: ObjectFetcher {
            var url: URL {
                return URL(string: "https://google.com")!
            }
            func fetch<T : BaseResult>(_ resultType: T.Type) -> SignalProducer<T, FetchError> {
                let res = T()
                res.url = "smoothmove"
                return SignalProducer<T, FetchError>(value: res)
            }
        }

        class DummyFailFetcher: ObjectFetcher {
            var url: URL {
                return URL(string: "https://google.com")!
            }
            func fetch<T : BaseResult>(_ resultType: T.Type) -> SignalProducer<T, FetchError> {
                let error = FetchError.statusCode(FecosystemsErrorResponse())
                return SignalProducer<T, FetchError>(error: error)
            }
        }

        class DummySaver: ObjectSaver {
            var savedObject: Object?
            func saveOne(_ object: Object) throws {
                savedObject = object
            }
        }

        describe("Successes") {

            beforeEach {
                container = Container()

                container.register(ObjectFetcher.self) { (ResolverType) -> ObjectFetcher in
                    return DummyFetcher()
                }.inObjectScope(.container)

                container.register(ObjectSaver.self, factory: { _ in
                    return DummySaver()
                }).inObjectScope(.container)

                container.register(ObjectSyncer.self, factory: {_ in
                    let saver = container.resolve(ObjectSaver.self)!
                    return ObjectSyncerImpl(objectSaver: saver)
                })

                syncer = container.resolve(ObjectSyncer.self)
            }

            it("Syncs") {

                syncer.sync(FecosystemsResult.self, fetcher: container.resolve(ObjectFetcher.self)!).start()

                let saver = container.resolve(ObjectSaver.self) as! DummySaver

                expect((saver.savedObject as? FecosystemsResult)?.url).toEventually(equal("smoothmove"))
            }
        }

        describe("Failures") {
            beforeEach {
                container = Container()

                container.register(ObjectFetcher.self, factory: { _ in
                    return DummyFailFetcher()
                }).inObjectScope(.container)

                container.register(ObjectSaver.self, factory: { _ in
                    return DummySaver()
                }).inObjectScope(.container)

                container.register(ObjectSyncer.self, factory: {_ in
                    let saver = container.resolve(ObjectSaver.self)!

                    return ObjectSyncerImpl(objectSaver: saver)
                })

                syncer = container.resolve(ObjectSyncer.self)
            }

            it("Syncs") {
                var correctError = false
                syncer.sync(FecosystemsResult.self, fetcher: container.resolve(ObjectFetcher.self)!).on(failed: { error in
                    switch error {
                    case.fetchingError(let error):
                        switch error {
                        case .statusCode(_):
                            correctError = true
                        default:
                            break
                        }
                    default:
                        break
                    }
                }).start()

                expect(correctError).toEventually(beTrue())
            }
        }
    }
}
