//
//  TabButtonView.swift
//  CleanArchitecturePractice
//
//  Created by Woody on 1/6/25.
//

import RxSwift
import RxCocoa
import UIKit
// MARK: TabButtonStackView
final class TabButtonStackView: UIStackView {
    private var disposeBag = DisposeBag()
    private let tabButtonType: [TabButtonType]
    let selectedButton: BehaviorRelay<TabButtonType?>
    
    init(tabButtonType: [TabButtonType]) {
        self.tabButtonType = tabButtonType
        self.selectedButton = BehaviorRelay<TabButtonType?>(value: tabButtonType.first)
        super.init(frame: .zero)
        axis = .horizontal
        alignment = .fill
        distribution = .fillEqually
        addButton()
        (arrangedSubviews.first as? UIButton)?.isSelected = true
    }
    
    private func addButton() {
        tabButtonType.forEach { tabType in
            let button = TabButton(tabButton: tabType)
            button.rx.tap.bind { [weak self] in
                self?.arrangedSubviews.forEach { ($0 as? UIButton)?.isSelected = false }
                button.isSelected = true
                self?.selectedButton.accept(tabType)
            }.disposed(by: disposeBag)
            addArrangedSubview(button)
        }
    }
    
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: TabButton
final class TabButton: UIButton {
    let tabButton: TabButtonType
    
    override var isSelected: Bool {
        didSet {
            backgroundColor = isSelected ? .systemBlue : .white
        }
    }
    
    init(tabButton: TabButtonType) {
        self.tabButton = tabButton
        super.init(frame: .zero)
        setTitle(tabButton.rawValue.capitalized, for: .normal)
        setTitleColor(.black, for: .normal)
        setTitleColor(.white, for: .selected)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

