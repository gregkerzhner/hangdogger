//
//  SignalProducerType+ResultExtension.swift
//  Hangdogger
//
//  Created by Greg Kerzhner on 9/27/16.
//  Copyright © 2016 Hangdog. All rights reserved.
//

import Foundation
import ReactiveSwift
import Moya
import RealmSwift
import ObjectMapper
import HTTPStatusCodes

extension SignalProducerProtocol where Value == Moya.Response, Error == Moya.Error {
    /// Maps data received from the signal into an object which implements the Mappable protocol.
    /// If the conversion fails, the signal errors.
    func mapObjectWithResponse<T: BaseResult>(_ type: T.Type) -> SignalProducer<T, Error> {
        return producer.flatMap(.latest) { response -> SignalProducer<T, Error> in
            return unwrapThrowable { try
                response.mapObjectWithResponse(T.self)
            }
        }
    }
}
/// Maps throwable to SignalProducer
private func unwrapThrowable<T>(_ throwable: () throws -> T) -> SignalProducer<T, Moya.Error> {
    do {
        return SignalProducer(value: try throwable())
    } catch {
        return SignalProducer(error: error as! Moya.Error)
    }
}
