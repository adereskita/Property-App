//
//  APIManager.swift
//  iOSTest
//
//  Created by Ade Reskita on 07/08/20.
//  Copyright © 2020 Ade Reskita. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class APIManager {
    
    let headers: HTTPHeaders = [
    "secret-key" : "$2b$10$z032e5RzBFljvw44bmQIyeDpK7yxz.gh9W2NO5VuiLtXfDciFYWq2"
    ]
    
    class func headers() -> HTTPHeaders {
        var headers: HTTPHeaders = [
        "secret-key" : "$2b$10$z032e5RzBFljvw44bmQIyeDpK7yxz.gh9W2NO5VuiLtXfDciFYWq2"
        ]

        if let authToken = UserDefaults.standard.string(forKey: "auth_token") {
            headers["Authorization"] = "Token" + " " + authToken
        }

        return headers
    }

}
