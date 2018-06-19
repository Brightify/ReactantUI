//
//  GlobalContext.swift
//  Tokenizer
//
//  Created by Tadeas Kriz on 01/06/2018.
//

import Foundation

#if canImport(Reactant)
import Reactant
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

public struct GlobalContext: DataContext {
    private typealias StyleSheets = [String: [String: Style]]

    public var applicationDescription: ApplicationDescription
    public var currentTheme: ApplicationDescription.ThemeName
    private var styles: StyleSheets = [:]

    public init() {
        self.applicationDescription = ApplicationDescription()
        self.currentTheme = applicationDescription.defaultTheme
        self.styles = [:]
    }

    public init(
        applicationDescription: ApplicationDescription,
        currentTheme: ApplicationDescription.ThemeName,
        styleSheetDictionary: [String: StyleGroup])
    {
        self.applicationDescription = applicationDescription
        self.currentTheme = currentTheme

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

    public func themed(image name: String) -> Image? {
        return applicationDescription.images[theme: currentTheme, item: name]
    }

    public func themed(color name: String) -> UIColorPropertyType? {
        return applicationDescription.colors[theme: currentTheme, item: name]
    }

    public func themed(font name: String) -> Font? {
        return applicationDescription.fonts[theme: currentTheme, item: name]
    }

    public mutating func setStyles(from styleSheetDictionary: [String: StyleGroup]) {
        styles = Dictionary(keyValueTuples: styleSheetDictionary.map { arg in
            let (key, value) = arg
            return (key, Dictionary(keyValueTuples: value.styles.map { ($0.name.name, $0) }))
        })
    }

    public mutating func setStyles(from styleSheets: [StyleGroup]) {
        let groups = (styleSheets
            .flatMap { $0.styles }
            .groupBy { style -> String? in
                guard case .global(let groupName, _) = style.name else { return nil }
                return groupName
            } as [(name: String, styles: [Style])])
            .map { ($0.name, Dictionary(keyValueTuples: $0.styles.map { ($0.name.name, $0) })) }

        styles = Dictionary(keyValueTuples: groups)
    }
}
