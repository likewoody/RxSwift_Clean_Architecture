//
//  UserUsecase.swift
//  CleanArchitecturePractice
//
//  Created by Woody on 1/5/25.
//

import Foundation

public protocol UserUsecase {
    func fetchUser(query: String, page: Int) async -> Result<UserListModel, NetworkError> // 유저 데이터 호출 (REST API)
    func getFavoriteUserList() -> Result<[UserRepositoryModel], CoreDataError> // Core Data
    func saveFavoriteUser(user: UserRepositoryModel) -> Result<Bool, CoreDataError> // Core Data
    func deleteFavoriteUser(userID: Int) -> Result<Bool, CoreDataError> // Core Data
    
    func checkFavoriteState(fetchUsers: [UserRepositoryModel],  favoriteUsers: [UserRepositoryModel]) -> [(user:UserRepositoryModel, isFavorite: Bool)]
    func convertListToDict(favoriteUsers: [UserRepositoryModel]) -> [String:[UserRepositoryModel]]
}

public struct UserUsecaseImpl: UserUsecase {
    /*
        Data, API작업을 해야하는데 Data와 API 작업은 저수준 모듈이기 떄문에
        RespositoryProtocol을 만들어 고수준으로 추상화한다.
        추상화한 RespositoryProtocol은 RespositoryImpl을 만들어 저수준에서 실제 Data, API 작업을 실행한다.
     */
    let userRepository: UserRepositoryProtocol
    
    init(userRepository: UserRepositoryProtocol) {
        self.userRepository = userRepository
    }
    
    public func fetchUser(query: String, page: Int) async -> Result<UserListModel, NetworkError> {
        await userRepository.fetchUser(query: query, page: page)
    }
    
    public func getFavoriteUserList() -> Result<[UserRepositoryModel], CoreDataError> {
        userRepository.getFavoriteUserList()
    }
    
    public func saveFavoriteUser(user: UserRepositoryModel) -> Result<Bool, CoreDataError> {
        return userRepository.saveFavoriteUser(user: user)
    }
    
    public func deleteFavoriteUser(userID: Int) -> Result<Bool, CoreDataError> {
        userRepository.deleteFavoriteUser(userID: userID)
    }
    public func checkFavoriteState(fetchUsers: [UserRepositoryModel], favoriteUsers: [UserRepositoryModel]) -> [(user: UserRepositoryModel, isFavorite: Bool)] {
        let setFavoriteUsers = Set(favoriteUsers) // 이중 for문이여서 속도가 느릴 수 있기 때문에 set으로 최대한 중복 데이터를 제거한다.
        let returnValue = fetchUsers.map { user in
            if setFavoriteUsers.contains(user) {
                return (user: user, isFavorite: true)
            }else {
                return (user: user, isFavorite: false)
            }
        }
//        print(returnValue)
        return returnValue
    }
    public func convertListToDict(favoriteUsers: [UserRepositoryModel]) -> [String : [UserRepositoryModel]] {
        return favoriteUsers.reduce(into: [String:[UserRepositoryModel]]()) {
            if let firstString = $1.repository.owner.login.first { // 초성 추출
                let key = firstString.uppercased() // 추출한 초성을 대문자로 만들기
                $0[key, default: []].append($1)
            }
        }
    }
    
}
