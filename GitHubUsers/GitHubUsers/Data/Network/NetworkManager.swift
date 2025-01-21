//
//  NetworkManager.swift
//  CleanArchitecturePractice
//
//  Created by Woody on 1/5/25.
//

import Foundation
import Alamofire

// MARK: 추상체
public protocol NetworkManagerProtocol {
    func fetchData<T: Decodable>(urlString: String, method: HTTPMethod, parameters: Parameters?) async -> Result<T, NetworkError>
}

// MARK: 실제 UserNetwork에서 사용할 구현체
public class NetworkManager: NetworkManagerProtocol {
    let session: UserSessionProtocol // Session Protocol을 사용한 이유는 mock data test + 추상화된 코드
    var headers: HTTPHeaders { // tokenHeader token 설정
        let header = HTTPHeader(name: "Authorization", value: "Bearer \(api_key)")
        let headers = HTTPHeaders([header])
        return headers
    }
    var api_key: String {
        guard let path = Bundle.main.path(forResource: "Info", ofType: "plist"),
              let dict = NSDictionary(contentsOfFile: path),
              let token = dict["API_KEY"] as? String else {
            fatalError("Configuration.plist not found or token missing")
        }
        return token
    }
    
    init(session: UserSessionProtocol) {
        self.session = session
    }
    
    public func fetchData<T: Decodable>(urlString: String, method: HTTPMethod, parameters: Parameters?) async -> Result<T, NetworkError> {
        let result = await session.request(urlString, method: method, parameters: parameters, headers: headers).serializingData().response
        
        if let error = result.error { // error가 있는 경우 return error
            return .failure(.requestFailed(error.localizedDescription))
        }
        guard let data = result.data else { return .failure(.dataNil)}
        guard let response = result.response else { return .failure(.invalidResponse)}
        if 200..<400 ~= response.statusCode {
            do {
                let datas = try JSONDecoder().decode(T.self, from: data)
                return .success(datas)
            } catch let error {
                return .failure(.failToDecode(error.localizedDescription))
            }
            
        } else {
            return .failure(.serverError(response.statusCode))
        }
    }
}
