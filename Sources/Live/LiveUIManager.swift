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

private struct WeakUIBox {
    weak var ui: ReactantUI?
    /// Workaround for non-existent class existentials
    weak var view: UIView?

    init<UI: UIView>(ui: UI) where UI: ReactantUI {
        self.ui = ui
        self.view = ui
    }
}

extension WeakUIBox: Equatable {

    static func ==(lhs: WeakUIBox, rhs: WeakUIBox) -> Bool {
        return lhs.ui === rhs.ui
    }
}

public class ReactantLiveUIManager {
    public static let shared = ReactantLiveUIManager()

    private var configuration: ReactantLiveUIConfiguration?
    private var watchers: [String: (watcher: Watcher, viewCount: Int)] = [:]
    private var styleWatchers: [String: Watcher] = [:]
    private var extendedEdges: [String: UIRectEdge] = [:]
    private var runtimeDefinitions: [String: String] = [:]
    private var definitions: [String: (definition: ComponentDefinition, loaded: Date, xmlPath: String)] = [:] {
        didSet {
            definitionsSubject.onNext(definitions)
        }
    }
    private let definitionsSubject = ReplaySubject<[String: (definition: ComponentDefinition, loaded: Date, xmlPath: String)]>.create(bufferSize: 1)
    
    public var onApplied: ((ComponentDefinition, UIView) -> Void)?

    private var styles: [String: StyleGroup] = [:] {
        didSet {
            resetErrors()
            let now = Date()
            var definitionsCopy = definitions
            for key in definitionsCopy.keys {
                definitionsCopy[key]?.loaded = now
            }
            definitions = definitionsCopy
        }
    }

    private let errorView = LiveUIErrorMessage().with(state: [:])
    private let disposeBag = DisposeBag()

    private weak var activeWindow: UIWindow?

    private init() {
        errorView.action
            .filter { $0 == .dismiss }
            .subscribe(onNext: { [weak self] _ in
                self?.resetErrors()
            })
            .addDisposableTo(disposeBag)
    }

    public var commonStyles: [Style] {
        return styles.values.flatMap { $0.styles }
    }

    var allRegisteredDefinitionNames: [String] {
        let configurationNames: Set<String>
        if let configuration = configuration {
            configurationNames = Set(configuration.componentTypes.keys)
        } else {
            configurationNames = []
        }
        return configurationNames.union(runtimeDefinitions.keys).sorted()
    }

    public func activate(in window: UIWindow, configuration: ReactantLiveUIConfiguration) {
        self.configuration = configuration
        self.activeWindow = window
        errorView.removeFromSuperview()
        errorView.translatesAutoresizingMaskIntoConstraints = true
        window.addSubview(errorView)
        errorView.frame = window.bounds

        loadStyles(configuration.commonStylePaths)
    }

    public func extendedEdges<UI: UIView>(of view: UI) -> UIRectEdge where UI: ReactantUI {
        return extendedEdges[view.__rui.xmlPath] ?? []
    }

    public func reloadFiles() {
        guard let rootDir = configuration?.rootDir else { return }
        guard let enumerator = FileManager.default.enumerator(atPath: rootDir) else { return }
        for file in enumerator {
            guard let fileName = file as? String, fileName.hasSuffix(".ui.xml") else { continue }
            let path = rootDir + "/" + fileName
            if let configuration = configuration, configuration.componentTypes.keys.contains(path) { continue }
            do {
                let definitions = try self.definitions(in: path)
                for definition in definitions {
                    runtimeDefinitions[definition.type] = path
                }
            } catch let error {
                logError(error, in: path)
            }
        }
    }

    public func presentPreview(in controller: UIViewController) {
        let navigation = UINavigationController()
        let dependencies = PreviewListController.Dependencies(manager: self)
        let reactions = PreviewListController.Reactions(
            preview: { name in
                navigation.push(controller: self.preview(for: name))
            },
            close: {
                navigation.dismiss(animated: true)
            })
        let previewList = PreviewListController(dependencies: dependencies, reactions: reactions)
        navigation.push(controller: previewList)
        controller.present(controller: navigation)
    }

    private func preview(for name: String) -> PreviewController {
        let parameters = PreviewController.Parameters(
            typeName: name,
            // FIXME handle possible errors
            view: try! componentInstantiation(named: name)())
        return PreviewController(parameters: parameters)

    }

    private func definitions(in file: String) throws -> [ComponentDefinition] {
        let url = URL(fileURLWithPath: file)
        guard let data = try? Data(contentsOf: url, options: .uncached) else {
            throw LiveUIError(message: "ERROR: file not found")
        }
        let xml = SWXMLHash.parse(data)

        guard let node = xml["Component"].element else { throw LiveUIError(message: "ERROR: Node is not Component") }
        var rootDefinition: ComponentDefinition

        if let type: String = xml["Component"].value(ofAttribute: "type") {
            rootDefinition = try ComponentDefinition(node: node, type: type)
        } else {
            rootDefinition = try ComponentDefinition(node: node, type: componentType(from: file))
        }

        if rootDefinition.isRootView {
            extendedEdges[file] = rootDefinition.edgesForExtendedLayout.resolveUnion()
        } else {
            extendedEdges.removeValue(forKey: file)
        }

        return rootDefinition.componentDefinitions
    }

