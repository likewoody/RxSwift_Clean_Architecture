//
//  UserNetwork.swift
//  CleanArchitecturePractice
//
//  Created by Woody on 1/5/25.
//

import Foundation

// MARK: 네트워크 추상체
public protocol UserNetworkProtocol {
    func fetchUser(query: String, page: Int) async -> Result<UserListModel, NetworkError>
}

// MARK: 실제 네트워크를 불러오는 구현체
final class UserNetwork: UserNetworkProtocol {
    private let network: NetworkManagerProtocol
    
    init(network: NetworkManagerProtocol) {
        self.network = network
    }

    func fetchUser(query: String, page: Int) async -> Result<UserListModel, NetworkError> {
        let url = "https://api.github.com/search/code?q=\(query)&page=\(page)"
        print(url)
        return await network.fetchData(urlString: url, method: .get, parameters: nil)
    }
}
