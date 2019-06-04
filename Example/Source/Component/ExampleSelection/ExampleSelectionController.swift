//
//  ExampleSelectionController.swift
//  Example
//
//  Created by Matouš Hýbl on 09/03/2018.
//

import Hyperdrive
import RxSwift
import RxGesture

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

final class ExampleSelectionController: HyperViewController<ExampleSelectionRootView> {
    struct Reactions {
        let exampleSelected: (ExampleType) -> Void
    }

    private let reactions: Reactions
    private let lifetimeDisposeBag = DisposeBag()

    init(reactions: Reactions) {
        self.reactions = reactions

        super.init()

        title = "Examples"
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        for example in ExampleType.allCases {
            let cell = SelectionCell(actionPublisher: ActionPublisher<SelectionCell.Action> { _ in })
            cell.state.name = example.name

//            cell.rx
//                .tapGesture()
//                .when(.recognized)
//                .subscribe(onNext: { [reactions] _ in
//                    reactions.exampleSelected(example)
//                })
//                .disposed(by: lifetimeDisposeBag)

            hyperView.stackView.addArrangedSubview(cell)
        }
    }

    override func handle(action: ExampleSelectionRootView.Action) {
        switch action {
        case .cellAct:
            print("what")
        }
    }

    /*override*/ func act(on action: ExampleType) {
        reactions.exampleSelected(action)
    }
}
