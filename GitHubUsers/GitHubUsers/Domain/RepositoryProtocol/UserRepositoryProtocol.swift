//
//  UserRepositoryProtocol.swift
//  CleanArchitecturePractice
//
//  Created by Woody on 1/5/25.
//

import Foundation

public protocol UserRepositoryProtocol {
    func fetchUser(query: String, page: Int) async -> Result<UserListModel, NetworkError>
    func getFavoriteUserList() -> Result<[UserRepositoryModel], CoreDataError>
    func saveFavoriteUser(user: UserRepositoryModel) -> Result<Bool, CoreDataError>
    func deleteFavoriteUser(userID: Int) -> Result<Bool, CoreDataError>
}
