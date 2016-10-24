//
//  ObjectFetcher.swift
//  Hangdogger
//
//  Created by Greg Kerzhner on 9/17/16.
//  Copyright © 2016 Hangdog. All rights reserved.
//

import Foundation
import ReactiveSwift

enum FetchError: Error {
    case imageMapping(FetchResponse)
    case jsonMapping(FetchResponse)
    case stringMapping(FetchResponse)
    case statusCode(FetchErrorResponse)
    case data(FetchResponse)
    case underlying(Error)
}


protocol ObjectFetcher {
    func fetch(params: [String: AnyObject]?) -> SignalProducer<FetcherResponse, FetchError>
}
