//
//  ObjectProviderTests.swift
//  Hangdogger
//
//  Created by Greg Kerzhner on 10/15/16.
//  Copyright © 2016 Hangdog. All rights reserved.
//

import Foundation

import Quick
import Nimble
import Swinject
import Result
import ReactiveSwift

@testable import Hangdogger


class ObjectProviderTests: QuickSpec {

    override func spec() {
        var container: Container!

        describe("Cached then non cached provider") {

            class DummySyncer: ObjectSyncer {
                func sync<T : BaseResult>(_ resultType: T.Type, fetcher: ObjectFetcher) -> SignalProducer<T, SyncError> {
                    let res = T()
                    res.url = "https://foobar.com"
                    res.createdAt = Date()
                    return SignalProducer<T, SyncError>(value: res)
                }
            }

            class DummyFailSyncer: ObjectSyncer {
                func sync<T : BaseResult>(_ resultType: T.Type, fetcher: ObjectFetcher) -> SignalProducer<T, SyncError> {
                    let res = FecosystemsErrorResponse()
                    res.statusCode = 500
                    let err = SyncError.fetchingError(FetchError.statusCode(res))
                    return SignalProducer<T, SyncError>(error: err)
                }
            }
            class DummyCacheManager: CacheManager {
                func cachedResponseOfType<T : BaseResult>(type: T.Type, url: String) -> T? {
                    return nil
                }

                func reactiveCachedResponseOfType<T : BaseResult>(type: T.Type, url: String) -> SignalProducer<T, NoError> {
                    return SignalProducer<T, NoError> { observer, disposable in
                    observer.sendCompleted()
                    }
                }
            }

            class DummyValueCacheManager: CacheManager {
                func cachedResponseOfType<T : BaseResult>(type: T.Type, url: String) -> T? {
                    let t = T()
                    t.createdAt = Date().addingTimeInterval(-1.0)
                    return t
                }

                func reactiveCachedResponseOfType<T : BaseResult>(type: T.Type, url: String) -> SignalProducer<T, NoError> {
                    return SignalProducer<T, NoError> { observer, disposable in
                        observer.send(value: self.cachedResponseOfType(type: type, url: url)!)
                        observer.sendCompleted()
                    }
                }
            }

            class DummyFetcher: ObjectFetcher {
                func fetch<T: BaseResult>(_ resultType: T.Type) -> SignalProducer<T, FetchError> {
                    let value = T()
                    value.createdAt = Date()
                    return SignalProducer(value: value)
                }
                var url: URL {
                    return URL(string: "https://www.google.com")!
                }
            }


            beforeEach {
                container = Container()

                container.register(ObjectSyncer.self, factory: {_ in
                    return DummySyncer()
                })

                container.register(ObjectProvider.self, factory: {c in
                    let syncer = c.resolve(ObjectSyncer.self)!
                    let manager = c.resolve(CacheManager.self)!

                    return CachedThenNonCachedObjectProvider(syncer: syncer, cacheManager: manager)
                })


            }

            it("Returns fresh if no cached data is available") {
                var res: FecosystemsResult?

                container.register(CacheManager.self, factory: {_ in
                    return DummyCacheManager()
                })

                let provider = container.resolve(ObjectProvider.self)!
                provider.provide(FecosystemsResult.self, fetcher: DummyFetcher()).start { (event) -> Void in
                    switch event {
                    case .value(let response):
                        res = response
                    default:
                        break
                    }
                }

                expect(res?.url).toEventually(equal("https://foobar.com"))
            }

            it("Returns cached data first, then fresh data") {
                container.register(CacheManager.self, factory: {_ in
                    return DummyValueCacheManager()
                })

                let provider = container.resolve(ObjectProvider.self)!

                var res = [FecosystemsResult]()
                provider.provide(FecosystemsResult.self, fetcher: DummyFetcher()).start { (event) -> Void in
                    switch event {
                    case .value(let response):
                        res.append(response)
                    default:
                        break
                    }
                }

                expect(res.count).toEventually(equal(2))
                expect(res.first!.createdAt).to(beLessThan(res.last!.createdAt))
            }

            it("Handles failures") {
                container.register(CacheManager.self, factory: {_ in
                    return DummyValueCacheManager()
                })

                container.register(ObjectSyncer.self, factory: {_ in
                    return DummyFailSyncer()
                })

                let provider = container.resolve(ObjectProvider.self)!

                var res = [FecosystemsResult]()
                var err: SyncError?
                provider.provide(FecosystemsResult.self, fetcher: DummyFetcher()).start { (event) -> Void in
                    switch event {
                    case .value(let response):
                        res.append(response)
                    case .failed(let error):
                        err = error
                    default:
                        break
                    }
                }

                expect(res.count).toEventually(equal(1))
                expect(err).toEventuallyNot(beNil())

                var resp: FetchErrorResponse?
                switch err! {
                case .fetchingError(let error):
                    switch error {
                    case .statusCode(let response):
                        resp = response
                    default:
                        break
                    }
                default:
                    break

                }

                expect(resp?.statusCode).toEventually(equal(500))
            }
        }
    }
}