    private func registerDefinitions(in file: String) throws {
        let definitions = try self.definitions(in: file)
        register(definitions: definitions, in: file)
    }

    internal func type(named name: String) -> UIView.Type? {
        return configuration?.componentTypes[name]
    }

    internal func componentInstantiation(named name: String) throws -> () -> UIView {
        if let precompiledType = configuration?.componentTypes[name] {
            return precompiledType.init
        } else if let definition = definitions[name] {
            return {
                AnonymousComponent(typeName: definition.definition.type, xmlPath: definition.xmlPath)
            }
        } else {
            throw TokenizationError(message: "Couldn't find type mapping for \(name)")
        }
    }

    internal func observeDefinition(for type: String) -> Observable<ComponentDefinition> {
        return definitionsSubject.map { $0[type] }
            .distinctUntilChanged { $0?.loaded == $1?.loaded }
            .filter { $0 != nil }.map { $0!.definition }

    }

    public func register<UI: UIView>(_ view: UI, setConstraint: @escaping (String, SnapKit.Constraint) -> Bool = { _, _ in false }) where UI: ReactantUI {
        let xmlPath = view.__rui.xmlPath
        if !watchers.keys.contains(xmlPath) {
            let watcher: Watcher
            do {
                watcher = try Watcher(path: xmlPath)
            } catch let error {
                logError(error, in: xmlPath)
                return
            }

            watchers[xmlPath] = (watcher: watcher, viewCount: 1)

            watcher.watch()
                .startWith(xmlPath)
                .subscribe(onNext: { path in
                    self.resetError(for: path)
                    do {
                        try self.registerDefinitions(in: path)

                        self.activeWindow?.topViewController()?.updateViewConstraints()
                    } catch let error {
                        self.logError(error, in: path)
                    }
                })
                .addDisposableTo(disposeBag)


        } else {
            watchers[xmlPath]?.viewCount += 1
        }
        observeDefinition(for: view.__rui.typeName)
            .observeOn(MainScheduler.asyncInstance)
            .takeUntil((view as UIView).rx.deallocated)
            .subscribe(onNext: { [weak view] definition in
                guard let view = view else { return }
                do {
                    try self.apply(definition: definition, view: view, setConstraint: setConstraint)
                } catch let error {
                    self.logError(error, in: xmlPath)
                }
            })
            .addDisposableTo(disposeBag)
    }

    public func unregister<UI: UIView>(_ ui: UI) where UI: ReactantUI {
        let xmlPath = ui.__rui.xmlPath
        guard let watcher = watchers[xmlPath] else {
            logError("ERROR: attempting to remove not registered UI", in: xmlPath)
            return
        }
        if watcher.viewCount == 1 {
            watchers.removeValue(forKey: xmlPath)
        } else {
            watchers[xmlPath]?.viewCount -= 1
        }
    }

    private func loadStyles(_ stylePaths: [String]) {
        for path in stylePaths {
            if styleWatchers.keys.contains(path) == false {

            let watcher: Watcher
            do {
                watcher = try Watcher(path: path)
            } catch let error {
                logError(error, in: path)
                return
            }

            watcher
                .watch()
                .startWith(path)
                .subscribe(onNext: { path in
                    self.resetError(for: path)
                    let url = URL(fileURLWithPath: path)
                    guard let data = try? Data(contentsOf: url, options: .uncached) else {
                        self.logError("ERROR: file not found", in: path)
                        return
                    }
                    let xml = SWXMLHash.parse(data)
                    do {
                        var oldStyles = self.styles
                        let group: StyleGroup = try xml["styleGroup"].value()
                        oldStyles[group.name] = group
                        self.styles = oldStyles
                    } catch let error {
                        self.logError(error, in: path)
                    }
                }).addDisposableTo(disposeBag)

                styleWatchers[path] = watcher
            }
        }
    }

    public func resetError(for path: String) {
        errorView.componentState.removeValue(forKey: path)
    }

    public func resetErrors() {
        errorView.componentState.removeAll()
    }

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
        default:
            logError(error.localizedDescription, in: path)
        }
    }

    public func logError(_ error: String?, in path: String) {
        print(error ?? "")

        if let error = error {
            errorView.componentState[path] = error
        } else {
            errorView.componentState.removeValue(forKey: path)
        }
    }

    private func register(definitions: [ComponentDefinition], in file: String) {
        var currentDefinitions = self.definitions
        for definition in definitions {
            currentDefinitions[definition.type] = (definition, Date(), file)
        }
        self.definitions = currentDefinitions
    }

    private func apply(definition: ComponentDefinition, view: UIView, setConstraint: @escaping (String, SnapKit.Constraint) -> Bool) throws {
        try ReactantLiveUIApplier(definition: definition, commonStyles: commonStyles, instance: view, setConstraint: setConstraint, onApplied: onApplied).apply()
        if let invalidable = view as? Invalidable {
            invalidable.invalidate()
        }
    }
}
