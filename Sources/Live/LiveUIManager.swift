//
//  LiveUIManager.swift
//  ReactantUI
//
//  Created by Tadeas Kriz on 4/25/17.
//  Copyright © 2017 Brightify. All rights reserved.
//

import UIKit
import SnapKit
import Reactant
import RxSwift
import RxCocoa

public enum WorkerSelection {
    case all
    case worker(ReactantLiveUIWorker)
}

/**
 * A class to be used as singleton - `ReactantLiveUIManager.shared`.
 *
 * Manages ComponentDefinitions and sends an event every time a componentDefinition gets updated, this is achieved through Watchers that notify the manager when a file changes.
 */
public class ReactantLiveUIManager {
    /// Shared instance of the `ReactantLiveUIManager`.
    public static let shared = ReactantLiveUIManager()
    private(set) var workers = Set<ReactantLiveUIWorker>()

    private let errorView = LiveUIErrorMessage().with(state: [:])
    private let disposeBag = DisposeBag()
    private let tokenTracker = ObservationTokenTracker()

    private weak var activeWindow: UIWindow?

    private init() {
        errorView
            .observeAction { [weak self] action in
                guard action == .dismiss, let s = self else { return }

                for worker in s.workers {
                    worker.resetErrors()
                }
            }
            .track(in: tokenTracker)
    }

    /// Activates a worker and makes him ready for use.
    public func activate(in window: UIWindow, worker: ReactantLiveUIWorker) {
        workers.insert(worker)

        errorView.removeFromSuperview()
        errorView.translatesAutoresizingMaskIntoConstraints = true
        window.addSubview(errorView)
        errorView.frame = window.bounds

        worker.activate()

        worker.updateObservable
            .subscribe(onNext: { [weak self] in
                guard let `self` = self else { return }
                self.activeWindow?.topViewController()?.updateViewConstraints()
            })
            .disposed(by: disposeBag)

        worker.errorsObservable
            .subscribe(onNext: { [weak self] errors in
                guard let `self` = self else { return }
                self.errorView.componentState = Dictionary(keyValueTuples: errors.map { ($0.path, $0.message) })
            })
            .disposed(by: disposeBag)
    }

    /// Provided the root directory is set, it reloads the component definitions from all `ui.xml` files, including subfolders for a bundle.
    public func reloadFiles(for bundle: Bundle) {
        guard let worker = workers.first(where: { $0.configuration.resourceBundle == bundle }) else { return }
        worker.reloadFiles()
    }

    /// Provided the root directory is set, it reloads the component definitions from all `ui.xml` files, including subfolders.
    public func reloadFiles() {
        workers.forEach { $0.reloadFiles() }
    }

    public func presentWorkerSelection(in controller: UIViewController, allowAll: Bool = false, handler: @escaping (WorkerSelection) -> Void) {
        let alertController = UIAlertController(title: "Select worker", message: nil, preferredStyle: .alert)
        if allowAll {
            let allWorkersAction = UIAlertAction(title: "All bundles", style: .default) { _ in handler(.all) }
            alertController.addAction(allWorkersAction)
        }

        let sortedWorkers = workers.sorted {
            guard $0.configuration.resourceBundle != Bundle.main else { return true }
            guard let bundle1Name = $0.configuration.resourceBundle.displayName,
                let bundle2Name = $1.configuration.resourceBundle.displayName
                else { return false }
            return bundle1Name < bundle2Name
        }
        for worker in sortedWorkers {
            let bundleName = worker.configuration.resourceBundle.displayName ??
                (worker.configuration.resourceBundle.bundlePath as NSString).lastPathComponent.components(separatedBy: ".")[0]
            let actionTitle: String
            if worker.configuration.resourceBundle == Bundle.main {
                actionTitle = "\(bundleName) (main)"
            } else {
                actionTitle = bundleName
            }
            let workerAction = UIAlertAction(title: actionTitle, style: .default) { _ in handler(.worker(worker)) }
            alertController.addAction(workerAction)
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in }
        alertController.addAction(cancelAction)

        controller.present(alertController, animated: true)
    }

    /**
     * Removes the error for given path if present.
     * - parameter path: `String` for which the error should be reset
     */
    public func resetError(for path: String) {
        errorView.componentState.removeValue(forKey: path)
    }

    /// Removes all errors for all paths for a bundle.
    public func resetErrors(for bundle: Bundle) {
        guard let worker = workers.first(where: { $0.configuration.resourceBundle == bundle }) else { return }
        worker.resetErrors()
    }

    /// Removes all errors for all paths.
    public func resetErrors() {
        workers.forEach { $0.resetErrors() }
    }

    /**
     * Method for logging error into the console.
     * - parameter error: `Error` to be logged
     * - parameter path: `String` describing the path for which the error should be logged
     */
    public func logError(_ error: Error, in path: String) {
        switch error {
        case let liveUiError as LiveUIError:
            logError(liveUiError.message, in: path)
        case let tokenizationError as TokenizationError:
            logError(tokenizationError.message, in: path)
        case let deserializationError as XMLDeserializationError:
            logError(deserializationError.description, in: path)
        case let watcherError as Watcher.Error:
            logError(watcherError.message, in: path)
        case let constraintParserError as ParseError:
            switch constraintParserError {
            case .message(let message):
                logError(message, in: path)
            case .unexpectedToken(let unexpectedToken):
                logError("Unexpected token `\(unexpectedToken)` encountered while parsing constraints", in: path)
            }
        case let wrappedError as ReactantLiveUIWorker.ErrorWrapper:
            logError(wrappedError.error, in: wrappedError.path)
        default:
            logError(error.localizedDescription, in: path)
        }
    }

    /**
     * Method for logging an error directly through string.
     * - parameter error: `String` describing the error to be logged
     * - parameter path: `String` describing the path for which the error should be logged
     * - NOTE: Using `logError(_ error: Error, in path: String)` is preferred to using this method.
     */
    public func logError(_ error: String?, in path: String) {
        print(error ?? "")

        if let error = error {
            errorView.componentState[path] = error
        } else {
            errorView.componentState.removeValue(forKey: path)
        }
    }
}
