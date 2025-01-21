//
//  UserCoreData.swift
//  CleanArchitecturePractice
//
//  Created by Woody on 1/5/25.
//

import Foundation
import CoreData

// MARK: Core Data 추상체
public protocol UserCoreDataProtocol {
    func getFavoriteUserList() -> Result<[UserRepositoryModel], CoreDataError> // Core Data
    func saveFavoriteUser(user: UserRepositoryModel) -> Result<Bool, CoreDataError> // Core Data
    func deleteFavoriteUser(userID: Int) -> Result<Bool, CoreDataError> // Core Data
}

// MARK: Core Data 구현체
// 1. fetch - NSFetchRequest 사용
// 2. save - NSEntity Description 사용
// 3. delete - fetch 후 result 값으로 delete
public struct UserCoreData: UserCoreDataProtocol {
    
    private let viewContext: NSManagedObjectContext
    
    init(viewContext: NSManagedObjectContext) {
        self.viewContext = viewContext
    }
    
    public func getFavoriteUserList() -> Result<[UserRepositoryModel], CoreDataError> {
        let fetchRequest: NSFetchRequest<FavoriteUser> = FavoriteUser.fetchRequest() // CoreData => FavoriteUser
        do {
            let result = try viewContext.fetch(fetchRequest)
            let userList: [UserRepositoryModel] = result.compactMap { favoriteUser in
                guard let login = favoriteUser.login, let imageURL = favoriteUser.imageURL else { return nil } // compactMap을 사용하여 nil이 반환되면 nil을 제외하고 return
                return UserRepositoryModel(repository: UserOwnerModel(owner: UserModel(id: Int(favoriteUser.id), login: login, imageURL: imageURL)))
            }
            return .success(userList)
        } catch {
            return .failure(.entityNotFound("FavoriteUser"))
        }
    }
    
    public func saveFavoriteUser(user: UserRepositoryModel) -> Result<Bool, CoreDataError> {
        guard let entity = NSEntityDescription.entity(forEntityName: "FavoriteUser", in: viewContext) else { return .failure(.entityNotFound("FavoriteUser Entity Not Found"))}
//        print("coreData save Favorite user : \(user)")
        let userObject = NSManagedObject(entity: entity, insertInto: viewContext)
        userObject.setValue(user.repository.owner.id, forKey: "id")
        userObject.setValue(user.repository.owner.login, forKey: "login")
        userObject.setValue(user.repository.owner.imageURL, forKey: "imageURL")
        do {
            try viewContext.save()
            return .success(true)
        } catch {
            return .failure(.saveError(error.localizedDescription))
        }
    }
    
    public func deleteFavoriteUser(userID: Int) -> Result<Bool, CoreDataError> {
        let fetchRequest: NSFetchRequest<FavoriteUser> = FavoriteUser.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %d", userID)
        do {
            let result = try viewContext.fetch(fetchRequest)
            guard let resultFirst = result.first else { return .failure(.entityNotFound("FAVORITE USER NOT FOUND")) }
            viewContext.delete(resultFirst)
            try viewContext.save()
            return .success(true)
        } catch {
            return .failure(.deleteError(error.localizedDescription))
        }
    }
}
