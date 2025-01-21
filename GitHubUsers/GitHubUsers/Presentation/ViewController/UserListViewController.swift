//
//  UserListViewController.swift
//  CleanArchitecturePractice
//
//  Created by Woody on 1/5/25.
//

import UIKit
import RxSwift
import RxCocoa
import SnapKit

class UserListViewController: UIViewController {
    private let viewModel: UserListViewModelProtocol
    private let saveFavoriteList = PublishRelay<UserRepositoryModel>()
    private let deleteFavoriteUser = PublishRelay<Int>()
    private let paging = BehaviorRelay<Int>(value: 1)
    private var disposeBag = DisposeBag()
    
    // MARK: components
    private let textField: UITextField = {
        let textField = UITextField()
        textField.layer.borderColor = UIColor.gray.cgColor
        textField.layer.borderWidth = 1
        textField.layer.cornerRadius = 8
        textField.placeholder = "검색어를 입력하세요."
        let image = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        image.frame = .init(x: 0, y: 0, width: 20, height: 20)
        textField.leftView = image
        textField.leftViewMode = .always
        textField.tintColor = .gray
        return textField
    }()
    
    private let tabButtonStackView = TabButtonStackView(tabButtonType: [.all, .favorite])
    private let tableView: UITableView = {
        let tableView = UITableView()
        
        tableView.register(UserTableViewCell.self, forCellReuseIdentifier: UserTableViewCell.id)
        tableView.register(HeaderTableViewCell.self, forCellReuseIdentifier: HeaderTableViewCell.id)
        return tableView
    }()
    
    // MARK: init
    init(viewModel: UserListViewModelProtocol) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        super.view.backgroundColor = .white
        
        setUI()
        bindView()
        bindViewModel()
    }
    
    // MARK: functions
    private func setUI() {
        view.addSubview(textField)
        view.addSubview(tabButtonStackView)
        view.addSubview(tableView)
        
        textField.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.equalToSuperview().inset(16)
            make.height.equalTo(44)
        }

        tabButtonStackView.snp.makeConstraints { make in
            make.top.equalTo(textField.snp.bottom).offset(8)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(50)
        }
        
        tableView.snp.makeConstraints { make in
            make.top.equalTo(tabButtonStackView.snp.bottom)
            make.leading.trailing.bottom.equalToSuperview()
        }
        
    }
    
    private func bindView() {
        self.tableView.rx.prefetchRows.bind(onNext: { [weak self] indexPath in
            guard let rows = self?.tableView.numberOfRows(inSection: 0), let firstIndext = indexPath.first?.row else { return }
            if firstIndext >= rows - 2 {
                if let currentPaging = self?.paging.value {
                    self?.paging.accept(currentPaging + 1)
                }
            }
        }).disposed(by: disposeBag)
    }
    
    private func bindViewModel() {
//        print("bindViewModel start")
        let tabButon = tabButtonStackView.selectedButton.compactMap{ $0 }
        let query = textField.rx.text.orEmpty.debounce(.milliseconds(300), scheduler: MainScheduler.instance)
//        print(query)
        
        let output = viewModel.transform(input: UserListViewModel.Input(tabButtonType: tabButon, query: query, saveFavorite: saveFavoriteList.asObservable(), deleteFavorite: deleteFavoriteUser.asObservable(), paging: paging.asObservable()))
        output.cellData.bind(to: tableView.rx.items) { [weak self] tableView, index, item in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: item.id) else { return UITableViewCell() }
            
            (cell as? UserTableViewCell)?.apply(cellData: item)
            (cell as? HeaderTableViewCell)?.apply(cellData: item)
            
            if let cell = cell as? UserTableViewCell, case let .user(user, isFavorite) = item {
                cell.favoriteButton.rx.tap.bind {
                    if isFavorite {
                        self?.deleteFavoriteUser.accept(user.repository.owner.id)
                    } else {
                        self?.saveFavoriteList.accept(user)
                    }
                }.disposed(by: cell.disposeBag)
            }
            
            return cell
        }.disposed(by: disposeBag)
        
        output.error
            .observe(on: MainScheduler.instance) // main thread 보장이 안되기 때문에 사용
            .bind { [weak self] errorMsg in
//                guard let self = self else { return }
                let alert = UIAlertController(title: "에러", message: errorMsg, preferredStyle: .alert) // Set Title
                    alert.addAction(.init(title: "확인", style: .default)) // Set OK Button
                self?.present(alert, animated: true)
        }.disposed(by: disposeBag)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
