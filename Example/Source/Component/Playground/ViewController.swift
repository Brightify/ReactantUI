//
//  ViewController.swift
//  ReactantPrototyping
//
//  Created by Filip Dolnik on 16.02.17.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Reactant
import UIKit
import SnapKit
import RxSwift

class ViewController: ControllerBase<Void, ExampleRootView> {

    override init() {
        super.init()

        rootView.componentState = (test: "test", 1, test2: (a: 10, b: "hello worl"))

        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .camera) {
            ApplicationTheme.selector.select(theme: ApplicationTheme.selector.currentTheme == .day ? .night : .day)
        }
    }
}
