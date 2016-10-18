//
//  ObjectFetcherTests.swift
//  Hangdogger
//
//  Created by Greg Kerzhner on 10/2/16.
//  Copyright © 2016 Hangdog. All rights reserved.
//

import Quick
import Nimble
import Swinject
import Moya
import ReactiveSwift

@testable import Hangdogger
class FecosystemsObjectFetcherTests: QuickSpec {

    override func spec() {
        it("Fetches objects using an object request") {
            let backend = ReactiveCocoaMoyaProvider<HangdoggerBackend>(stubClosure: MoyaProvider.ImmediatelyStub)
            let fetcher = FecosystemObjectFetcher(backend: backend, params: nil)
            var result: FecosystemsResult?
            fetcher.fetch(FecosystemsResult.self).start { (event) -> Void in
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

            expect(result?.fecosystems.count).toEventually(equal(2))
        }

        it("Handles general errors") {
            let backend = ReactiveCocoaMoyaProvider<HangdoggerBackend>(endpointClosure: { target in
                let url = target.baseURL.appendingPathComponent(target.path).absoluteString
                let error = NSError(domain: "fo", code: 12, userInfo: nil)
                return Endpoint(URL: url, sampleResponseClosure: {.networkError(error)}, method: target.method, parameters: target.parameters)
                }, stubClosure: MoyaProvider.ImmediatelyStub)
            let fetcher = FecosystemObjectFetcher(backend: backend)

            var domain: String?

            fetcher.fetch(FecosystemsResult.self).start { (event) -> Void in
                switch event {
                case .value(let response):
                    break
                case .failed(let err):
                    switch err {
                    case .underlying(let underlying):
                        domain = (underlying as NSError).domain
                    default:
                        break
                    }
                default:
                    break
                }
            }

            expect(domain).toEventually(equal("fo"))
        }

        it("Handles network errors") {
            let backend = ReactiveCocoaMoyaProvider<HangdoggerBackend>(endpointClosure: { target in
                let url = target.baseURL.appendingPathComponent(target.path).absoluteString

                let json = ["error": "OHMYGERRRD"]
                let data = try! JSONSerialization.data(withJSONObject: json, options: .prettyPrinted)

                let response = EndpointSampleResponse.networkResponse(404, data)

                return Endpoint(URL: url, sampleResponseClosure: {response}, method: target.method, parameters: target.parameters)
                }, stubClosure: MoyaProvider.ImmediatelyStub)
            let fetcher = FecosystemObjectFetcher(backend: backend)


            var response: FetchErrorResponse?
            fetcher.fetch(FecosystemsResult.self).start { (event) -> Void in
                switch event {
                case .value(let response):
                    break
                case .failed(let err):
                    switch err {
                    case .statusCode(let res):
                        response = res
                    default:
                        break
                    }
                default:
                    break
                }
            }


            expect(response?.statusCode).toEventually(equal(404))
            expect(response?.description).toEventually(equal("OHMYGERRRD"))
        }

        it("Can handle malformed network responses") {
            let backend = ReactiveCocoaMoyaProvider<HangdoggerBackend>(endpointClosure: { target in
                let url = target.baseURL.appendingPathComponent(target.path).absoluteString
                let data = "Swefwefef".data(using: String.Encoding.utf8)
                let response = EndpointSampleResponse.networkResponse(404, data!)

                return Endpoint(URL: url, sampleResponseClosure: {response}, method: target.method, parameters: target.parameters)
                }, stubClosure: MoyaProvider.ImmediatelyStub)
            let fetcher = FecosystemObjectFetcher(backend: backend)


            var response: FetchErrorResponse?
            fetcher.fetch(FecosystemsResult.self).start { (event) -> Void in
                switch event {
                case .value(let response):
                    break
                case .failed(let err):
                    switch err {
                    case .statusCode(let res):
                        response = res
                    default:
                        break
                    }
                default:
                    break
                }
            }


            expect(response?.statusCode).toEventually(equal(404))
        }
    }
}
