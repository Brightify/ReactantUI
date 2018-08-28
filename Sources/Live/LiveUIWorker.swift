//
//  LiveUIWorker.swift
//  ReactantUI
//
//  Created by Matyáš Kříž on 24/07/2018.
//

import UIKit
import SnapKit
import Reactant
import RxSwift
import RxCocoa

internal extension BehaviorRelay {
    internal func mutate(using mutator: (inout Element) -> Void) {
        var mutableValue = value
        mutator(&mutableValue)
        accept(mutableValue)
    }
}

public class ReactantLiveUIWorker {
    private let updateSubject = PublishSubject<Void>()
    var updateObservable: Observable<Void> {
        return updateSubject.asObservable()
    }

    private let errorSubject = BehaviorRelay<[ErrorWrapper]>(value: [])
    var errorsObservable: Observable<[ErrorWrapper]> {
        return errorSubject.asObservable().distinctUntilChanged()
    }

    let configuration: ReactantLiveUIConfiguration
    var applicationDescriptionWatcher: Watcher?
    var watchers: [String: (watcher: Watcher, viewCount: Int)] = [:]
    var styleWatchers: [String: Watcher] = [:]
    var extendedEdges: [String: UIRectEdge] = [:]
    var runtimeDefinitions: [String: String] = [:]
    var definitions: [String: (definition: ComponentDefinition, loaded: Date, xmlPath: String)] = [:] {
        didSet {
            definitionsSubject.onNext(definitions)
        }
    }
    private let forceReapplyTrigger = PublishSubject<AnyObject>()
    private let definitionsSubject = ReplaySubject<[String: (definition: ComponentDefinition, loaded: Date, xmlPath: String)]>.create(bufferSize: 1)

    private var appliers: [UIView: ReactantLiveUIApplier] = [:]

