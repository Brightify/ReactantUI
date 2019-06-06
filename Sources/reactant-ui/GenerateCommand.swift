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

import SwiftCodeGen

public enum GenerateCommandError: Error, LocalizedError {
    case inputPathInvalid
    case ouputFileInvalid
    case applicationDescriptionFileInvalid
    case XCodeProjectPathInvalid
    case cannotReadXCodeProj(Error)
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
        case .cannotReadXCodeProj(let error):
            return "Cannot read xcodeproj." + error.localizedDescription
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

extension RuntimePlatform: ConvertibleFromString {
    public static func convert(from: String) -> RuntimePlatform? {
        switch from.lowercased() {
        case "ios":
            return .iOS
        case "tvos":
            return .tvOS
        default:
            return nil
        }
    }
}

class GenerateCommand: Command {

    enum Output {
        case file(URL)
        case console
    }

    static let forbiddenNames = ["RootView", "UIView", "UIViewController", "self", "switch",
                                 "if", "else", "guard", "func", "class", "ViewBase", "ControllerBase", "for"]

    let name = "generate"
    let shortDescription = "Generate Swift UI code from XMLs"
    let enableLive = Flag("--enable-live")

    let xcodeProjectPath = Key<String>("--xcodeprojPath")
    let inputPath = Key<String>("--inputPath")
    let outputFile = Key<String>("--outputFile")
    let consoleOutput = Flag("--console-output")
    let applicationDescriptionFile = Key<String>("--description", description: "Path to an XML file with Application Description.")
    let swiftVersionParameter = Key<String>("--swift")
    let platform = Key<RuntimePlatform>("--platform") //, completion: .values(RuntimePlatform.allCases))
    let defaultAccessModifier = Key<String>("--defaultAccessModifier")
    let generateDisposableHelper = Flag("--generate-disposable-helper")

