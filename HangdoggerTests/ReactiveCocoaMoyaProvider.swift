//
//  SignalProducerExtensionsTests.swift
//  Hangdogger
//
//  Created by Greg Kerzhner on 10/2/16.
//  Copyright © 2016 Hangdog. All rights reserved.
//

import Foundation

import Quick
import Nimble
import ReactiveSwift
import Moya
import Swinject

@testable import Hangdogger

class ReactiveCocoaMoyaProviderExtensionTests: QuickSpec {

    override func spec() {
        var provider: ReactiveCocoaMoyaProvider<HangdoggerBackend>!

        beforeEach {
            let container = Container()

            container.register(ReactiveCocoaMoyaProvider<HangdoggerBackend>.self) { _ in
                return ReactiveCocoaMoyaProvider<HangdoggerBackend>(stubClosure: MoyaProvider.ImmediatelyStub)
            }

            provider = container.resolve(ReactiveCocoaMoyaProvider<HangdoggerBackend>.self)!
        }

        it("Provides a result") {
            var result: FetcherResponse?
            provider.objectRequest(.fecosystems, resultType: FecosystemsResult.self, errorDescriptionType: FecosystemsErrorResponse.self).start { (event) -> Void in
                switch event {
                case .value(let response):
                    result = response
                case .failed(let error):
                    print("\(error)")
                    break
                default:
                    break
                }
            }

            expect(result?.syncableObjects.count).toEventually(equal(2))
        }
    }
}