    private(set) var context: ReactantLiveUIWorker.Context {
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

    var styles: [String: StyleGroup] = [:] {
        didSet {
            context.globalContext.setStyles(from: styles)
        }
    }

    var commonStyles: [Style] {
        return styles.flatMap { $0.value.styles }
    }

    var allRegisteredDefinitionNames: Set<String> {
        return Set(configuration.componentTypes.keys).union(runtimeDefinitions.keys)
    }

    private let disposeBag = DisposeBag()

    public init(configuration: ReactantLiveUIConfiguration) {
        self.configuration = configuration
        self.context = ReactantLiveUIWorker.Context(configuration: configuration, globalContext: GlobalContext())
        self.context.worker = self
    }

    public func activate() {
        watchApplicationDescription(configuration.applicationDescriptionPath)
        loadStyles(configuration.commonStylePaths)
    }

    /**
     * Method for checking view's extendedEdges field as `UIRectEdge`.
     * - parameter view: `ReactantUI` view to be checked.
     * - returns: `UIRectEdge` (can be empty if no edges are found)
     */
    public func extendedEdges<UI: UIView>(of view: UI) -> UIRectEdge where UI: ReactantUI {
        return extendedEdges[view.__rui.xmlPath] ?? []
    }

    /**
     * Method for registering a new view to Watchlist. It will get updated as its `ui.xml` file changes.
     * - parameter view: `ReactantUI` view to be registered
     * - parameter setConstraint: Closure to be called when constraining the view
     */
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
                        self.updateSubject.onNext(())
                    } catch let error {
                        self.logError(error, in: path)
                    }
                })
                .disposed(by: disposeBag)
        } else {
            watchers[xmlPath]?.viewCount += 1
        }

        let reapplyTrigger = forceReapplyTrigger.filter { $0 === view }
        observeDefinition(for: view.__rui.typeName)
            .flatMapLatest { definition in
                Observable.concat(.just(definition), reapplyTrigger.map { _ in definition })
            }
            .observeOn(MainScheduler.instance)
            .takeUntil((view as UIView).rx.deallocated)
            .subscribe(onNext: { [weak view] definition in
                guard let view = view else { return }
                do {
                    try self.apply(definition: definition, view: view, setConstraint: setConstraint)
                } catch let error {
                    self.logError(error, in: xmlPath)
                }
            })
            .disposed(by: disposeBag)
    }

    public func reapply<UI: UIView>(_ view: UI) where UI: ReactantUI {
        forceReapplyTrigger.onNext(view)
    }

    /**
     * Method used to unregister a view from Watchlist.
     * - parameter ui: `ReactantUI` view to be unregistered
     */
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

    private func registerDefinitions(in file: String) throws {
        let newDefinitions = try self.componentDefinitions(in: file)
        var currentDefinitions = self.definitions
        for definition in newDefinitions {
            currentDefinitions[definition.type] = (definition, Date(), file)
        }
        self.definitions = currentDefinitions
    }

    private func apply(definition: ComponentDefinition, view: UIView, setConstraint: @escaping (String, SnapKit.Constraint) -> Bool) throws {
        let componentContext = ComponentContext(globalContext: context.globalContext, component: definition)
        let uiApplier = appliers[view, default: ReactantLiveUIApplier(workerContext: context)]
        try uiApplier.apply(context: componentContext, commonStyles: commonStyles, view: view, setConstraint: setConstraint)
        if let invalidable = view as? Invalidable {
            invalidable.invalidate()
        }
    }

    func loadStyles(_ stylePaths: [String]) {
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
                    })
                    .disposed(by: disposeBag)

                styleWatchers[path] = watcher
            }
        }
    }

    func watchApplicationDescription(_ path: String?) {
        guard let path = path, applicationDescriptionWatcher == nil else { return }

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
            .subscribe(onNext: { [unowned self] path in
                self.resetError(for: path)
                let url = URL(fileURLWithPath: path)
                guard let data = try? Data(contentsOf: url, options: .uncached) else {
                    self.logError("ERROR: file not found", in: path)
                    return
                }
                let xml = SWXMLHash.parse(data)
                do {
                    var globalContextCopy = self.context.globalContext
                    globalContextCopy.applicationDescription = try xml["Application"].value()
                    if !globalContextCopy.applicationDescription.themes.contains(globalContextCopy.currentTheme) {
                        globalContextCopy.currentTheme = globalContextCopy.applicationDescription.defaultTheme
                    }
                    self.context.globalContext = globalContextCopy
                } catch let error {
                    self.logError(error, in: path)
                }
            })
            .disposed(by: disposeBag)

        applicationDescriptionWatcher = watcher
    }

    func reloadFiles() {
        let rootDir = configuration.rootDir
        guard let enumerator = FileManager.default.enumerator(atPath: rootDir) else { return }
        for file in enumerator {
            guard let fileName = file as? String, fileName.hasSuffix(".ui.xml") else { continue }
            let path = rootDir + "/" + fileName
            if configuration.componentTypes.keys.contains(path) { continue }
            do {
                let definitions = try self.componentDefinitions(in: path)
                for definition in definitions {
                    runtimeDefinitions[definition.type] = path
                }
            } catch let error {
                logError(error, in: path)
            }
        }
    }

    func componentDefinitions(in file: String) throws -> [ComponentDefinition] {
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

    public func setSelectedTheme(name: String) {
        context.globalContext.currentTheme = name
    }

    private func logError(_ error: Error, in path: String) {
        errorSubject.mutate {
            $0.append(ErrorWrapper(error, in: path))
        }
    }

    private func logError(_ message: String, in path: String) {
        errorSubject.mutate {
            $0.append(ErrorWrapper(message, in: path))
        }
    }

    func resetErrors() {
        errorSubject.accept([])
    }

    /**
     * Removes the error for given path if present.
     * - parameter path: `String` for which the error should be reset
     */
    public func resetError(for path: String) {
        errorSubject.mutate {
            guard let index = $0.index(where: { $0.path == path }) else { return }
            $0.remove(at: index)
        }
    }

    internal func observeDefinition(for type: String) -> Observable<ComponentDefinition> {
        return definitionsSubject
            .map { $0[type] }
            .distinctUntilChanged { $0?.loaded == $1?.loaded }
            .flatMap {
                $0.map { Observable.just($0.definition) } ?? .empty()
            }
    }

    func presentThemeSelection(in controller: UIViewController) {
        let alertController = UIAlertController(title: "Select theme", message: nil, preferredStyle: .alert)

        for theme in context.globalContext.applicationDescription.themes {
            let actionTitle: String
            if theme == context.globalContext.applicationDescription.defaultTheme {
                actionTitle = "\(theme) (default)"
            } else {
                actionTitle = theme
            }
            let themeAction = UIAlertAction(title: actionTitle, style: .default) { [weak self] _ in
                self?.context.globalContext.currentTheme = theme
            }
            alertController.addAction(themeAction)
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in }
        alertController.addAction(cancelAction)

        controller.present(alertController, animated: true)
    }

    /**
     * Presents the preview inside passed controller.
     * - parameter controller: `UIViewController` to be presented in
     */
    public func presentPreview(in controller: UIViewController) {
        let navigation = UINavigationController()
        let dependencies = PreviewListController.Dependencies(worker: self)
        let reactions = PreviewListController.Reactions(
            preview: { name in
                navigation.push(controller: self.preview(for: name))
        },
            close: {
                navigation.dismiss(animated: true)
        })
        let previewList = PreviewListController(dependencies: dependencies, reactions: reactions)
        navigation.push(controller: previewList)
        controller.present(navigation, animated: true)
    }

    private func preview(for name: String) -> PreviewController {
        let parameters = PreviewController.Parameters(
            typeName: name,
            // FIXME handle possible errors
            view: try! context.componentInstantiation(named: name)())
        return PreviewController(parameters: parameters)
    }
}