    public func execute() throws {
        let output = DescriptionPipe()

        guard let inputPath = inputPath.value else {
            throw GenerateCommandError.inputPathInvalid
        }
        let inputPathURL = URL(fileURLWithPath: inputPath)

        let outputType: Output
        if let outputFile = outputFile.value {
            outputType = .file(URL(fileURLWithPath: outputFile))
        } else if (consoleOutput.value) {
            outputType = .console
        } else {
            throw GenerateCommandError.ouputFileInvalid
        }

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

        let mainContext = MainDeserializationContext(elementFactories:
            Module.mapKit.elements(for: .iOS) +
            Module.uiKit.elements(for: .iOS) +
            Module.webKit.elements(for: .iOS), referenceFactory: Module.uiKit.referenceFactory)

        // path with the stylegroup associated with it
        var globalContextFiles = [] as [(path: String, group: StyleGroup)]
        var stylePaths = [] as [String]
        for path in styleFiles {
            output.line("// Generated from \(path)")
            let data = try Data(contentsOf: URL(fileURLWithPath: path))

            let xml = SWXMLHash.parse(data)
            guard let element = xml["styleGroup"].element else { continue }
            var group: StyleGroup = try mainContext.deserialize(element: element)
            
            globalContextFiles.append((path, group))
            stylePaths.append(path)
        }

        let globalContext = GlobalContext(applicationDescription: applicationDescription,
                                          currentTheme: applicationDescription.defaultTheme,
                                          styleSheets: globalContextFiles.map { $0.group })

        var componentTypes: [String] = []
        var imports: Set<String> = []
        for path in uiFiles {
            let data = try Data(contentsOf: URL(fileURLWithPath: path))

            let xml = SWXMLHash.parse(data)

            guard let node = xml.children.first?.element else { continue }
            var definition: ComponentDefinition
            do {
//                if let type: String = xml["Component"].value(ofAttribute: "type") {
                    definition = try mainContext.deserialize(element: node, type: node.name)
//                } else {
//                    definition = try ComponentDefinition(node: node, type: componentType(from: path))
//                }
                if GenerateCommand.forbiddenNames.contains(definition.type) {
                    throw GenerateCommandError.invalidType(path)
                }
            } catch let error {
                throw GenerateCommandError.tokenizationError(path: path, error: error)
            }
            componentTypes.append(contentsOf: definition.componentTypes)
            globalContext.register(definition: definition, path: path)
            imports.formUnion(definition.requiredImports)
            imports.formUnion(definition.styles.map { $0.parentModuleImport })
        }

        for (offset: index, element: (path: path, group: group)) in globalContextFiles.enumerated() {
            let configuration = GeneratorConfiguration(minimumMajorVersion: minimumDeploymentTarget,
                                                       localXmlPath: path,
                                                       isLiveEnabled: enableLive.value,
                                                       swiftVersion: swiftVersion,
                                                       defaultModifier: accessModifier)
            let styleContext = StyleGroupContext(globalContext: globalContext, group: group)
            output.append(try StyleGenerator(context: styleContext, configuration: configuration).generate(imports: index == 0))
        }

        output.lines(
              "import UIKit",
              "import Hyperdrive",
              "import ReactantUI",
              "import SnapKit")

        try output.append(theme(context: globalContext, swiftVersion: swiftVersion))

        if enableLive.value {
            output.append(ifSimulator(ifClause: "import ReactantLiveUI"))
        }
        for imp in imports {
            output.append("import \(imp)")
        }

        let bundleTokenClass = Structure.class(accessibility: .private, name: "__HyperdriveUIBundleToken")
        let resourceBundeProperty = SwiftCodeGen.Property.constant(accessibility: .private, name: "__resourceBundle", value: .constant("Bundle(for: __HyperdriveUIBundleToken.self)"))

        output.append(bundleTokenClass)
        output.append(resourceBundeProperty)

//        output.append("""
//        private final class __ReactantUIBundleToken { }
//        private let __resourceBundle = Bundle(for: __ReactantUIBundleToken.self)
//        """)

        for (path, rootDefinition) in globalContext.componentDefinitions.definitionsByPath.sorted(by: { $0.key.compare($1.key) == .orderedAscending }) {
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
            output.append(ifSimulator(ifClause: "let bundleWorker = ReactantLiveUIWorker(configuration: GeneratedReactantLiveUIConfiguration())"))
        }
                          
        output.append("public func activateLiveReload(in window: UIWindow) {")
        if enableLive.value {
            let liveUIActivation = [
                "ReactantLiveUIManager.shared.activate(in: window, worker: bundleWorker)",
                "ApplicationTheme.selector.register(target: bundleWorker, listener: { theme in",
                "    bundleWorker.setSelectedTheme(name: theme.name)",
                "})",
            ] as [Describable]

            output.append(ifSimulator(ifClause: liveUIActivation))
        }
        output.append("}")

        let result = output.result.joined(separator: "\n")

        switch outputType {
        case .console:
            print(result)
        case .file(let outputPathURL):
            try result.write(to: outputPathURL, atomically: true, encoding: .utf8)
        }
    }

