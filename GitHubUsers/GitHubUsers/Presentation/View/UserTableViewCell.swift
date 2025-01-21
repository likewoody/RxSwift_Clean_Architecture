//
//  UserTableViewCell.swift
//  CleanArchitecturePractice
//
//  Created by Woody on 1/6/25.
//

import UIKit
import Kingfisher
import RxSwift

protocol UserListCellProtocol {
    func apply(cellData: UserListCellData)
}

final class UserTableViewCell: UITableViewCell, UserListCellProtocol {
    static let id = "UserTableViewCell"
    // 필요한 UI => Image, Text
    private let userImage: UIImageView = {
        let userImage = UIImageView()
        userImage.layer.borderWidth = 1
        userImage.layer.borderColor = UIColor.gray.cgColor
        userImage.layer.cornerRadius = 5
        userImage.clipsToBounds = true
        return userImage
    }()
    private let titleLabel: UILabel = {
        let titleLabel = UILabel()
        titleLabel.font = .systemFont(ofSize: 18)
        titleLabel.numberOfLines = 2
        return titleLabel
    }()
    public let favoriteButton: UIButton = {
        let favoriteButton = UIButton()
        favoriteButton.setImage(UIImage(systemName: "heart"), for: .normal)
        favoriteButton.setImage(UIImage(systemName: "heart.fill"), for: .selected)
        favoriteButton.tintColor = .red
        return favoriteButton
    }()
    public var disposeBag = DisposeBag()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(userImage)
        contentView.addSubview(titleLabel)
        contentView.addSubview(favoriteButton)
        
        userImage.snp.makeConstraints { make in
            make.top.leading.bottom.equalToSuperview().inset(20)
            make.width.equalTo(80)
            make.height.equalTo(80).priority(.high)
        }
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(userImage)
            make.leading.equalTo(userImage.snp.trailing).offset(10)
            make.trailing.equalToSuperview().inset(20)
        }
        favoriteButton.snp.makeConstraints { make in
            make.centerY.equalToSuperview()
            make.trailing.equalTo(-20)
        }
    }
    
    func apply(cellData: UserListCellData) {
        guard case let .user(user, isFavorite) = cellData else { return }
        userImage.kf.setImage(with: URL(string: user.repository.owner.imageURL))
//        print("\(user.login) 이름 at UserTableViewCell apply")
        titleLabel.text = user.repository.owner.login
        favoriteButton.isSelected = isFavorite

    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
