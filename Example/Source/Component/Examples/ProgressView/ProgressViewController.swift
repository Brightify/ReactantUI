//
//  ProgressViewController.swift
//  Example
//
//  Created by Matouš Hýbl on 16/04/2018.
//

import Reactant

final class ProgressViewController: ControllerBase<Void, ProgressViewRootView> {

    override init() {
        super.init(title: "Progress view")
    }

    override func afterInit() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .camera) {
            ApplicationTheme.selector.select(theme: ApplicationTheme.selector.currentTheme == .day ? .night : .day)
        }
    }
}
