//
//  UIGenerator.swift
//  ReactantUIGenerator
//
//  Created by Matouš Hýbl on 26/02/2018.
//

import Foundation
import Tokenizer

import SwiftCodeGen

public class UIGenerator: Generator {
    public let root: ComponentDefinition
    public let componentContext: ComponentContext

    private var tempCounter: Int = 1

    public init(componentContext: ComponentContext, configuration: GeneratorConfiguration) {
        self.root = componentContext.component
        self.componentContext = componentContext
        super.init(configuration: configuration)
    }

    public override func generate(imports: Bool) throws -> String {
        let modifier = (componentContext.component.modifier == .public || configuration.defaultModifier == .public) ? "public " : ""

        let viewAccessibility: Accessibility = componentContext.component.modifier == .public || configuration.defaultModifier == .public ? .public : .internal

        let triggerReloadPaths = [configuration.localXmlPath].map { #""\#($0)""# }.joined(separator: ",\n")

        let viewProperties: [SwiftCodeGen.Property] = [
            .constant(accessibility: viewAccessibility, modifiers: .static, name: "triggerReloadPaths", type: "Set<String>", value: "[\(triggerReloadPaths)]")
        ]

        let viewDeclarations = try root.allChildren.map { child in
            SwiftCodeGen.Property.constant(
                accessibility: child.isExported ? viewAccessibility : .private,
                name: child.id.description,
                type: try child.runtimeType(for: .iOS).name)
        }

        tempCounter = 1
        let viewInitializations = root.allChildren.flatMap { child -> [String] in
            let pipe = DescriptionPipe()
            pipe.string("\(child.id) = ")
            try! child.initialization(for: .iOS, describeInto: pipe)
            return pipe.result
        }

        tempCounter = 1
        let loadViewPipe = DescriptionPipe()
        var themedProperties = [:] as [String: [Tokenizer.Property]]
        for property in root.properties {
            guard !property.anyValue.requiresTheme else {
                themedProperties["self", default: []].append(property)
                continue
            }
            let propertyContext = PropertyContext(parentContext: componentContext, property: property)
            loadViewPipe.line(property.application(on: "self", context: propertyContext))
        }

        tempCounter = 1
        let loadView = Function(
            accessibility: .private,
            name: "loadView",
            block: try loadViewPipe.lines(from: root.children.map {
                try generate(element: $0, superName: "self", containedIn: root, themedProperties: &themedProperties)
            }).result)

        tempCounter = 1
        let setupConstraints = Function(
            accessibility: .private,
            name: "setupConstraints",
            block: DescriptionPipe().lines(from: root.children.map {
                generateConstraints(element: $0, superName: "self", forUpdate: false)
            }).result)

        let viewInit = Function.initializer(
            accessibility: viewAccessibility,
            parameters: [
                .init(name: "initialState", type: "State", defaultValue: "State()"),
                .init(name: "actionPublisher", type: "ActionPublisher<Action>"),
            ],
            block: viewInitializations + [
                "",
                "state = initialState",
                "self.actionPublisher = actionPublisher",
                "",
                "super.init()",
                "",
                "loadView()",
                "setupConstraints()",
                "initialState.owner = self",
            ])

        let stateProperties: [SwiftCodeGen.Property] = [
            .variable(accessibility: .fileprivate, modifiers: .weak, name: "owner", type: "\(root.type)?"),
        ]

        let stateItems = try componentContext.resolve(state: root)

        let stateVariables = stateItems.map { _, item -> SwiftCodeGen.Property in
//            let propertyContext = PropertyContext(parentContext: componentContext, property: property)
//            let defaultValue = property.anyDescription.anyDefaultValue
            return SwiftCodeGen.Property.variable(
                name: item.name,
                type: item.type.runtimeType(for: .iOS).name,
                value: item.defaultValue.generate(context: SupportedPropertyTypeContext(parentContext: componentContext, value: .value(item.defaultValue))),
                block: [
                    "didSet { notify\(item.name.capitalizingFirstLetter())Changed() }"
                ])
        }

        let stateNotifyFunctions = stateItems.map { _, item -> Function in
            return Function(
                accessibility: .private,
                modifiers: .final,
                name: "notify\(item.name.capitalizingFirstLetter())Changed",
                block: item.applications.map { item in
                    let propertyContext = PropertyContext(parentContext: componentContext, property: item.property.property)
                    return item.property.property.application(on: (item.element as? UIElement)?.id.description ?? "owner?", context: propertyContext)
                })
        }

        let stateFunctions: [Function] = [
            .initializer(),
            .init(accessibility: viewAccessibility,
                  name: "apply",
                  parameters: [.init(label: "from", name: "otherState", type: "State")],
                  block: stateItems.map { _, item in
                      "\(item.name) = otherState.\(item.name)"
                  }),
            .init(accessibility: viewAccessibility,
                  name: "resynchronize",
                  block: stateNotifyFunctions.map {
                      "\($0.name)()"
                  }),
        ]


//        UIControlEventObserver.observe(button, to: actionPublisher)

        let stateClass = Class(
            accessibility: viewAccessibility,
            isFinal: true,
            name: "State",
            inheritances: ["HyperViewState"],
            properties: stateProperties + stateVariables,
            functions: stateFunctions + stateNotifyFunctions)

        let actionEnum = Enumeration(
            accessibility: viewAccessibility,
            name: "Action",
            cases: try componentContext.resolve(actions: root.providedActions).map { action in
                Enumeration.Case(name: action.name, arguments: action.parameters.map { parameter -> (name: String?, type: String) in
                    (name: parameter.label, type: parameter.type.runtimeType(for: .iOS).name)
                })
            })

        let viewClass = Class(
            accessibility: viewAccessibility,
            isFinal: true,
            name: root.type,
            inheritances: ["HyperViewBase", "HyperView"],
            containers: [stateClass, actionEnum],
            properties: viewProperties + viewDeclarations,
            functions: [viewInit, loadView, setupConstraints])

        if root.type == "ATest" {
            viewClass.describe(into: DebugDescriptionPipe())
            exit(0)
        }

        return ""

        if root.isAnonymous {
            l("\(modifier)final class \(root.type): ViewBase<Void, Void>") { }
        }
        
        let constraintFields = root.children.flatMap(self.constraintFields)
        try l("extension \(root.type): ReactantUI" + (root.isRootView ? ", RootView" : "")) {
            if root.isRootView {
                l("\(modifier)var edgesForExtendedLayout: UIRectEdge") {
                    if configuration.isLiveEnabled {
                        if configuration.swiftVersion >= .swift4_1 {
                            l("#if targetEnvironment(simulator)")
                        } else {
                            l("#if (arch(i386) || arch(x86_64)) && (os(iOS) || os(tvOS))")
                        }
                        l("return bundleWorker.extendedEdges(of: self)")
                        l("#else")
                    }
                    l("return \(RectEdge.toGeneratedString(root.edgesForExtendedLayout))")
                    if configuration.isLiveEnabled {
                        l("#endif")
                    }
                }
            }
            l()
            l("\(modifier)var rui: \(root.type).RUIContainer") {
                l("return Reactant.associatedObject(self, key: &\(root.type).RUIContainer.associatedObjectKey)") {
                    l("return \(root.type).RUIContainer(target: self)")
                }
            }
            l()
            l("\(modifier)var __rui: Reactant.ReactantUIContainer") {
                l("return rui")
            }
            l()
            try l("\(modifier)final class RUIContainer: Reactant.ReactantUIContainer") {
                l("fileprivate static var associatedObjectKey = 0 as UInt8")
                l()
                l("\(modifier)var xmlPath: String") {
                    l("return \"\(configuration.localXmlPath)\"")
                }
                l()
                l("\(modifier)var typeName: String") {
                    l("return \"\(root.type)\"")
                }
                l()
                l("\(modifier)let constraints = \(root.type).LayoutContainer()")
                l()
                l("private weak var target: \(root.type)?")
                l()

                tempCounter = 1
                l()
                l("fileprivate init(target: \(root.type))") {
                    l("self.target = target")
                }
                l()
                try l("\(modifier)func setupReactantUI()") {
                    l("guard let target = self.target else { /* FIXME Should we fatalError here? */ return }")
                    if configuration.isLiveEnabled {
                        if configuration.swiftVersion >= .swift4_1 {
                            l("#if targetEnvironment(simulator)")
                        } else {
                            l("#if (arch(i386) || arch(x86_64)) && (os(iOS) || os(tvOS))")
                        }
                        // This will register `self` to remove `deinit` from ViewBase
                        l("bundleWorker.register(target)") {

                            if constraintFields.isEmpty {
                                l("_, _ in")
                                l("return false")
                            } else {
                                l("[constraints] field, constraint -> Bool in")
                                l("switch field") {
                                    for constraintField in constraintFields {
                                        l("case \"\(constraintField)\":")
                                        l("    constraints.\(constraintField) = constraint")
                                        l("    return true")
                                    }
                                    l("default:")
                                    l("    return false")
                                }
                            }
                        }
                        l("#else")
                    }
                    var themedProperties = [:] as [String: [Tokenizer.Property]]
                    for property in root.properties {
                        guard !property.anyValue.requiresTheme else {
                            themedProperties["target", default: []].append(property)
                            continue
                        }
                        let propertyContext = PropertyContext(parentContext: componentContext, property: property)
                        l(property.application(on: "target", context: propertyContext))
                    }
                    try root.children.forEach {
                        try generate(element: $0, superName: "target", containedIn: root, themedProperties: &themedProperties)
                    }

                    if !themedProperties.isEmpty {
                        l("ApplicationTheme.selector.register(target: target, listener: { [weak target] theme in")
                        l("guard let target = target else { return }")
                        for (name, properties) in themedProperties {
                            for property in properties {
                                let propertyContext = PropertyContext(parentContext: componentContext, property: property)
                                l(property.application(on: name, context: propertyContext))
                            }
                        }
                        l("})")
                    }


                    tempCounter = 1
                    root.children.forEach { generateConstraints(element: $0, superName: "target", forUpdate: false) }
                    if configuration.isLiveEnabled {
                        l("#endif")
                    }
                }
                l()
                l("\(modifier)func updateReactantUI()") {
                    l("guard let target = self.target else { /* FIXME Should we fatalError here? */ return }")

                    if configuration.isLiveEnabled {
                        if configuration.swiftVersion >= .swift4_1 {
                            l("#if targetEnvironment(simulator)")
                        } else {
                            l("#if (arch(i386) || arch(x86_64)) && (os(iOS) || os(tvOS))")
                        }
                        // This will reapply the component definition.
                        // TODO Do a real "update" instead of "remake" that's being done now
                        l("bundleWorker.reapply(target)")
                        l("#else")
                    }

                    // TODO: Add conditional properties?
//                    for property in root.properties {
//                        l(property.application(on: "target"))
//                    }
//                    try root.children.forEach { try generate(element: $0, superName: "target", containedIn: root) }

                    tempCounter = 1
                    root.children.forEach { generateConstraints(element: $0, superName: "target", forUpdate: true) }

                    if configuration.isLiveEnabled {
                        l("#endif")
                    }
                }
                l()
                l("\(modifier)static func destroyReactantUI(target: UIView)") {
                    if configuration.isLiveEnabled {
                        l(ifSimulator("""
                                      guard let knownTarget = target as? \(root.type) else { /* FIXME Should we fatalError here? */ return }
                                      bundleWorker.unregister(knownTarget)
                                """))
                    }

                    l("ApplicationTheme.selector.unregister(target: target)")
                }
            }
            l()
            l("\(modifier)final class LayoutContainer") {
                for constraintField in constraintFields {
                    l("fileprivate(set) var \(constraintField): SnapKit.Constraint?")
                }
            }
            try generateStyles(modifier: modifier)
            try generateTemplates(modifier: modifier)
        }

        return output
    }

    private func generate(element: UIElement, superName: String, containedIn: UIContainer, themedProperties: inout [String: [Tokenizer.Property]]) throws -> DescriptionPipe {

        let pipe = DescriptionPipe()

        let name = element.id.description

        for style in element.styles {
            switch style {
            case .local(let styleName):
                pipe.line("\(name).apply(style: \(root.stylesName).\(styleName))")
            case .global(let group, let styleName):
                let stylesGroupName = group.capitalizingFirstLetter() + "Styles"
                pipe.line("\(name).apply(style: \(stylesGroupName).\(styleName))")
            }
        }

        for property in element.properties {
            guard !property.anyValue.requiresTheme else {
                themedProperties[name, default: []].append(property)
                continue
            }

            let propertyContext = PropertyContext(parentContext: componentContext, property: property)
            pipe.line(property.application(on: name, context: propertyContext))
        }
        pipe.line("\(superName).\(containedIn.addSubviewMethod)(\(name))")
        pipe.line()
        if let container = element as? UIContainer {
            try container.children.forEach {
                pipe.lines(from: try generate(element: $0, superName: name, containedIn: container, themedProperties: &themedProperties))
            }
        }

        return pipe
    }

    private func generateConstraints(element: UIElement, superName: String, forUpdate: Bool) -> DescriptionPipe {
        let pipe = DescriptionPipe()

        let name = element.id.description

        defer {
            if let container = element as? UIContainer {
                container.children.forEach {
                    pipe.lines(from: generateConstraints(element: $0, superName: name, forUpdate: forUpdate))
                }
            }
        }

        // we want to continue only if we are generating constraints for update AND the layout has conditions
        // on the other hand, if it's the first time this method is called (not from update), we don't want to
        // generate the constraints if the layout has any conditions in it (they will be handled in update later)
        guard forUpdate == element.layout.hasConditions else { return pipe }

        if let horizontalCompressionPriority = element.layout.contentCompressionPriorityHorizontal {
            pipe.line("\(name).setContentCompressionResistancePriority(UILayoutPriority(rawValue: \(horizontalCompressionPriority.numeric)), for: .horizontal)")
        }

        if let verticalCompressionPriority = element.layout.contentCompressionPriorityVertical {
            pipe.line("\(name).setContentCompressionResistancePriority(UILayoutPriority(rawValue: \(verticalCompressionPriority.numeric)), for: .vertical)")
        }

        if let horizontalHuggingPriority = element.layout.contentHuggingPriorityHorizontal {
            pipe.line("\(name).setContentHuggingPriority(UILayoutPriority(rawValue: \(horizontalHuggingPriority.numeric)), for: .horizontal)")
        }

        if let verticalHuggingPriority = element.layout.contentHuggingPriorityVertical {
            pipe.line("\(name).setContentHuggingPriority(UILayoutPriority(rawValue: \(verticalHuggingPriority.numeric)), for: .vertical)")
        }
        // we're calling `remakeConstraints` if we're called from update
        pipe.block(line: "\(name).snp.\(forUpdate ? "re" : "")makeConstraints", header: "make") {
            for constraint in element.layout.constraints {
                pipe.lines(from: generateConstraintLine(constraint: constraint, superName: superName, name: name, fallback: false))
            }
        }

        return pipe
    }

    private func generateConstraintLine(constraint: Constraint, superName: String, name: String, fallback: Bool) -> DescriptionPipe {
        var constraintLine = "make.\(constraint.anchor).\(constraint.relation)("

        switch constraint.type {
        case .targeted(let targetDefinition):
            let target: String
            switch targetDefinition.target {
            case .field(let targetName):
                target = "target.\(targetName)"
            case .layoutId(let layoutId):
                target = "named_\(layoutId)"
            case .parent:
                target = superName
            case .this:
                target = name
            case .safeAreaLayoutGuide:
                if fallback {
                    target = "\(superName).fallback_safeAreaLayoutGuide"
                } else {
                    target = "\(superName).safeAreaLayoutGuide"
                }
            case .readableContentGuide:
                target="\(superName).readableContentGuide"
            }
            constraintLine += target
            if targetDefinition.targetAnchor != constraint.anchor {
                constraintLine += ".snp.\(targetDefinition.targetAnchor)"
            }

        case .constant(let constant):
            constraintLine += "\(constant)"
        }
        constraintLine += ")"

        if case .targeted(let targetDefinition) = constraint.type {
            if targetDefinition.constant != 0 {
                constraintLine += ".offset(\(targetDefinition.constant))"
            }
            if targetDefinition.multiplier != 1 {
                constraintLine += ".multipliedBy(\(targetDefinition.multiplier))"
            }
        }

        if constraint.priority.numeric != 1000 {
            constraintLine += ".priority(\(constraint.priority.numeric))"
        }

        if let field = constraint.field {
            constraintLine = "constraints.\(field) = \(constraintLine).constraint"
        }

        let pipe = DescriptionPipe()
        if let condition = constraint.condition {
            pipe.block(line: "if \(condition.generateSwift(viewName: name))") {
                pipe.line(constraintLine)
            }
        } else {
            pipe.line(constraintLine)
        }
        return pipe
    }

    private func constraintFields(element: UIElement) -> [String] {
        var fields = Set<String>()
        for constraint in element.layout.constraints {
            guard let field = constraint.field else { continue }

            fields.insert(field)
        }

        if let container = element as? UIContainer {
            return fields + container.children.flatMap(constraintFields)
        } else {
            return Array(fields)
        }
    }

    private func generateStyles(modifier: String) throws {
        try l("\(modifier)struct \(root.stylesName)") {
            for style in root.styles {
                switch style.type {
                case .attributedText(let styles):
                    try generate(modifier: modifier, attributeTextStyle: style, styles: styles)
                case .view(let type):
                    try generate(modifier: modifier, viewStyle: style, type: type)
                }
            }
        }
    }

    private func generateTemplates(modifier: String) throws {
        try l("\(modifier)struct \(root.templatesName)") {
            for template in root.templates {
                try generate(modifier: modifier, template: template)
            }
        }
    }

    private func generate(modifier: String, template: Template) throws {
        func generate(arguments: [String]) -> String {
            var result = ""
            for argument in arguments {
                result.append("\(argument): String")

                if argument != arguments.last {
                    result.append(", ")
                }
            }

            return result
        }

        switch template.type {
        case .attributedText(let attributedTextTemplate):
            l("public static func \(template.name.name)(\(generate(arguments: attributedTextTemplate.arguments))) -> NSMutableAttributedString") {
                let property = attributedTextTemplate.attributedText
                let propertyContext = PropertyContext(parentContext: componentContext, property: property)

                l("return " + property.application(context: propertyContext))
            }
        }
    }

    // DISCLAIMER: This method is identical to a method with the same signature in `StyleGenerator.swift`. If you're changing the functionality of this method, you most likely want to bring the functionality changes over to that method as well.
    private func generate(modifier: String, attributeTextStyle style: Style, styles: [AttributedTextStyle]) throws {
        func generate(attributes array: [Tokenizer.Property]) {
            for property in array {
                let propertyContext = PropertyContext(parentContext: componentContext, property: property)
                l("Attribute.\(property.name)(\(property.anyValue.generate(context: propertyContext.child(for: property.anyValue)))),")
            }
        }

        l("\(modifier)struct \(style.name.name)") {
            if !style.properties.isEmpty {
                l("private static let ___sharedProperties___: [Reactant.Attribute] = ", encapsulateIn: .brackets) {
                    generate(attributes: style.properties)
                }
            }

            for childStyle in styles {
                l("\(modifier) static let \(childStyle.name): [Reactant.Attribute] = ", encapsulateIn: .none) {

                    // extended styles generation
                    // currently O(n^3 * m) where m is the extension depth level
                    func generateExtensions(from extendedStyles: [StyleName]) {
                        for extendedStyleName in extendedStyles {
                            guard let extendedStyle = componentContext.style(named: extendedStyleName),
                                case .attributedText(let styles) = extendedStyle.type,
                                styles.contains(where: { $0.name == childStyle.name }) else { continue }

                            generateExtensions(from: extendedStyle.extend)

                            l(componentContext.resolvedStyleName(named: extendedStyleName) + ".\(childStyle.name),")
                        }
                    }

                    l("Array<Reactant.Attribute>(subarrays: ")
                    generateExtensions(from: style.extend)
                    if !style.properties.isEmpty {
                        l("___sharedProperties___,")
                    }
                    l("", encapsulateIn: .custom(open: "[", close: "])")) {
                        generate(attributes: childStyle.properties)
                    }
                }
            }
        }
    }

    // DISCLAIMER: This method is identical to a method with the same signature in `StyleGenerator.swift`. If you're changing the functionality of this method, you most likely want to bring the functionality changes over to that method as well.
    private func generate(modifier: String, viewStyle style: Style, type: String) throws {
        guard let mapping = ElementMapping.mapping[type] else {
            throw GeneratorError(message: "Mapping for type \(type) does not exist")
        }

        func styleApplication() {
            for extendedStyle in style.extend {
                switch extendedStyle {
                case .local(let name):
                    l("\(root.stylesName).\(name)(view)")
                case .global(let group, let name):
                    l("\(group.capitalizingFirstLetter() + "Styles").\(name)(view)")
                }
            }
            for property in style.properties {
                let propertyContext = PropertyContext(parentContext: componentContext, property: property)
                l(property.application(on: "view", context: propertyContext))
            }
        }

        if style.requiresTheme(context: componentContext) {
            l("\(modifier)static func \(style.name.name)(theme: ApplicationTheme) -> (_ view: \(try mapping.runtimeType())) -> Void") {
                l("return { view in", encapsulateIn: .none) {
                    styleApplication()
                }
                l("}")
            }

        } else {
            l("\(modifier)static func \(style.name.name)(_ view: \(try mapping.runtimeType()))") {
                styleApplication()
            }
        }
    }
}
