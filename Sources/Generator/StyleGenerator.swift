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
            case .view(let factory):
                return try generate(accessibility: accessibility, viewStyle: style, elementFactory: factory)
            }
        }

        return Structure.struct(
            accessibility: accessibility,
            name: styleGroup.swiftName,
            containers: containers,
            functions: functions)
    }

    private func generate(accessibility: Accessibility, attributeTextStyle style: Style, styles: [AttributedTextStyle]) throws -> Structure {
        func generate(properties: [Tokenizer.Property]) -> [Expression] {
            return properties.map { property in
                let propertyContext = PropertyContext(parentContext: context, property: property)
                return .invoke(target: .member(target: .constant("Attribute"), name: property.name), arguments: [
                    MethodArgument(value: property.anyValue.generate(context: propertyContext.child(for: property.anyValue)))
                ])
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
                    value: .arrayLiteral(items: generate(properties: style.properties))))
        }

        for childStyle in styles {
            // extended styles generation
            // currently O(n^3 * m) where m is the extension depth level
            func generateExtensions(from extendedStyles: [StyleName]) -> [Expression] {
                return extendedStyles.flatMap { extendedStyleName -> [Expression] in
                    guard let extendedStyle = context.style(named: extendedStyleName),
                        case .attributedText(let styles) = extendedStyle.type,
                        styles.contains(where: { $0.name == childStyle.name }) else { return [] }

                    return generateExtensions(from: extendedStyle.extend) +
                        [.constant(context.resolvedStyleName(named: extendedStyleName) + ".\(childStyle.name)")]
                }
            }

            var argumentExpressions: [Expression] = generateExtensions(from: style.extend)
            if !style.properties.isEmpty {
                argumentExpressions.append(.constant("___sharedProperties___"))
            }
            argumentExpressions.append(.arrayLiteral(items: generate(properties: childStyle.properties)))
            let arguments = argumentExpressions.enumerated().map { index, expression in
                MethodArgument(name: index == 0 ? "subarrays" : nil, value: expression)
            }

            let attributeExpression = Expression.invoke(target: .constant("Array<Hyperdrive.Attribute>"), arguments: arguments)

            properties.append(
                .constant(
                    accessibility: accessibility,
                    modifiers: .static,
                    name: childStyle.name,
                    type: "[Hyperdrive.Attribute]",
                    value: attributeExpression)
            )
        }

        return Structure.struct(
            accessibility: accessibility,
            name: style.name.name,
            properties: properties)
    }

    private func generate(accessibility: Accessibility, viewStyle style: Style, elementFactory: UIElementFactory) throws -> Function {
        let extendedApplications = style.extend.map { extendedStyle -> Statement in
            let function: Expression
            switch extendedStyle {
            case .local(let name):
                function = .member(target: .constant(styleGroup.swiftName), name: name)
            case .global(let group, let name):
                function = .member(target: .constant(group.capitalizingFirstLetter() + "Styles"), name: name)
            }
            return .expression(.invoke(target: function, arguments: [MethodArgument(value: .constant("view"))]))
        }

        let applications = style.properties.map { property -> Statement in
            let propertyContext = PropertyContext(parentContext: context, property: property)
            return property.application(on: "view", context: propertyContext)
        }

        let parameters: [MethodParameter]
        let returnType: String?
        let block: Block

        if style.requiresTheme(context: context) {
            parameters = [
                MethodParameter(name: "theme", type: "ApplicationTheme"),
            ]
            returnType = "(_ view: \(try elementFactory.runtimeType())) -> Void"

            let closure = Closure(parameters: [(name: "view", type: nil)], returnType: nil, block: Block(statements: extendedApplications + applications))

            block = [Statement.return(expression: .closure(closure))]
        } else {
            parameters = [
                MethodParameter(label: "_", name: "view", type: try elementFactory.runtimeType().name)
            ]
            returnType = nil
            block = Block(statements: extendedApplications + applications)
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

        return try styleGroupGenerator.generateStyles(accessibility: groupAccessibility)
    }
}
