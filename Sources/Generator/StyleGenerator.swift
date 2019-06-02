//
//  StyleGenerator.swift
//  Reactant
//
//  Created by Matouš Hýbl on 17/04/2017.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation
import Tokenizer
import SwiftCodeGen

public class StyleGroupGenerator {
    private let context: DataContext
    private let styleGroup: StyleGroup

    public init(context: DataContext, styleGroup: StyleGroup) {
        self.context = context
        self.styleGroup = styleGroup
    }

    public func generateStyles(accessibility: Accessibility) throws -> Structure {
        let containers = try styleGroup.styles.compactMap { style -> ContainerType? in
            switch style.type {
            case .attributedText(let styles):
                return try generate(accessibility: accessibility, attributeTextStyle: style, styles: styles)
            case .view:
                return nil
            }
        }

        let functions = try styleGroup.styles.compactMap { style -> Function? in
            switch style.type {
            case .attributedText:
                return nil
            case .view(let type):
                return try generate(accessibility: accessibility, viewStyle: style, type: type)
            }
        }

        return Structure.struct(
            accessibility: accessibility,
            name: styleGroup.swiftName,
            containers: containers,
            functions: functions)
    }

    private func generate(accessibility: Accessibility, attributeTextStyle style: Style, styles: [AttributedTextStyle]) throws -> Structure {
        func generate(properties: [Tokenizer.Property]) -> [String] {
            return properties.map { property in
                let propertyContext = PropertyContext(parentContext: context, property: property)
                return "Attribute.\(property.name)(\(property.anyValue.generate(context: propertyContext.child(for: property.anyValue)))),"
            }
        }
        var properties: [SwiftCodeGen.Property] = []
        if !style.properties.isEmpty {
            properties.append(
                .constant(
                    accessibility: .private,
                    modifiers: .static,
                    name: "___sharedProperties___",
                    type: "[Hyperdrive.Attribute]",
                    value: "[\(generate(properties: style.properties).joined(separator: "\n"))]"))
        }

        for childStyle in styles {
            // extended styles generation
            // currently O(n^3 * m) where m is the extension depth level
            func generateExtensions(from extendedStyles: [StyleName]) -> [String] {
                return extendedStyles.flatMap { extendedStyleName -> [String] in
                    guard let extendedStyle = context.style(named: extendedStyleName),
                        case .attributedText(let styles) = extendedStyle.type,
                        styles.contains(where: { $0.name == childStyle.name }) else { return [] }

                    return generateExtensions(from: extendedStyle.extend) +
                        [context.resolvedStyleName(named: extendedStyleName) + ".\(childStyle.name),"]
                }
            }

            var block: [String] = generateExtensions(from: style.extend)
            if !style.properties.isEmpty {
                block.append("___sharedProperties___,")
            }
            block.append("[")
            block.append(contentsOf: generate(properties: childStyle.properties))
            block.append("]")

            properties.append(
                .constant(
                    accessibility: accessibility,
                    modifiers: .static,
                    name: childStyle.name,
                    type: "[Hyperdrive.Attribute]",
                    value: "Array<Hyperdrive.Attribute>(subarrays: \(block.joined(separator: "\n")))")
            )
        }

        return Structure.struct(
            accessibility: accessibility,
            name: style.name.name,
            properties: properties)
    }

    private func generate(accessibility: Accessibility, viewStyle style: Style, type: String) throws -> Function {
        guard let mapping = ElementMapping.mapping[type] else {
            throw GeneratorError(message: "Mapping for type \(type) does not exist")
        }

        let extendedApplications = style.extend.map { extendedStyle -> String in
            switch extendedStyle {
            case .local(let name):
                return "\(styleGroup.swiftName).\(name)(view)"
            case .global(let group, let name):
                return "\(group.capitalizingFirstLetter() + "Styles").\(name)(view)"
            }
        }

        let applications = style.properties.map { property -> String in
            let propertyContext = PropertyContext(parentContext: context, property: property)
            return property.application(on: "view", context: propertyContext)
        }

        let parameters: [MethodParameter]
        let returnType: String?
        let block: [String]

        if style.requiresTheme(context: context) {
            parameters = [
                MethodParameter(name: "theme", type: "ApplicationTheme"),
            ]
            returnType = "(_ view: \(try mapping.runtimeType())) -> Void"
            block = ["return { view in"]
                + (extendedApplications + applications).map { "    \($0)" }
                + ["}"]
        } else {
            parameters = [
                MethodParameter(label: "_", name: "view", type: try mapping.runtimeType())
            ]
            returnType = nil
            block = extendedApplications + applications
        }

        return Function(
            accessibility: accessibility,
            modifiers: .static,
            name: style.name.name,
            parameters: parameters,
            returnType: returnType,
            block: block)
    }
}

public class StyleGenerator: Generator {

    private let context: StyleGroupContext
    private let group: StyleGroup
    private let styleGroupGenerator: StyleGroupGenerator

    public init(context: StyleGroupContext, configuration: GeneratorConfiguration) {
        self.group = context.group
        self.context = context
        self.styleGroupGenerator = StyleGroupGenerator(context: context, styleGroup: group)
        super.init(configuration: configuration)
    }

