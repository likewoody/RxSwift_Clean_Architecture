//
//  UserSession.swift
//  CleanArchitecturePractice
//
//  Created by Woody on 1/5/25.
//

import Foundation
import Alamofire

public protocol UserSessionProtocol {
    func request(_ convertible: any URLConvertible,
                 method: HTTPMethod,
                 parameters: Parameters?,
                 headers: HTTPHeaders?) -> DataRequest
}

public class UserSession: UserSessionProtocol {
    let session: Session
    
    init() {
        let config = URLSessionConfiguration.default
        config.requestCachePolicy = .returnCacheDataElseLoad // cache 데이터가 있다면 cache return 받아 사용
        self.session = Session(configuration: config)
    }
    
    public func request(_ convertible: any URLConvertible,
                 method: HTTPMethod = .get,
                 parameters: Parameters? = nil,
                 headers: HTTPHeaders? = nil) -> DataRequest {
        session.request(convertible, method: method, parameters: parameters, headers: headers)
        
    }
}
