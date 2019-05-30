//
//  ExampleSelectionController.swift
//  Example
//
//  Created by Matouš Hýbl on 09/03/2018.
//

import Hyperdrive
import RxSwift

final class ExampleSelectionController: ControllerBase<Void, ExampleSelectionRootView> {
    struct Reactions {
        let exampleSelected: (ExampleType) -> Void
    }

    private let reactions: Reactions

    init(reactions: Reactions) {
        self.reactions = reactions

        super.init(title: "Examples")
    }

    override func act(on action: ExampleType) {
        reactions.exampleSelected(action)
    }
}
