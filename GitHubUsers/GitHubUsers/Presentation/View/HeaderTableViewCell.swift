//
//  HeaderTableViewCell.swift
//  CleanArchitecturePractice
//
//  Created by Woody on 1/6/25.
//

import UIKit

final class HeaderTableViewCell: UITableViewCell, UserListCellProtocol {
    static let id = "HeaderTableViewCell"
    private let titleLable: UILabel = {
        let titleLable = UILabel()
        titleLable.font = .systemFont(ofSize: 20, weight: .bold)
        return titleLable
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.addSubview(titleLable)
        
        titleLable.snp.makeConstraints { make in
            make.top.leading.bottom.equalToSuperview().inset(20)
        }
    }
    
    func apply(cellData: UserListCellData) {
        guard case let .header(header) = cellData else { return }
        print(header)
        titleLable.text = header
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
