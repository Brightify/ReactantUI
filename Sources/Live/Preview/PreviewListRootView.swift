//
//  PreviewListRootView.swift
//  ReactantUI
//
//  Created by Tadeas Kriz on 4/25/17.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Reactant

final class PreviewListRootView: Reactant.PlainTableView<PreviewListCell>, RootView {
    override var edgesForExtendedLayout: UIRectEdge {
        return .all
    }

    @objc
    init() {
        super.init(
            cellFactory: PreviewListCell.init,
            options: [.reloadable, .deselectsAutomatically])

        rowHeight = UITableView.automaticDimension
        backgroundColor = .white
    }
}
