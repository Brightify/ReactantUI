//
//  ExampleSelectionRootView.swift
//  Example
//
//  Created by Matouš Hýbl on 09/03/2018.
//

import Reactant
import RxSwift

final class ExampleSelectionRootView: ViewBase<Void, ExampleType> {

    let stackView = UIStackView()

    override func update() {
        stackView.arrangedSubviews.forEach { stackView.removeArrangedSubview($0) }

        let selectionCells = ExampleType.allValues.map { SelectionCell().with(state: $0) }

        Observable.merge(selectionCells.map { $0.action })
            .subscribe(onNext: { [weak self] in
                self?.perform(action: $0)
            })
            .disposed(by: stateDisposeBag)

        selectionCells.forEach { stackView.addArrangedSubview($0) }
    }
}
