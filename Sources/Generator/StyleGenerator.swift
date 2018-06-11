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

    private func generate(attributeTextStyle style: Style, styles: [AttributedTextStyle]) throws {
        func generate(attributes array: [Property]) {
            for property in array {
                let propertyContext = PropertyContext(parentContext: context, property: property)
                l("    Attribute.\(property.name)(\(property.anyValue.generate(context: propertyContext.child(for: property.anyValue)))),")
            }
        }

        l("struct \(style.name.name)") {
            l("private static let ___sharedProperties___: [Reactant.Attribute] = [")
            generate(attributes: style.properties)
            l("]")

            for childStyle in styles {
                l("static let \(childStyle.name): [Reactant.Attribute] = ")
                // TODO: Extending
//            for extendedStyle in style.extend {
//                switch extendedStyle {
//                case .local(let name):
//                    l("\(root.stylesName).\(name)")
//                case .global(let group, let name):
//                    l("\(group.capitalizingFirstLetter() + "Styles").\(name)")
//                }
//
//                l("+")
//            }

                l("___sharedProperties___ + [")
                generate(attributes: childStyle.properties)
                l("]")
            }
        }
    }

    private func generate(viewStyle style: Style, type: String) throws {
        guard let mapping = ElementMapping.mapping[type] else {
            throw GeneratorError(message: "Mapping for type \(type) does not exist")
        }
        l("static func \(style.name.name)(_ view: \(try mapping.runtimeType()))") {
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
    }
}
