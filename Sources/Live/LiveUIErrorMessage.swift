//
//  LiveUIErrorMessage.swift
//  ReactantUI
//
//  Created by Tadeas Kriz.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Reactant
import RxSwift

enum LiveUIErrorMessageItemAction {
    case dismiss
}

final class LiveUIErrorMessage: ViewBase<[String: String], LiveUIErrorMessageItemAction> {

    override var actions: [Observable<LiveUIErrorMessageItemAction>] {
        return [
            button.rx.tap.rewrite(with: .dismiss)
        ]
    }

    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    private let button = UIButton()

    override func update() {
        let state = componentState

        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        for (index, item) in state.enumerated() {
            if index > 0 {
                let divider = UIView()
                Styles.divider(view: divider)
                stackView.addArrangedSubview(divider)
                divider.snp.makeConstraints { make in
                    make.height.equalTo(1)
                }
            }

            let itemView = LiveUIErrorMessageItem().with(state: (file: item.key, message: item.value))
            stackView.addArrangedSubview(itemView)
        }

        isHidden = state.isEmpty
    }

    override func loadView() {
        children(
            scrollView.children(
                stackView
            ),
            button
        )

        Styles.base(view: self)

        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.alignment = .fill
        stackView.spacing = 10

        button.setTitle("Dismiss (ESC)", for: .normal)
        button.setTitleColor(.white, for: .normal)
    }

    override func setupConstraints() {
        scrollView.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()
            make.top.equalToSuperview()
        }

        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(UIEdgeInsets(top: 40, left: 20, bottom: 20, right: 20))
            make.width.equalToSuperview().inset(20)
        }

        button.snp.makeConstraints { make in
            make.leading.equalToSuperview()
            make.trailing.equalToSuperview()

            make.top.equalTo(scrollView.snp.bottom)
            make.bottom.equalToSuperview()

            make.height.equalTo(50)
        }
    }
}

extension LiveUIErrorMessage {
    fileprivate struct Styles {
        static func base(view: LiveUIErrorMessage) {
            view.backgroundColor = UIColor(red:0.800, green: 0.000, blue: 0.000, alpha:1)
        }

        static func divider(view: UIView) {
            view.backgroundColor = .white
        }

        static func stack(label: UILabel) {
            label.textColor = .white
            label.numberOfLines = 0
        }
    }
}
