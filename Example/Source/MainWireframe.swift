//
//  MainWireframe.swift
//  Example
//
//  Created by Matouš Hýbl on 09/03/2018.
//

import Hyperdrive

final class MainWireframe: Wireframe {

    func entrypoint() -> UIViewController {
        return UINavigationController(rootViewController: exampleSelection())
    }

    func exampleSelection() -> ExampleSelectionController {
        return create { provider in
            let reactions = ExampleSelectionController.Reactions(
                exampleSelected: {
                    switch $0 {
                    case .playground:
                        provider.navigation?.pushViewController(self.playground(), animated: true)
                    case .plainTableView:
                        provider.navigation?.pushViewController(self.plainTableViewController(), animated: true)
                    case .headerTableView:
                        provider.navigation?.pushViewController(self.headerTableView(), animated: true)
                    case .footerTableView:
                        provider.navigation?.pushViewController(self.footerTableView(), animated: true)
                    case .simpleTableView:
                        provider.navigation?.pushViewController(self.simpleTableView(), animated: true)
                    case .simulatedSeparatorTableView:
                        provider.navigation?.pushViewController(self.simulatedSeparatorTableView(), animated: true)
                    case .stackView:
                        provider.navigation?.pushViewController(self.stackViewController(), animated: true)
                    case .progressView:
                        provider.navigation?.pushViewController(self.progressViewController(), animated: true)
                    }
                }
            )

            return ExampleSelectionController(reactions: reactions)
        }
    }

    private func playground() -> UIViewController {
        return ViewController()
    }

    private func plainTableViewController() -> PlainTableViewController {
        return PlainTableViewController()
    }

    private func headerTableView() -> UIViewController {
        return HeaderTableViewController { HeaderTableViewRootView(initialState: ())) }
    }

    private func footerTableView() -> UIViewController {
        return FooterTableViewController(root)
    }

    private func simpleTableView() -> UIViewController {
        return SimpleTableViewController()
    }

    private func simulatedSeparatorTableView() -> UIViewController {
        return SimulatedSeparatorTableViewController()
    }

    private func stackViewController() -> StackViewController {
        return StackViewController()
    }

    private func progressViewController() -> ProgressViewController {
        return ProgressViewController()
    }
}
