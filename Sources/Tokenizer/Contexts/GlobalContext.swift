//
//  GlobalContext.swift
//  Tokenizer
//
//  Created by Tadeas Kriz on 01/06/2018.
//

import Foundation

#if canImport(Hyperdrive)
import Hyperdrive
#else
extension Dictionary {
    public init(keyValueTuples: [(Key, Value)]) {
        var result: [Key: Value] = [:]
        for item in keyValueTuples {
            result[item.0] = item.1
        }
        self = result
    }
}
#endif

/**
 * The topmost context (disregarding `ReactantLiveUIWorker.Context` which serves LiveUI purposes only).
 * Any data to be shared throughout the whole application (bundle) should be located in this context.
 */
public struct GlobalContext: DataContext {
    private typealias StyleSheets = [String: [String: Style]]
    private typealias TemplateSheets = [String: [String: Template]]
    private typealias ComponentDefinitions = [String: ComponentDefinition]

    public var applicationDescription: ApplicationDescription
    public var currentTheme: ApplicationDescription.ThemeName
    public var resourceBundle: Bundle?
    private var styles: StyleSheets = [:]
    private var templates: TemplateSheets = [:]
    private var componentDefinitions: ComponentDefinitions = [:]

    public init() {
        self.applicationDescription = ApplicationDescription()
        self.currentTheme = applicationDescription.defaultTheme
        self.resourceBundle = Bundle.main
    }

    public init(
        applicationDescription: ApplicationDescription,
        currentTheme: ApplicationDescription.ThemeName,
        resourceBundle: Bundle?,
        styleSheetDictionary: [String: StyleGroup])
    {
        self.applicationDescription = applicationDescription
        self.currentTheme = currentTheme
        self.resourceBundle = resourceBundle

        setStyles(from: styleSheetDictionary)
    }

    public init(
        applicationDescription: ApplicationDescription,
        currentTheme: ApplicationDescription.ThemeName,
        styleSheets: [StyleGroup]) {
        self.applicationDescription = applicationDescription
        self.currentTheme = currentTheme

        setStyles(from: styleSheets)
    }

    public func resolvedStyleName(named styleName: StyleName) -> String {
        guard case .global(let groupName, let name) = styleName else {
            fatalError("Global context cannot resolve local style name \(styleName.name).")
        }
        return "\(groupName.capitalizingFirstLetter())Styles.\(name)"
    }

    public func style(named styleName: StyleName) -> Style? {
        guard case .global(let groupName, let name) = styleName else { return nil }
        return styles[groupName]?[name]
    }

    public func template(named templateName: TemplateName) -> Template? {
        guard case .global(let groupName, let name) = templateName else { return nil }
        return templates[groupName]?[name]
    }

    public func themed(image name: String) -> Image? {
        return applicationDescription.images[theme: currentTheme, item: name].flatMap { $0 }
    }

    public func themed(color name: String) -> UIColorPropertyType? {
        return applicationDescription.colors[theme: currentTheme, item: name]
    }

    public func themed(font name: String) -> Font? {
        return applicationDescription.fonts[theme: currentTheme, item: name].flatMap { $0 }
    }

    public mutating func setStyles(from styleSheetDictionary: [String: StyleGroup]) {
        styles = Dictionary(keyValueTuples: styleSheetDictionary.map { arg in
            let (key, value) = arg
            return (key, Dictionary(keyValueTuples: value.styles.map { ($0.name.name, $0) }))
        })
    }

    public mutating func setStyles(from styleSheets: [StyleGroup]) {
        let groups = Dictionary(grouping: styleSheets.flatMap { $0.styles }, by: { style -> String? in
            guard case .global(let groupName, _) = style.name else { return nil }
            return groupName
        }).compactMap { name, styles -> (String, [String: Style])? in
            guard let name = name else { return nil }
            return (name, Dictionary(keyValueTuples: styles.map { ($0.name.name, $0) }))
        }

        styles = Dictionary(keyValueTuples: groups)
    }
}
