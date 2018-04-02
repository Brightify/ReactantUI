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

    var name: String {
        switch self {
        case .plainTableView:
            return "Plain table view"
        case .playground:
            return "Playground"
        case .stackView:
            return "Stack view"
        }
    }

    static let allValues: [ExampleType] = [.plainTableView, .playground, .stackView]
}

final class SelectionCell: ControlBase<ExampleType, ExampleType> {
    override var actions: [Observable<ExampleType>] {
        return [
            rx.controlEvent(.touchUpOutside).withLatestFrom(observableState)
        ]
    }

    let name = UILabel()

    override func update() {
        name.text = componentState.name
    }
}
