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
        fileprivate weak var owner: PreviewListRootView? { didSet { resynchronize() } }

        var items: [PreviewListCell.State] = [] { didSet { notifyItemsChanged() } }

        func apply(from otherState: PreviewListRootView.State) {
            items = otherState.items
        }

        func resynchronize() {
            notifyItemsChanged()
        }

        private func notifyItemsChanged() {
            owner?.tableView1.componentState = .items(items)
        }
    }
    enum Action {
        case refresh
        case selected(PreviewListCell.State)
        case rowAction
    }

    static let triggerReloadPaths: Set<String> = []

    let state: State

    private let tableView1 = Hyperdrive.PlainTableView<PreviewListCell>(cellFactory: PreviewListCell())

    init(initialState: State = State(), actionPublisher: ActionPublisher<Action> = ActionPublisher()) {
        state = initialState

        super.init()

        loadView()
        setupConstraints()
    
        state.owner = self
    }

    private func loadView() {
        addSubview(tableView1)

        backgroundColor = .white
    }

    private func setupConstraints() {
        tableView1.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
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
