//
//  ReactiveCocoaMoyaProviderExtensions.swift
//  Hangdogger
//
//  Created by Greg Kerzhner on 9/17/16.
//  Copyright © 2016 Hangdog. All rights reserved.
//

import Foundation
import Moya
import ReactiveSwift
import ObjectMapper
import RealmSwift

extension ReactiveCocoaMoyaProvider {
    func basicRequest(token: Target) -> SignalProducer<Response, Moya.Error> {
        return self.request(token: token).retry(upTo: 1)
    }

    //test that this does the basic request, etc
    func objectRequest<T: BaseResult, U: FetchErrorResponse>(_ token: Target, resultType: T.Type, errorDescriptionType: U.Type) -> SignalProducer<T, FetchError> {
        return self.basicRequest(token: token).filterSuccessfulStatusCodes().mapObjectWithResponse(resultType).mapError({error -> FetchError in
            return self.mapError(error, errorDescriptionType: errorDescriptionType)
        })
    }

    fileprivate func mapError< U: FetchErrorResponse>(_ error: Moya.Error, errorDescriptionType: U.Type) -> FetchError {
        switch error {
        case .imageMapping(let response):
            let response = FetchResponse(statusCode: response.statusCode, data: response.data, response: response.response)
            return FetchError.imageMapping(response)
        case .jsonMapping(let response):
            let response = FetchResponse(statusCode: response.statusCode, data: response.data, response: response.response)
            return FetchError.jsonMapping(response)
        case .stringMapping(let response):
            let response = FetchResponse(statusCode: response.statusCode, data: response.data, response: response.response)
            return FetchError.stringMapping(response)
        case .statusCode(let response):
            let obj = try? response.mapJSON()
            var object: U! = Mapper<U>().map(JSONObject: obj)
            if object == nil {
                object = U()
            }
            object.statusCode = response.statusCode
            return FetchError.statusCode(object)
        case .data(let response):
            let response = FetchResponse(statusCode: response.statusCode, data: response.data, response: response.response)
            return FetchError.data(response)
        case .underlying(let error):
            return FetchError.underlying(error)
        }
    }
}

