//
//  PreviewListController.swift
//  ReactantUI
//
//  Created by Tadeas Kriz on 4/25/17.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Hyperdrive
import RxSwift

final class PreviewListController: HyperViewController<PreviewListRootView> {
    struct Dependencies {
        let worker: ReactantLiveUIWorker
    }
    struct Reactions {
        let preview: (String) -> Void
        let close: () -> Void
    }

    private let dependencies: Dependencies
    private let reactions: Reactions

    private let closeButton = UIBarButtonItem(title: "Close", style: .done, target: nil, action: nil)

    private let lifetimeDisposeBag = DisposeBag()

    init(dependencies: Dependencies, reactions: Reactions) {
        self.dependencies = dependencies
        self.reactions = reactions

        super.init()

        afterInit()
    }

    private func afterInit() {
        title = "Select view to preview"

        navigationItem.leftBarButtonItem = closeButton
        closeButton.rx.tap
            .subscribe(onNext: reactions.close)
            .disposed(by: lifetimeDisposeBag)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        loadDefinitions()
    }

    private func loadDefinitions() {
        let items = Array(dependencies.worker.allRegisteredDefinitionNames)
        hyperView.state.items = items.map {
            let state = PreviewListCell.State()
            state.title = $0
            return state
        }
    }

    override func handle(action: PreviewListRootView.Action) {
        switch action {
        case .refresh:
            dependencies.worker.reloadFiles()
            loadDefinitions()
        case .selected(let path):
            guard let title = path.title else { break }
            reactions.preview(title)
        case .rowAction:
            break
        }
    }
}
