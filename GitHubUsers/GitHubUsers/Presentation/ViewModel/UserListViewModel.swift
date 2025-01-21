//
//  UserListViewModel.swift
//  CleanArchitecturePractice
//
//  Created by Woody on 1/5/25.
//

import Foundation
import RxSwift
import RxCocoa

public protocol UserListViewModelProtocol {
    func transform(input: UserListViewModel.Input) -> UserListViewModel.Output
//    func fetchUser(query: String, page: Int)
//    func getFavoriteUserList(query: String)
//    func validQuery(query: String) -> Bool
//    func saveFavoriteUser(user: UserModel, query: String)
//    func deleteFavoriteUser(userID: Int, query: String)
}

public final class UserListViewModel: UserListViewModelProtocol {
    private let usecase: UserUsecase
    private let disposeBag = DisposeBag()
    private let error = PublishRelay<String>()
    private let userList = BehaviorSubject<[UserRepositoryModel]>(value: [])
    private let favoriteUserList = BehaviorSubject<[UserRepositoryModel]>(value: [])
    private let allFavoriteUserList = BehaviorSubject<[UserRepositoryModel]>(value: [])
    
    init(usecase: UserUsecase) {
        self.usecase = usecase
    }
    
    public struct Input {
        // tab Button, query, saveFavorite, delteFavortie, paging
        let tabButtonType: Observable<TabButtonType>
        let query: Observable<String>
        let saveFavorite: Observable<UserRepositoryModel>
        let deleteFavorite: Observable<Int>
        let paging: Observable<Int>
    }
    public struct Output {
        let cellData: Observable<[UserListCellData]>
        let error: Observable<String> // error를 따로 저장하지 않아도 되기에 String으로 return
    }
    
    public func transform(input: Input) -> Output {
        input.query.bind { [weak self] query in
            // TODO: get userList by query & favorite list
            guard let self = self, validQuery(query: query) else {
                self?.getFavoriteUserList(query: "")
                return
            }
            getFavoriteUserList(query: query)
            fetchUser(query: query, page: 1) // TODO: page 처리 필요
        }.disposed(by: disposeBag)
        
        input.saveFavorite
            .withLatestFrom(input.query, resultSelector: { ($0, $1) })
            .bind { [weak self] userModel, query in
            // TODO: save favorite user
                self?.saveFavoriteUser(user: userModel, query: query)
        }.disposed(by: disposeBag)
        
        input.deleteFavorite
            .withLatestFrom(input.query, resultSelector: { ($0, $1) })
            .bind { [weak self] userID, query in
            // TODO: delete favorite user
                self?.deleteFavoriteUser(userID: userID, query: query)
        }.disposed(by: disposeBag)
        
        input.paging
            .withLatestFrom(input.query, resultSelector: { ($0, $1) })
            .bind { [weak self] currentPaging, query in
//            // TODO: when scroll down, get more page
            self?.fetchUser(query: query, page: currentPaging)
        }.disposed(by: disposeBag)
        
        let cellData: Observable<[UserListCellData]> = Observable.combineLatest(input.tabButtonType, userList, favoriteUserList, allFavoriteUserList).map { [weak self] tabButtonType, userList, favoriteUserList, allFavoriteUserList in
            var cellData: [UserListCellData] = []
            // TODO: which data will pass from here to ViewController
            guard let self = self else {return cellData}
            switch tabButtonType {
            case .all:
                let result = usecase.checkFavoriteState(fetchUsers: userList, favoriteUsers: allFavoriteUserList)
                return result.map { user, isFavorite in
                    UserListCellData.user(user: user, isFavorite: isFavorite)
                }
            case .favorite:
                let dict = usecase.convertListToDict(favoriteUsers: favoriteUserList)
                let keys = dict.keys.sorted() // [초성 : [UserModel]] 형식이므로, Key 초성만 가져온다.
                keys.forEach { key in
                    cellData.append(.header(key))
//                    print("cellData check : \(cellData)")
//                    print("dict key : \(dict[key])")
                    if let users = dict[key] {
                        cellData += users.map { UserListCellData.user(user: $0, isFavorite: true) }
                    }
                }
            }
            return cellData
        }
        return Output(cellData: cellData, error: error.asObservable()) // Observable 데이터를 방출만 하는 것을 선언
    }
    
    private func fetchUser(query: String, page: Int) {
        guard let urlQueryAllowed = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) else { return }
        Task{
            let result = await usecase.fetchUser(query: urlQueryAllowed, page: page)
            switch result {
            case .success(let users):
                if page == 1 { // page가 0이면 just show userList
                    userList.onNext(users.items)
                } else {
                    // page가 0이 아닐 때 기존 리스트 + new userList
                    userList.onNext(try userList.value() + users.items)
                }
            case .failure(let error):
                self.error.accept(error.description)
            }
        }
    }
    
    private func getFavoriteUserList(query: String) {
        let result = usecase.getFavoriteUserList()
        switch result {
        case .success(let users):
            if query.isEmpty {
                favoriteUserList.onNext(users)
            } else {
                let filteredUsers = users.filter { $0.repository.owner.login.contains(query.lowercased()) }
                favoriteUserList
                    .onNext(filteredUsers)
            }
            allFavoriteUserList.onNext(users)
        case .failure(let error):
            self.error.accept(error.description)
        }
    }
    
    private func validQuery(query: String) -> Bool {
        if query.isEmpty {
            return false
        } else {
            return true
        }
    }
    
    private func saveFavoriteUser(user: UserRepositoryModel, query: String) {
        let result = usecase.saveFavoriteUser(user: user)
        switch result {
        case .success(_):
            getFavoriteUserList(query: query)
        case .failure(let error):
            self.error.accept(error.description)
        }
    }
    
    private func deleteFavoriteUser(userID: Int, query: String) {
        let result = usecase.deleteFavoriteUser(userID: userID)
        switch result {
        case .success(_):
            getFavoriteUserList(query: query)
        case .failure(let error):
            self.error.accept(error.description)
        }
    }
}

enum TabButtonType: String {
    case all, favorite
}

enum UserListCellData {
    case user(user: UserRepositoryModel, isFavorite: Bool)
    case header(String)
    
    var id: String {
        switch self {
        case .header: HeaderTableViewCell.id
        case .user: UserTableViewCell.id
        }
    }
}