    public override func generate(imports: Bool) throws -> Describable {
        let pipe = DescriptionPipe()
        if imports {
            pipe.lines(
                "import UIKit",
                "import Hyperdrive",
                "import SnapKit")
            if configuration.isLiveEnabled {
                pipe.lines(ifSimulator("import ReactantLiveUI"))
            }
        }
        let styleImports = Set(group.styles.map { $0.parentModuleImport })
        for styleImport in styleImports {
            pipe.line("import \(styleImport)")
        }
        pipe.line()
        let groupAccessibility: Accessibility
        if group.accessModifier == .public || group.styles.contains(where: { $0.accessModifier == .public }) {
            groupAccessibility = .public
        } else {
            groupAccessibility = .internal
        }

        func styleAccessModifier(style: Style) -> AccessModifier {
            if group.accessModifier == .public {
                return .public
            }
            return style.accessModifier
        }

        let structure = try styleGroupGenerator.generateStyles(accessibility: groupAccessibility)

//        try pipe.block(line: "\(groupAccessModifier.rawValue) struct \()") {
//            for style in group.styles {
//                switch style.type {
//                case .attributedText(let styles):
//                    try pipe.append(generate(modifier: styleAccessModifier(style: style).rawValue, attributeTextStyle: style, styles: styles))
//                case .view(let type):
//                    try pipe.append(generate(modifier: styleAccessModifier(style: style).rawValue, viewStyle: style, type: type))
//                }
//            }
//        }

        return pipe.append(structure)
    }

//    // DISCLAIMER: This method is identical to a method with the same signature in `UIGenerator.swift`. If you're changing the functionality of this method, you most likely want to bring the functionality changes over to that method as well.
//    private func generate(modifier: String, attributeTextStyle style: Style, styles: [AttributedTextStyle]) throws -> DescriptionPipe {
//        let pipe = DescriptionPipe()
//        func generate(attributes array: [Tokenizer.Property]) {
//            for property in array {
//                let propertyContext = PropertyContext(parentContext: context, property: property)
//                pipe.line("Attribute.\(property.name)(\(property.anyValue.generate(context: propertyContext.child(for: property.anyValue)))),")
//            }
//        }
//
//        pipe.block(line: "\(modifier) struct \(style.name.name)") {
//            if !style.properties.isEmpty {
//                pipe.block(line: "private static let ___sharedProperties___: [Reactant.Attribute] = ", encapsulateIn: .brackets) {
//                    generate(attributes: style.properties)
//                }
//            }
//
//            for childStyle in styles {
//                pipe.block(line: "\(modifier) static let \(childStyle.name): [Reactant.Attribute] = ", encapsulateIn: .none) {
//
//                    // extended styles generation
//                    // currently O(n^3 * m) where m is the extension depth level
//                    func generateExtensions(from extendedStyles: [StyleName]) {
//                        for extendedStyleName in extendedStyles {
//                            guard let extendedStyle = context.style(named: extendedStyleName),
//                                case .attributedText(let styles) = extendedStyle.type,
//                                styles.contains(where: { $0.name == childStyle.name }) else { continue }
//
//                            generateExtensions(from: extendedStyle.extend)
//
//                            pipe.line(context.resolvedStyleName(named: extendedStyleName) + ".\(childStyle.name),")
//                        }
//                    }
//
//                    pipe.line("Array<Reactant.Attribute>(subarrays: ")
//                    generateExtensions(from: style.extend)
//                    if !style.properties.isEmpty {
//                        pipe.line("___sharedProperties___,")
//                    }
//                    pipe.block(encapsulateIn: .custom(open: "[", close: "])")) {
//                        generate(attributes: childStyle.properties)
//                    }
//                }
//            }
//        }
//        return pipe
//    }
//
//    // DISCLAIMER: This method is identical to a method with the same signature in `UIGenerator.swift`. If you're changing the functionality of this method, you most likely want to bring the functionality changes over to that method as well.
//    private func generate(modifier: String, viewStyle style: Style, type: String) throws -> DescriptionPipe {
//        guard let mapping = ElementMapping.mapping[type] else {
//            throw GeneratorError(message: "Mapping for type \(type) does not exist")
//        }
//
//        let pipe = DescriptionPipe()
//
//        func styleApplication() {
//            for extendedStyle in style.extend {
//                switch extendedStyle {
//                case .local(let name):
//                    pipe.line("\(group.swiftName).\(name)(view)")
//                case .global(let group, let name):
//                    pipe.line("\(group.capitalizingFirstLetter() + "Styles").\(name)(view)")
//                }
//            }
//            for property in style.properties {
//                let propertyContext = PropertyContext(parentContext: context, property: property)
//                pipe.line(property.application(on: "view", context: propertyContext))
//            }
//        }
//
//        if style.requiresTheme(context: context) {
//            pipe.block(line: "\(modifier) static func \(style.name.name)(theme: ApplicationTheme) -> (_ view: \(try mapping.runtimeType())) -> Void") {
//                pipe.block(line: "return", header: "view") {
//                    styleApplication()
//                }
//            }
//        } else {
//            pipe.block(line: "\(modifier) static func \(style.name.name)(_ view: \(try mapping.runtimeType()))") {
//                styleApplication()
//            }
//        }
//        return pipe
//    }
}
