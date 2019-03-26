//
//  GenerateCommand.swift
//  ReactantUI
//
//  Created by Matouš Hýbl on 16/02/2018.
//

#if canImport(Common)
import Common
#endif
import Generator
import Tokenizer
import Foundation
import xcodeproj
import SwiftCLI

public enum GenerateCommandError: Error, LocalizedError {
    case inputPathInvalid
    case ouputFileInvalid
    case applicationDescriptionFileInvalid
    case XCodeProjectPathInvalid
    case cannotReadXCodeProj
    case invalidType(String)
    case tokenizationError(path: String, error: Error)
    case invalidSwiftVersion
    case themedItemNotFound(theme: String, item: String)
    case invalidAccessModifier

    public var localizedDescription: String {
        switch self {
        case .inputPathInvalid:
            return "Input path is invalid."
        case .ouputFileInvalid:
            return "Output file path is invalid."
        case .applicationDescriptionFileInvalid:
            return "Application description file path is invalid."
        case .XCodeProjectPathInvalid:
            return "xcodeproj path is invalid."
        case .cannotReadXCodeProj:
            return "Cannot read xcodeproj."
        case .invalidType(let path):
            return "Invalid Component type at path: \(path) - do not use keywords.";
        case .tokenizationError(let path, let error):
            return "Tokenization error in file: \(path), error: \(error)"
        case .invalidSwiftVersion:
            return "Invalid Swift version"
        case .themedItemNotFound(let theme, let item):
            return "Missing item `\(item) in theme \(theme)."
        case .invalidAccessModifier:
            return "Invalid access modifier"
        }
    }

    public var errorDescription: String? {
        return localizedDescription
    }
}

class GenerateCommand: Command {

    static let forbiddenNames = ["RootView", "UIView", "UIViewController", "self", "switch",
                                 "if", "else", "guard", "func", "class", "ViewBase", "ControllerBase", "for"]

    let name = "generate"
    let shortDescription = "Generate Swift UI code from XMLs"
    let enableLive = Flag("--enable-live")

    let xcodeProjectPath = Key<String>("--xcodeprojPath")
    let inputPath = Key<String>("--inputPath")
    let outputFile = Key<String>("--outputFile")
    let applicationDescriptionFile = Key<String>("--description", description: "Path to an XML file with Application Description.")
    let swiftVersionParameter = Key<String>("--swift")
    let defaultAccessModifier = Key<String>("--defaultAccessModifier")
    let generateDisposableHelper = Flag("--generate-disposable-helper")