    private func theme(context: GlobalContext, swiftVersion: SwiftVersion) throws -> Structure {
        let description = context.applicationDescription
        func allCases<T>(item: String, from container: ThemeContainer<T>) throws -> [(Expression, Block)] {
            return try description.themes.map { theme in
                guard let themedItem = container[theme: theme, item: item] else {
                    throw GenerateCommandError.themedItemNotFound(theme: theme, item: item)
                }
                let typeContext = SupportedPropertyTypeContext(parentContext: context, value: .value(themedItem))
                return (Expression.constant(".\(theme)"), [.return(expression: themedItem.generate(context: typeContext))])
            }
        }

        let themeProperty = SwiftCodeGen.Property.constant(accessibility: .fileprivate, name: "theme", type: "ApplicationTheme")

        func themeContainer<T>(from container: ThemeContainer<T>, named name: String) throws -> Structure {
            let themeProperty = SwiftCodeGen.Property.constant(accessibility: .fileprivate, name: "theme", type: "ApplicationTheme")

            let properties = try container.allItemNames.sorted().map { item -> SwiftCodeGen.Property in
                let switchStatement = try Statement.switch(
                    expression: .constant("theme"),
                    cases: allCases(item: item, from: container),
                    default: nil)

                return SwiftCodeGen.Property.variable(
                    accessibility: .public,
                    name: item,
                    type: T.runtimeType(for: .iOS).name,
                    block: [switchStatement])
            }

            return Structure.struct(
                accessibility: .public,
                name: name,
                properties: [themeProperty] + properties)
        }

        let colorsStruct = try themeContainer(from: description.colors, named: "Colors")

        let imagesStruct = try themeContainer(from: description.images, named: "Images")

        let fontsStruct = try themeContainer(from: description.fonts, named: "Fonts")

        let currentTheme = SwiftCodeGen.Property.variable(
            accessibility: .public,
            modifiers: .static,
            name: "current",
            type: "ApplicationTheme",
            block: [
                .return(expression: .constant("selector.currentTheme")),
            ])

        let selector = SwiftCodeGen.Property.constant(
            accessibility: .public,
            modifiers: .static,
            name: "selector",
            value: .constant("ReactantThemeSelector<ApplicationTheme>(defaultTheme: .\(description.defaultTheme))"))

        let colors = SwiftCodeGen.Property.variable(
            accessibility: .public,
            name: "colors",
            type: "Colors",
            block: [
                .return(expression: .constant("Colors(theme: self)"))
            ])

        let images = SwiftCodeGen.Property.variable(
            accessibility: .public,
            name: "images",
            type: "Images",
            block: [
                .return(expression: .constant("Images(theme: self)"))
            ])

        let fonts = SwiftCodeGen.Property.variable(
            accessibility: .public,
            name: "fonts",
            type: "Fonts",
            block: [
                .return(expression: .constant("Fonts(theme: self)"))
            ])

        return Structure.enum(
            accessibility: .public,
            name: "ApplicationTheme",
            inheritances: ["String", "ReactantThemeDefinition"],
            containers: [colorsStruct, imagesStruct, fontsStruct],
            cases: description.themes.map {
                Structure.EnumCase(name: $0)
            },
            properties: [currentTheme, selector, colors, images, fonts])

//        return """
//
//        public enum ApplicationTheme: String, ReactantThemeDefinition {
//            public static var current: ApplicationTheme {
//                return selector.currentTheme
//            }
//
//            public static let selector = ReactantThemeSelector<ApplicationTheme>(defaultTheme: .\(description.defaultTheme))
//
//        \(cases)
//
//            public struct Colors {
//                fileprivate let theme: ApplicationTheme
//
//            \(allColorsSorted.joined(separator: "\n"))
//            }
//            public struct Images {
//                fileprivate let theme: ApplicationTheme
//
//            \(allImagesSorted.joined(separator: "\n"))
//            }
//            public struct Fonts {
//                fileprivate let theme: ApplicationTheme
//
//            \(allFontsSorted.joined(separator: "\n"))
//            }
//
//            public var colors: Colors {
//                return Colors(theme: self)
//            }
//
//            public var images: Images {
//                return Images(theme: self)
//            }
//
//            public var fonts: Fonts {
//                return Fonts(theme: self)
//            }
//        }
//
//        \(rxSwiftShim)
//        """
    }

    private func minimumDeploymentTarget() throws -> Int {
        guard let xcodeProjectPathsString = xcodeProjectPath.value, let xcprojpath = URL(string: xcodeProjectPathsString) else {
            throw GenerateCommandError.XCodeProjectPathInvalid
        }

        let project: XcodeProj
        do {
            project = try XcodeProj(pathString: xcprojpath.absoluteURL.path)
        } catch {
            throw GenerateCommandError.cannotReadXCodeProj(error)
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

    private func ifSimulator(ifClause: Describable, elseClause: Describable? = nil) -> [Describable] {
        let elseCode: [Describable]
        if let elseClause = elseClause {
            elseCode = ["#else", elseClause]
        } else {
            elseCode = []
        }

        return ["#if targetEnvironment(simulator)", ifClause] +
            elseCode +
            ["#endif"]
    }
}
