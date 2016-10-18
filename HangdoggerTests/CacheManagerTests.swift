//
//  CacheManagerTests.swift
//  Hangdogger
//
//  Created by Greg Kerzhner on 10/12/16.
//  Copyright © 2016 Hangdog. All rights reserved.
//

import Foundation

import Quick
import Nimble
import Swinject
import RealmSwift
@testable import Hangdogger

class CacheManagerTests: QuickSpec {
    override func spec() {
        var container: Container!

        beforeEach {
            container = Container()
        }

        describe("Providing results") {
            beforeEach {
                container.register(Realm.self, factory: { _ in
                    let config = Realm.Configuration(inMemoryIdentifier: "MyInMemoryRealm")
                    return try! Realm(configuration: config)
                }).inObjectScope(.container)

                container.register(CacheManager.self, factory: { container in
                    let realm = container.resolve(Realm.self)!
                    return CacheManagerImpl(realm: realm, timeout: 10)
                })


            }

            it("Returns cached responses if they exist") {
                let url = "https://okq.com"
                let response = FecosystemsResult()
                response.createdAt = Date().addingTimeInterval(-9.0)
                response.url = url
                let realm = container.resolve(Realm.self)!

                try! realm.write {
                    realm.add(response, update: true)
                }

                let cacheManager = container.resolve(CacheManager.self)!

                let cachedResponse = cacheManager.cachedResponseOfType(type: FecosystemsResult.self, url: url)

                expect(cachedResponse).toNot(beNil())
            }

            it("Does not return expired responses") {
                let url = "https://ok.com"
                let response = FecosystemsResult()
                response.createdAt = Date().addingTimeInterval(-11.0)
                response.url = url
                let realm = container.resolve(Realm.self)!

                try! realm.write {
                    realm.add(response)
                }

                let cacheManager = container.resolve(CacheManager.self)!

                let cachedResponse = cacheManager.cachedResponseOfType(type: FecosystemsResult.self, url: "https://ok.com")

                expect(cachedResponse).to(beNil())
            }

            it("Does not return responses for the wrong URL") {
                let url = "https://ok.com"
                let response = FecosystemsResult()
                response.createdAt = Date().addingTimeInterval(-8.0)
                response.url = url
                let realm = container.resolve(Realm.self)!

                try! realm.write {
                    realm.add(response)
                }

                let cacheManager = container.resolve(CacheManager.self)!

                let cachedResponse = cacheManager.cachedResponseOfType(type: FecosystemsResult.self, url: "https://okz.com")

                expect(cachedResponse).to(beNil())
            }
        }
    }
}
