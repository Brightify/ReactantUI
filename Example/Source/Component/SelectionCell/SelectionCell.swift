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

    var name: String {
        switch self {
        case .plainTableView:
            return "Plain table view"
        case .playground:
            return "Playground"
        }
    }

    static let allValues: [ExampleType] = [.plainTableView, .playground]
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
