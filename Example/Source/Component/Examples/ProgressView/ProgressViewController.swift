//
//  ProgressViewController.swift
//  Example
//
//  Created by Matouš Hýbl on 16/04/2018.
//

import Hyperdrive

final class ProgressViewController: HyperViewController<ProgressViewRootView> {

    init() {
        super.init()

        title = "Progress view"
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .camera) {
            ApplicationTheme.selector.select(theme: ApplicationTheme.selector.currentTheme == .day ? .night : .day)
        }
    }
}
