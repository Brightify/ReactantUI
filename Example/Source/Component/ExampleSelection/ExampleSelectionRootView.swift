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
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }

        let selectionCells = ExampleType.allValues.map { SelectionCell().with(state: $0) }

        for cell in selectionCells {
            cell.observeAction { [weak self] in
                self?.perform(action: $0)
            }
            .track(in: stateTracking)
        }

        selectionCells.forEach { stackView.addArrangedSubview($0) }
    }
}
