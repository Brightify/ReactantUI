//
//  PreviewListRootView.swift
//  ReactantUI
//
//  Created by Tadeas Kriz on 4/25/17.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Hyperdrive

//final class HyperTableView<Cell: View & HyperView>: UITableView, UITableViewDelegate, UITableViewDataSource {
//}

final class PreviewListRootView: HyperViewBase, HyperView /*Hyperdrive.PlainTableView<PreviewListCell>, RootView*/ {
    final class State: HyperViewState {
        fileprivate weak var owner: PreviewListRootView?

        var items: [PreviewListCell.State] = [] { didSet { notifyItemsChanged() } }

        func apply(from otherState: PreviewListRootView.State) {
            items = otherState.items
        }

        func resynchronize() {
            notifyItemsChanged()
        }

        private func notifyItemsChanged() {

        }
    }
    enum Action {
        case refresh
        case selected(PreviewListCell.State)
        case rowAction
    }

    static let triggerReloadPaths: Set<String> = []

    let state: State

    private let tableView1 = UITableView()

    init(initialState: State, actionPublisher: ActionPublisher<Action>) {
        state = initialState

        super.init()
    
        state.owner = self
    }

    
//    @objc
//    init() {
//        super.init(
//            cellFactory: PreviewListCell.init,
//            reloadable: true)
//
//        rowHeight = UITableView.automaticDimension
//        backgroundColor = .white
//    }
}
