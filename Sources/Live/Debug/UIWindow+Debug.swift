//
//  UIWindow+Debug.swift
//  ReactantUI
//
//  Created by Tadeas Kriz on 4/25/17.
//  Copyright © 2017 Brightify. All rights reserved.
//

import UIKit

extension UIWindow {
    override open var canBecomeFirstResponder: Bool {
        return true
    }

    override open var keyCommands: [UIKeyCommand]? {
        return [
            UIKeyCommand(input: "d", modifierFlags: .command, action: #selector(openLiveUIDebugMenu), discoverabilityTitle: "Open Debug Menu"),
            UIKeyCommand(input: UIKeyInputEscape, modifierFlags: [], action: #selector(dissmissErrorView), discoverabilityTitle: "Dismiss error"),
        ]
    }

    @objc
    func openLiveUIDebugMenu() {
        let controller = DebugAlertController.create(manager: ReactantLiveUIManager.shared, window: self)
        self.rootViewController?.present(controller: controller)
    }

    @objc
    func dissmissErrorView() {
        ReactantLiveUIManager.shared.resetErrors()
    }
}