    public func execute() throws {
        var output: [String] = []

        guard let inputPath = inputPath.value else {
            throw GenerateCommandError.inputPathInvalid
        }
        let inputPathURL = URL(fileURLWithPath: inputPath)

        guard let outputFile = outputFile.value else {
            throw GenerateCommandError.ouputFileInvalid
        }
        let outputPathURL = URL(fileURLWithPath: outputFile)

        let rawSwiftVersion = swiftVersionParameter.value ?? "4.1" // use 4.1 as default
        guard let swiftVersion = SwiftVersion(raw: rawSwiftVersion) else {
            throw GenerateCommandError.invalidSwiftVersion
        }

        let rawModifier = defaultAccessModifier.value ?? AccessModifier.internal.rawValue
        guard let accessModifier = AccessModifier(rawValue: rawModifier) else {
            throw GenerateCommandError.invalidAccessModifier
        }

        // ApplicationDescription is not required. We can work with default values and it makes it backward compatible.
        let applicationDescription: ApplicationDescription
        let applicationDescriptionPath = applicationDescriptionFile.value
        if let applicationDescriptionPath = applicationDescriptionPath {
            let applicationDescriptionData = try Data(contentsOf: URL(fileURLWithPath: applicationDescriptionPath))
            let xml = SWXMLHash.parse(applicationDescriptionData)
            if let node = xml["Application"].element {
                applicationDescription = try ApplicationDescription(node: node)
            } else {
                print("warning: ReactantUIGenerator: No <Application> element inside the application path!")
                return
                // FIXME: uncomment and delete the above when merged with `feature/logger` branch
//                Logger.instance.warning("Application file path does not contain the <Application> element.")
            }
        } else {
            applicationDescription = ApplicationDescription()
        }

        let minimumDeploymentTarget = try self.minimumDeploymentTarget()

        let uiXmlEnumerator = FileManager.default.enumerator(atPath: inputPath)
        let uiFiles = uiXmlEnumerator?.compactMap { $0 as? String }.filter { $0.hasSuffix(".ui.xml") }
            .map { inputPathURL.appendingPathComponent($0).path } ?? []

        let styleXmlEnumerator = FileManager.default.enumerator(atPath: inputPath)
        let styleFiles = styleXmlEnumerator?.compactMap { $0 as? String }.filter { $0.hasSuffix(".styles.xml") }
            .map { inputPathURL.appendingPathComponent($0).path } ?? []

        // path with the stylegroup associated with it
        var globalContextFiles = [] as [(path: String, group: StyleGroup)]
        var stylePaths = [] as [String]
        for path in styleFiles {
            output.append("// Generated from \(path)")
            let data = try Data(contentsOf: URL(fileURLWithPath: path))

            let xml = SWXMLHash.parse(data)
            let group: StyleGroup = try xml["styleGroup"].value()
            globalContextFiles.append((path, group))
            stylePaths.append(path)
        }

        let globalContext = GlobalContext(applicationDescription: applicationDescription,
                                          currentTheme: applicationDescription.defaultTheme,
                                          styleSheets: globalContextFiles.map { $0.group })
        for (offset: index, element: (path: path, group: group)) in globalContextFiles.enumerated() {
            let configuration = GeneratorConfiguration(minimumMajorVersion: minimumDeploymentTarget,
                                                       localXmlPath: path,
                                                       isLiveEnabled: enableLive.value,
                                                       swiftVersion: swiftVersion,
                                                       defaultModifier: accessModifier)
            let styleContext = StyleGroupContext(globalContext: globalContext, group: group)
            output.append(try StyleGenerator(context: styleContext, configuration: configuration).generate(imports: index == 0))
        }

        var componentTypes: [String] = []
        var componentDefinitions: [String: ComponentDefinition] = [:]
        var imports: Set<String> = []
        for path in uiFiles {
            let data = try Data(contentsOf: URL(fileURLWithPath: path))

            let xml = SWXMLHash.parse(data)

            guard let node = xml["Component"].element else { continue }
            var definition: ComponentDefinition
            do {
                if let type: String = xml["Component"].value(ofAttribute: "type") {
                    definition = try ComponentDefinition(node: node, type: type)
                } else {
                    definition = try ComponentDefinition(node: node, type: componentType(from: path))
                }
                if GenerateCommand.forbiddenNames.contains(definition.type) {
                    throw GenerateCommandError.invalidType(path)
                }
            } catch let error {
                throw GenerateCommandError.tokenizationError(path: path, error: error)
            }
            componentTypes.append(contentsOf: definition.componentTypes)
            componentDefinitions[path] = definition
            imports.formUnion(definition.requiredImports)
            imports.formUnion(definition.styles.map { $0.parentModuleImport })
        }

        output.append("""
              import UIKit
              import Reactant
              import ReactantUI
              import SnapKit
              """)

        try output.append(theme(context: globalContext, swiftVersion: swiftVersion))

        if enableLive.value {
            output.append(ifSimulator(swiftVersion: swiftVersion, ifClause: "import ReactantLiveUI"))
        }
        for imp in imports {
            output.append("import \(imp)")
        }

        output.append("""
        private final class __ReactantUIBundleToken { }
        private let __resourceBundle = Bundle(for: __ReactantUIBundleToken.self)
        """)

        for (path, rootDefinition) in componentDefinitions {
            output.append("// Generated from \(path)")
            let configuration = GeneratorConfiguration(minimumMajorVersion: minimumDeploymentTarget,
                                                       localXmlPath: path,
                                                       isLiveEnabled: enableLive.value,
                                                       swiftVersion: swiftVersion,
                                                       defaultModifier: accessModifier)
            for definition in rootDefinition.componentDefinitions {
                let componentContext = ComponentContext(globalContext: globalContext, component: definition)
                output.append(try UIGenerator(componentContext: componentContext, configuration: configuration).generate(imports: false))
            }
        }

        if enableLive.value {
            let generatedApplicationDescriptionPath = applicationDescriptionPath.map { "\"\($0)\"" } ?? "nil"
            if swiftVersion < .swift4_1 {
                output.append("#if (arch(i386) || arch(x86_64)) && (os(iOS) || os(tvOS))")
            } else {
                output.append("#if targetEnvironment(simulator)")
            }
            output.append("""
                      struct GeneratedReactantLiveUIConfiguration: ReactantLiveUIConfiguration {
                      let applicationDescriptionPath: String? = \(generatedApplicationDescriptionPath)
                      let rootDir = \"\(inputPath)\"
                      let resourceBundle: Bundle = __resourceBundle
                      let commonStylePaths: [String] = [
                  """)
            for path in stylePaths {
                output.append("        \"\(path)\",")
            }
            output.append("    ]")

            if componentTypes.isEmpty {
                output.append("    let componentTypes: [String: UIView.Type] = [:]")
            } else {
                output.append("    let componentTypes: [String: UIView.Type] = [")
                // filter out empty component types - these components are initialized in code, so they should already be included if they use RUI
                for type in Set(componentTypes) {
                    output.append("        \"\(type)\": \(type).self,")
                }
                output.append("    ]")
            }
            output.append("""
                  }
                  #endif
                  """)
        }

        if enableLive.value {
            output.append(ifSimulator(swiftVersion: swiftVersion, ifClause: "\nlet bundleWorker = ReactantLiveUIWorker(configuration: GeneratedReactantLiveUIConfiguration())\n"))
        }
                          
        output.append("public func activateLiveReload(in window: UIWindow) {")
        if enableLive.value {
            let liveUIActivation = """
                ReactantLiveUIManager.shared.activate(in: window, worker: bundleWorker)
                ApplicationTheme.selector.register(target: bundleWorker, listener: { theme in
                    bundleWorker.setSelectedTheme(name: theme.name)
                })
            """

            output.append(ifSimulator(swiftVersion: swiftVersion, ifClause: liveUIActivation))
        }
        output.append("}")

        try output.joined(separator: "\n").write(to: outputPathURL, atomically: true, encoding: .utf8)
    }

