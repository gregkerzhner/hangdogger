//
//  CacheManager.swift
//  Hangdogger
//
//  Created by Greg Kerzhner on 10/12/16.
//  Copyright © 2016 Hangdog. All rights reserved.
//

import Foundation
import RealmSwift
import ReactiveSwift
import Result

protocol CacheManager {
    func cachedResponseOfType<T: BaseResult>(type: T.Type, url: String) -> T?

    func reactiveCachedResponseOfType<T: BaseResult>(type: T.Type, url: String) -> SignalProducer<T, NoError>
}

class CacheManagerImpl: CacheManager {
    private let realm: Realm
    private let timeout: Double
    init(realm: Realm, timeout: Double) {
        self.realm = realm
        self.timeout = timeout
    }

    func cachedResponseOfType<T: BaseResult>(type: T.Type, url: String) -> T? {
        //query cache based on timeout parameter
        let date = Date().addingTimeInterval(self.timeout * -1.0)
        return realm.objects(type).filter("url == %@ AND createdAt >= %@", url, date).sorted(byProperty: "createdAt").first
    }

    func reactiveCachedResponseOfType<T: BaseResult>(type: T.Type, url: String) -> SignalProducer<T, NoError> {
        return SignalProducer<T, NoError> { observer, disposable in
            if let cachedResult = self.cachedResponseOfType(type: type, url: url) {
                observer.send(value: cachedResult)
            }

            observer.sendCompleted()
        }
    }
}
