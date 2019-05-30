//
//  DebugAlertController.swift
//  ReactantUI
//
//  Created by Tadeas Kriz on 4/25/17.
//  Copyright © 2017 Brightify. All rights reserved.
//

import UIKit

class DebugAlertController: UIAlertController {
    override var canBecomeFirstResponder: Bool {
        return true
    }

    override var keyCommands: [UIKeyCommand]? {
        return [
            UIKeyCommand(input: "d", modifierFlags: .command, action: #selector(close), discoverabilityTitle: "Close Debug Menu")
        ]
    }

    @objc
    func close() {
        dismiss(animated: true)
    }

    static func create(manager: ReactantLiveUIManager, window: UIWindow) -> DebugAlertController {
        let controller = DebugAlertController(title: "Debug menu", message: "Hyperdrive Live UI", preferredStyle: .actionSheet)

        controller.popoverPresentationController?.sourceView = window
        controller.popoverPresentationController?.sourceRect = window.bounds

        let hasMultipleThemes = manager.workers.contains { $0.context.globalContext.applicationDescription.themes.count > 1 }
        let hasMultipleWorkers = manager.workers.count > 1

        if hasMultipleThemes {
            let switchTheme = UIAlertAction(title: "Switch theme ..", style: .default) { [weak window] _ in
                guard let controller = window?.rootViewController else { return }
                if hasMultipleWorkers {
                    manager.presentWorkerSelection(in: controller) { selection in
                        guard case .worker(let worker) = selection else { return }

                        worker.presentThemeSelection(in: controller)
                    }
                } else if let worker = manager.workers.first {
                    worker.presentThemeSelection(in: controller)
                }
            }

            controller.addAction(switchTheme)
        }

        let reloadFiles = UIAlertAction(title: "Reload files\(hasMultipleWorkers ? " .." : "")", style: .default) { [weak window] _ in
            guard let controller = window?.rootViewController else { return }
            if hasMultipleWorkers {
                manager.presentWorkerSelection(in: controller, allowAll: true) { selection in
                    switch selection {
                    case .all:
                        manager.reloadFiles()
                    case .worker(let worker):
                        worker.reloadFiles()
                    }
                }
            } else if let worker = manager.workers.first {
                worker.reloadFiles()
            }
        }
        controller.addAction(reloadFiles)

        let preview = UIAlertAction(title: "Preview ..", style: .default) { [weak window] _ in
            guard let controller = window?.rootViewController else { return }
            if hasMultipleWorkers {
                manager.presentWorkerSelection(in: controller) { selection in
                    guard case .worker(let worker) = selection else { return }

                    worker.presentPreview(in: controller)
                }
            } else if let worker = manager.workers.first {
                worker.presentPreview(in: controller)
            }
        }
        controller.addAction(preview)

        controller.addAction(UIAlertAction(title: "Close menu", style: UIAlertAction.Style.cancel))
        return controller
    }
}