    private func theme(context: GlobalContext, swiftVersion: SwiftVersion) throws -> String {
        let description = context.applicationDescription
        func allCases<T>(item: String, from container: ThemeContainer<T>) throws -> String {
            return try description.themes.map { theme in
                guard let themedItem = container[theme: theme, item: item] else {
                    throw GenerateCommandError.themedItemNotFound(theme: theme, item: item)
                }
                let typeContext = SupportedPropertyTypeContext(parentContext: context, value: themedItem)
                return "case .\(theme): return \(themedItem.generate(context: typeContext))"
            }.joined(separator: "\n")
        }

        let cases = description.themes.map {
            "    case \($0)"
        }.joined(separator: "\n")

        let allColorsSorted = try description.colors.allItemNames.sorted().map { """
            public var \($0): UIColor {
                switch theme {
                \(try allCases(item: $0, from: description.colors))
                }
            }
            """
        }
        let allImagesSorted = try description.images.allItemNames.sorted().map { """
            public var \($0): UIImage? {
                switch theme {
                \(try allCases(item: $0, from: description.images))
                }
            }
            """
        }
        let allFontsSorted = try description.fonts.allItemNames.sorted().map { """
            public var \($0): UIFont {
                switch theme {
                \(try allCases(item: $0, from: description.fonts))
                }
            }
            """
        }

        let rxSwiftShim: String
        // canImport is only available from 4.1 and above
        if swiftVersion >= .swift4_1 && generateDisposableHelper.value {
            rxSwiftShim = """
            #if canImport(RxSwift)
            import RxSwift

            extension ReactantThemeSelector.ListenerToken: Disposable {
                public func dispose() {
                    cancel()
                }
            }
            #endif
            """
        } else {
            rxSwiftShim = ""
        }

        return """

        public enum ApplicationTheme: String, ReactantThemeDefinition {
            public static var current: ApplicationTheme {
                return selector.currentTheme
            }

            public static let selector = ReactantThemeSelector<ApplicationTheme>(defaultTheme: .\(description.defaultTheme))

        \(cases)

            public struct Colors {
                fileprivate let theme: ApplicationTheme

            \(allColorsSorted.joined(separator: "\n"))
            }
            public struct Images {
                fileprivate let theme: ApplicationTheme

            \(allImagesSorted.joined(separator: "\n"))
            }
            public struct Fonts {
                fileprivate let theme: ApplicationTheme

            \(allFontsSorted.joined(separator: "\n"))
            }

            public var colors: Colors {
                return Colors(theme: self)
            }

            public var images: Images {
                return Images(theme: self)
            }

            public var fonts: Fonts {
                return Fonts(theme: self)
            }
        }

        \(rxSwiftShim)
        """
    }

    private func minimumDeploymentTarget() throws -> Int {
        guard let xcodeProjectPathsString = xcodeProjectPath.value, let xcprojpath = URL(string: xcodeProjectPathsString) else {
            throw GenerateCommandError.XCodeProjectPathInvalid
        }

        guard let project = try? XcodeProj(pathString: xcprojpath.absoluteURL.path) else {
            throw GenerateCommandError.cannotReadXCodeProj
        }

        return project.pbxproj.buildConfigurations
            .compactMap { config -> Substring? in
                let value = (config.buildSettings["TVOS_DEPLOYMENT_TARGET"] ?? config.buildSettings["IPHONEOS_DEPLOYMENT_TARGET"]) as? String

                return value?.split(separator: ".").first
            }
            .compactMap { Int(String($0)) }.reduce(50) { previous, new in
                return previous < new ? previous : new
        }
    }

    private func ifSimulator(swiftVersion: SwiftVersion, ifClause: String, elseClause: String? = nil) -> String {
        let elseCode: String
        if let elseClause = elseClause {
            elseCode = """
            #else
            \(elseClause)
            """
        } else {
            elseCode = ""
        }

        if swiftVersion >= .swift4_1 {
            return """
            #if targetEnvironment(simulator)
            \(ifClause)
            \(elseCode)
            #endif
            """
        } else {
            return """
            #if (arch(i386) || arch(x86_64)) && (os(iOS) || os(tvOS))
            \(ifClause)
            \(elseCode)
            #endif
            """
        }
    }
}
