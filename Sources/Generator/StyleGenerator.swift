//
//  StyleGenerator.swift
//  Reactant
//
//  Created by Matouš Hýbl on 17/04/2017.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation
import Tokenizer

public class StyleGenerator: Generator {

    private let context: StyleGroupContext
    private let group: StyleGroup
    private var tempCounter: Int = 1

    public init(context: StyleGroupContext, configuration: GeneratorConfiguration) {
        self.group = context.group
        self.context = context
        super.init(configuration: configuration)
    }

    public override func generate(imports: Bool) throws -> String {
        if imports {
            l("""
              import UIKit
              import Reactant
              import SnapKit
              """)
            if configuration.isLiveEnabled {
                l(ifSimulator("import ReactantLiveUI"))
            }
        }
        let styleImports = Set(group.styles.map { $0.parentModuleImport })
        for styleImport in styleImports {
            l("import \(styleImport)")
        }
        l()
        try l("struct \(group.swiftName)") {
            for style in group.styles {
                switch style.type {
                case .attributedText(let styles):
                    try generate(attributeTextStyle: style, styles: styles)
                case .view(let type):
                    try generate(viewStyle: style, type: type)
                }
            }
        }

        return output
    }

    // DISCLAIMER: This method is identical to a method with the same signature in `UIGenerator.swift`. If you're changing the functionality of this method, you most likely want to bring the functionality changes over to that method as well.
    private func generate(attributeTextStyle style: Style, styles: [AttributedTextStyle]) throws {
        func generate(attributes array: [Property]) {
            for property in array {
                let propertyContext = PropertyContext(parentContext: context, property: property)
                l("Attribute.\(property.name)(\(property.anyValue.generate(context: propertyContext.child(for: property.anyValue)))),")
            }
        }

        l("struct \(style.name.name)") {
            if !style.properties.isEmpty {
                l("private static let ___sharedProperties___: [Reactant.Attribute] = ", encapsulateIn: .brackets) {
                    generate(attributes: style.properties)
                }
            }

            for childStyle in styles {
                l("static let \(childStyle.name): [Reactant.Attribute] = ", encapsulateIn: .none) {

                    // extended styles generation
                    // currently O(n^3 * m) where m is the extension depth level
                    func generateExtensions(from extendedStyles: [StyleName]) {
                        for extendedStyleName in extendedStyles {
                            guard let extendedStyle = context.style(named: extendedStyleName),
                                case .attributedText(let styles) = extendedStyle.type,
                                styles.contains(where: { $0.name == childStyle.name }) else { continue }

                            generateExtensions(from: extendedStyle.extend)

                            l(context.resolvedStyleName(named: extendedStyleName) + ".\(childStyle.name),")
                        }
                    }

                    l("Array<Reactant.Attribute>(subarrays: ")
                    generateExtensions(from: style.extend)
                    if !style.properties.isEmpty {
                        l("___sharedProperties___,")
                    }
                    l("", encapsulateIn: .brackets) {
                        generate(attributes: childStyle.properties)
                    }
                    l(")")
                }
            }
        }
    }

    // DISCLAIMER: This method is identical to a method with the same signature in `UIGenerator.swift`. If you're changing the functionality of this method, you most likely want to bring the functionality changes over to that method as well.
    private func generate(viewStyle style: Style, type: String) throws {
        guard let mapping = ElementMapping.mapping[type] else {
            throw GeneratorError(message: "Mapping for type \(type) does not exist")
        }

        func styleApplication() {
            for extendedStyle in style.extend {
                switch extendedStyle {
                case .local(let name):
                    l("\(group.swiftName).\(name)(view)")
                case .global(let group, let name):
                    l("\(group.capitalizingFirstLetter() + "Styles").\(name)(view)")
                }
            }
            for property in style.properties {
                let propertyContext = PropertyContext(parentContext: context, property: property)
                l(property.application(on: "view", context: propertyContext))
            }
        }

        if style.requiresTheme(context: context) {
            l("static func \(style.name.name)(theme: ApplicationTheme) -> (_ view: \(try mapping.runtimeType())) -> Void") {
                l("return { view in", encapsulateIn: .none) {
                    styleApplication()
                }
                l("}")
            }

        } else {
            l("static func \(style.name.name)(_ view: \(try mapping.runtimeType()))") {
                styleApplication()
            }
        }
    }
}
