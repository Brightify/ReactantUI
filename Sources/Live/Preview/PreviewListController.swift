//
//  PreviewListController.swift
//  ReactantUI
//
//  Created by Tadeas Kriz on 4/25/17.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Reactant

final class PreviewListController: ControllerBase<Void, PreviewListRootView> {
    struct Dependencies {
        let worker: ReactantLiveUIWorker
    }
    struct Reactions {
        let preview: (String) -> Void
        let close: () -> Void
    }

    private let dependencies: Dependencies
    private let reactions: Reactions

    private let closeButton = UIBarButtonItem(title: "Close", style: .done)

    init(dependencies: Dependencies, reactions: Reactions) {
        self.dependencies = dependencies
        self.reactions = reactions

        super.init(title: "Select view to preview")
    }

    override func afterInit() {
        navigationItem.leftBarButtonItem = closeButton
        closeButton.rx.tap
            .subscribe(onNext: reactions.close)
            .disposed(by: lifetimeDisposeBag)
    }

    override func update() {
        let items = Array(dependencies.worker.allRegisteredDefinitionNames)
        rootView.componentState = .items(items)
    }

    override func act(on action: PlainTableViewAction<PreviewListCell>) {
        switch action {
        case .refresh:
            dependencies.worker.reloadFiles()
            invalidate()
        case .selected(let path):
            reactions.preview(path)
        case .rowAction:
            break
        }
    }
}
