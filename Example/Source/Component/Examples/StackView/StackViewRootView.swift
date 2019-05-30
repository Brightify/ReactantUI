//
//  StackViewRootView.swift
//  Example
//
//  Created by Matouš Hýbl on 02/04/2018.
//

import Hyperdrive

final class StackViewRootView: ViewBase<Void, Void> {

    let stackView = UIStackView()

    override func afterInit() {
        let view = UIView()
        view.snp.makeConstraints { make in make.height.equalTo(20) }
        view.backgroundColor = .red
        stackView.addArrangedSubview(view)
    }
}
