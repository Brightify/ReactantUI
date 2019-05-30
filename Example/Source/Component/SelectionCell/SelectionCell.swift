//
//  SelectionCell.swift
//  Example
//
//  Created by Matouš Hýbl on 09/03/2018.
//

import Hyperdrive
import RxSwift

enum ExampleType: CaseIterable {
    case plainTableView
    case headerTableView
    case footerTableView
    case simpleTableView
    case simulatedSeparatorTableView
    case playground
    case stackView
    case progressView

    var name: String {
        switch self {
        case .plainTableView:
            return "Plain table view"
        case .headerTableView:
            return "Header table view"
        case .footerTableView:
            return "Footer table view"
        case .simpleTableView:
            return "Simple table view"
        case .simulatedSeparatorTableView:
            return "Simulated separator table view"
        case .playground:
            return "Playground"
        case .stackView:
            return "Stack view"
        case .progressView:
            return "Progress view"
        }
    }
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
