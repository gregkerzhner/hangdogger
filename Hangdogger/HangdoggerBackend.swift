//
//  HangdoggerBackend.swift
//  Hangdogger
//
//  Created by Greg Kerzhner on 9/13/16.
//  Copyright © 2016 Hangdog. All rights reserved.
//

import UIKit
import Moya

enum HangdoggerBackend {
    case fecosystems
    case fecosystem(id: Int)
}

extension HangdoggerBackend: TargetType {
    var baseURL: URL { return URL(string: "http://localhost:3000")! }

    var path: String {
        switch self {
            case .fecosystems:
                return "/fecosystems"
            case .fecosystem(let id):
                return "/fecosystems/\(id)"
        }
    }

    var method: Moya.Method {
        return .GET
    }

    var parameters: [String: Any]? {
        switch self {
        default:
            return nil
        }
    }

    var sampleData: Data {
        switch self {
        case .fecosystems:
            let fecosystems: [String: [[String: AnyObject]]] = ["fecosystems": [["id":100 as AnyObject, "name": "Foo" as AnyObject], ["id":100 as AnyObject, "name": "Foo" as AnyObject]]]
            let jsonData = try! JSONSerialization.data(withJSONObject: fecosystems, options: JSONSerialization.WritingOptions.prettyPrinted)

            return jsonData
        default:
            return "Half measures are as bad as nothing at all.".data(using: String.Encoding.utf8)!
        }
    }

    var multipartBody: [MultipartFormData]? {
        // Optional
        return nil
    }

    var task: Task {
        return Task.request
    }
}
