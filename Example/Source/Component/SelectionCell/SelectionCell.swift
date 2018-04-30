//
//  SelectionCell.swift
//  Example
//
//  Created by Matouš Hýbl on 09/03/2018.
//

import Reactant
import RxSwift

enum ExampleType {
    case plainTableView
    case playground
    case stackView
    case progressView

    var name: String {
        switch self {
        case .plainTableView:
            return "Plain table view"
        case .playground:
            return "Playground"
        case .stackView:
            return "Stack view"
        case .progressView:
            return "Progress view"
        }
    }

    static let allValues: [ExampleType] = [.plainTableView, .playground, .stackView, .progressView]
}

final class SelectionCell: ButtonBase<ExampleType, ExampleType> {
    override var actions: [Observable<ExampleType>] {
        return [
            rx.controlEvent(.touchUpInside).withLatestFrom(observableState)
        ]
    }

    let name = UILabel()

    override func update() {
        name.text = componentState.name
    }
}
