//
//  UserRepository.swift
//  CleanArchitecturePractice
//
//  Created by Woody on 1/5/25.
//

import Foundation

public struct UserRepository: UserRepositoryProtocol {
    private let coreData: UserCoreDataProtocol, network: UserNetworkProtocol
    init(coreData: UserCoreDataProtocol, network: UserNetworkProtocol) {
        self.coreData = coreData
        self.network = network
    }
    public func fetchUser(query: String, page: Int) async -> Result<UserListModel, NetworkError> {
        await network.fetchUser(query: query, page: page)    
    }
    
    public func getFavoriteUserList() -> Result<[UserRepositoryModel], CoreDataError> {
        coreData.getFavoriteUserList()
    }
    
    public func saveFavoriteUser(user: UserRepositoryModel) -> Result<Bool, CoreDataError> {
        return coreData.saveFavoriteUser(user: user)
    }
    
    public func deleteFavoriteUser(userID: Int) -> Result<Bool, CoreDataError> {
        coreData.deleteFavoriteUser(userID: userID)
    }
}
