//
//  ApplicationDescription.swift
//  ReactantUI
//
//  Created by Tadeas Kriz on 6/18/18.
//

import Foundation

/**
 * Structure containing themed resources.
 * An example would be themed XML element **<Fonts>** (and its innards) inside an **<Application>** XML element.
 */
public struct ThemeContainer<T: AttributeSupportedPropertyType>: XMLElementDeserializable {
    public typealias ItemName = String

    private var defaultItems: [ItemName: T] = [:]
    private var themedItems: [ApplicationDescription.ThemeName: [ItemName: T]] = [:]

    /**
     * Given a theme and an item name returns its property type.
     * - parameter theme: theme to use
     * - parameter item: item to get using the passed theme
     * - returns: property type corresponding to passed theme and item if present, otherwise nil
     */
    public subscript(theme theme: String, item item: String) -> T? {
        guard let themeItems = themedItems[theme] else {
            return defaultItems[item]
        }

        return themeItems[item] ?? defaultItems[item]
    }

    /**
     * A `Set` of all themed items inside the theme container.
     */
    public var allItemNames: Set<ItemName> {
        let defaultItemNames = defaultItems.keys
        let themedItemNames = themedItems.values.flatMap { $0.keys }
        return Set(defaultItemNames).union(themedItemNames)
    }

    public init() { }

    public init(node: XMLElement) throws {
        for child in node.xmlChildren {
            for (name, attribute) in child.allAttributes {
                let item = try T.materialize(from: attribute.text)
                if child.name == "shared" {
                    defaultItems[name] = item
                } else {
                    themedItems[child.name, default: [:]][name] = item
                }
            }
        }
    }

    /**
     * Tries to deserialize the `ThemeContainer` from an XML element.
     * - parameter element: XML element to parse
     * - returns: if not thrown, the `ThemeContainer` structure
     */
    public static func deserialize(_ element: XMLElement) throws -> ThemeContainer<T> {
        return try ThemeContainer(node: element)
    }
}

/**
 * Structure describing an **<Application>** XML element containing **<Themes>**, **<Colors>**, **<Images>**, and **<Fonts>**
 * that are to be themeable inside the application.
 */
public struct ApplicationDescription: XMLElementDeserializable {
    public static let defaultThemeName = "none"

    public typealias ThemeName = String

    public var themes = [ApplicationDescription.defaultThemeName]
    public var defaultTheme = ApplicationDescription.defaultThemeName
    public var colors =  ThemeContainer<UIColorPropertyType>()
    public var images = ThemeContainer<Image?>()
    public var fonts = ThemeContainer<Font?>()

    public init(node: XMLElement) throws {
        if let themesNode = try node.singleOrNoElement(named: "Themes") {
            themes = themesNode.xmlChildren.map { $0.name }
            guard let defaultThemeIfNotSelected = themes.first else {
                throw TokenizationError.missingTheme()
            }

            defaultTheme = try themesNode.value(ofAttribute: "default", defaultValue: defaultThemeIfNotSelected)
        }

        if let colorsNode = try node.singleOrNoElement(named: "Colors") {
            colors = try colorsNode.value()
        }
        if let imagesNode = try node.singleOrNoElement(named: "Images") {
            images = try imagesNode.value()
        }
        if let fontsNode = try node.singleOrNoElement(named: "Fonts") {
            fonts = try fontsNode.value()
        }

        // We want to let caller know the result of validation by throwing when it didn't validate
        try validate()
    }

    public init() {
        // Here we want to crash, because we're validating a no-arg initializer. If the validation fails, we need to crash
        // because it means we have a programming issue (either the validation or default parameters are wrong).
        try! validate()
    }

    /**
     * Tries to validate the application description, throws if it's invalid.
     */
    public func validate() throws {
        // MARK:- Validation
        guard themes.contains(defaultTheme) else {
            throw TokenizationError.defaultThemeMissing(themes: themes, defaultTheme: defaultTheme)
        }
    }

    /**
     * Tries to deserialize the `ApplicationDescription` from an XML element.
     * - parameter element: XML element to parse
     * - returns: if not thrown, the `ApplicationDescription` structure
     */
    public static func deserialize(_ element: XMLElement) throws -> ApplicationDescription {
        return try ApplicationDescription(node: element)
    }

    /**
     * Checks if the passed value is themed.
     * - parameter value: the value to check
     * - returns: `Optional` value, the original value without the prefix if check succeeded, nil otherwise
     */
    public static func themedValueName(value: String) -> String? {
        let themePrefix = "theme."
        if value.hasPrefix(themePrefix) {
            return String(value.dropFirst(themePrefix.count))
        } else {
            return nil
        }
    }
}

extension TokenizationError {
    public static func missingTheme() -> TokenizationError {
        return TokenizationError(message: "When declaring <themes> in your application description, make sure you add at least one theme as a child element.")
    }

    public static func defaultThemeMissing(themes: [ApplicationDescription.ThemeName], defaultTheme: ApplicationDescription.ThemeName) -> TokenizationError {
        return TokenizationError(message: "Default theme `\(defaultTheme)` is not declared in <themes>. Declared themes: \(themes)")
    }
}