extension ReactantLiveUIWorker: Hashable {
    public var hashValue: Int {
        return configuration.resourceBundle.hashValue
    }

    public static func ==(lhs: ReactantLiveUIWorker, rhs: ReactantLiveUIWorker) -> Bool {
        return lhs.hashValue == rhs.hashValue
    }
}

extension ReactantLiveUIWorker {
    public struct Context: DataContext {
        public var configuration: ReactantLiveUIConfiguration
        public var globalContext: GlobalContext
        public weak var worker: ReactantLiveUIWorker?

        public var resourceBundle: Bundle? {
            return configuration.resourceBundle
        }

        public init(configuration: ReactantLiveUIConfiguration, globalContext: GlobalContext, worker: ReactantLiveUIWorker? = nil) {
            self.configuration = configuration
            self.globalContext = globalContext
            self.worker = worker
        }

        public func componentInstantiation(named name: String) throws -> () -> UIView {
            if let precompiledType = configuration.componentTypes[name] {
                return precompiledType.init
            } else if let strongWorker = worker, let definition = strongWorker.definitions[name] {
                return {
                    AnonymousComponent(typeName: definition.definition.type, xmlPath: definition.xmlPath, worker: strongWorker)
                }
            } else {
                throw LiveUIError(message: "ERROR: Unable to find instantiation mapping for component \(name) in bundle \(configuration.resourceBundle.name)")
            }
        }

        public func resolvedStyleName(named styleName: StyleName) -> String {
            return globalContext.resolvedStyleName(named: styleName)
        }

        public func style(named styleName: StyleName) -> Style? {
            return globalContext.style(named: styleName)
        }

        public func themed(image name: String) -> Image? {
            return globalContext.themed(image: name)
        }

        public func themed(color name: String) -> UIColorPropertyType? {
            return globalContext.themed(color: name)
        }

        public func themed(font name: String) -> Font? {
            return globalContext.themed(font: name)
        }
    }
}

extension ReactantLiveUIWorker {
    struct ErrorWrapper: Error, Equatable {
        let error: Error
        let path: String
        let message: String

        init(_ error: Error, in path: String) {
            self.error = error
            self.path = path
            self.message = ErrorWrapper.formMessage(from: error)
        }

        init(_ message: String, in path: String) {
            self.error = LiveUIError(message: message)
            self.path = path
            self.message = message
        }

        private static func formMessage(from error: Error) -> String {
            switch error {
            case let liveUiError as LiveUIError:
                return liveUiError.message
            case let tokenizationError as TokenizationError:
                return tokenizationError.message
            case let deserializationError as XMLDeserializationError:
                return deserializationError.description
            case let watcherError as Watcher.Error:
                return watcherError.message
            case let constraintParserError as ParseError:
                switch constraintParserError {
                case .message(let message):
                    return message
                case .unexpectedToken(let unexpectedToken):
                    return "Unexpected token `\(unexpectedToken)` encountered while parsing constraints"
                }
            case let wrappedError as ReactantLiveUIWorker.ErrorWrapper:
                return formMessage(from: wrappedError.error)
            default:
                return error.localizedDescription
            }
        }

        // for `Observable.distinctUntilChanged()`
        static func ==(lhs: ReactantLiveUIWorker.ErrorWrapper, rhs: ReactantLiveUIWorker.ErrorWrapper) -> Bool {
            return lhs.error.localizedDescription == rhs.error.localizedDescription && lhs.path == rhs.path
        }
    }
}
