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

    private let styleGroupGenerator: StyleGroupGenerator

    private var tempCounter: Int = 1

    public init(componentContext: ComponentContext, configuration: GeneratorConfiguration) {
        self.root = componentContext.component
        self.componentContext = componentContext
        self.styleGroupGenerator = StyleGroupGenerator(
            context: componentContext,
            styleGroup: StyleGroup(name: root.stylesName, accessModifier: root.modifier, styles: root.styles))
        super.init(configuration: configuration)
    }

    public override func generate(imports: Bool) throws -> Describable {
        let viewAccessibility: Accessibility = componentContext.component.modifier == .public || configuration.defaultModifier == .public ? .public : .internal

        let triggerReloadPaths = [configuration.localXmlPath].map { #""\#($0)""# }.joined(separator: ",\n")

        let viewProperties: [SwiftCodeGen.Property] = [
            .constant(accessibility: viewAccessibility, modifiers: .static, name: "triggerReloadPaths", type: "Set<String>", value: "[\(triggerReloadPaths)]"),
            .constant(accessibility: viewAccessibility, name: "layout", value: "Constraints()"),
            .constant(accessibility: viewAccessibility, name: "state", type: "State"),
            .constant(accessibility: .private, name: "actionPublisher", type: "ActionPublisher<Action>"),
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

        let loadViewPipe = DescriptionPipe()
        var themedProperties = [:] as [String: [Tokenizer.Property]]
        for property in root.properties {
            guard !property.anyValue.requiresTheme else {
                themedProperties["self", default: []].append(property)
                continue
            }
            if case .state = property.anyValue { continue }
            let propertyContext = PropertyContext(parentContext: componentContext, property: property)
            loadViewPipe.line(property.application(on: "self", context: propertyContext))
        }

        try loadViewPipe.append(root.children.map {
            try generate(element: $0, superName: "self", containedIn: root, themedProperties: &themedProperties)
        })

        if !themedProperties.isEmpty {
            loadViewPipe.block(line: "ApplicationTheme.selector.register(target: self, listener:", encapsulateIn: .custom(open: "{", close: "})"), header: "[weak self] theme") {
                loadViewPipe.line("guard let self = self else { return }")
                for (name, properties) in themedProperties {
                    for property in properties {
                        let propertyContext = PropertyContext(parentContext: componentContext, property: property)
                        loadViewPipe.line(property.application(on: "self." + name, context: propertyContext))
                    }
                }
            }
        }

        let loadView = Function(
            accessibility: .private,
            name: "loadView",
            block: loadViewPipe.result)

        let setupConstraints = Function(
            accessibility: .private,
            name: "setupConstraints",
            block: DescriptionPipe().append(root.children.map {
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
                block: ["guard let owner = owner else { return }"] + item.applications.map { item in
                    let propertyContext = PropertyContext(parentContext: componentContext, property: item.property.property)
                    let view = (item.element as? UIElement).map { "owner.\($0.id.description)" } ?? "owner"
                    return item.property.property.application(on: view, context: propertyContext)
                })
        }

        let stateFunctions: [Function] = [
            .initializer(accessibility: viewAccessibility),
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

        let stateClass = Structure.class(
            accessibility: viewAccessibility,
            isFinal: true,
            name: "State",
            inheritances: ["HyperViewState"],
            properties: stateProperties + stateVariables,
            functions: stateFunctions + stateNotifyFunctions)

        let actionEnum = Structure.enum(
            accessibility: viewAccessibility,
            name: "Action",
            cases: try componentContext.resolve(actions: root.providedActions).map { action in
                Structure.EnumCase(name: action.name, arguments: action.parameters.map { parameter -> (name: String?, type: String) in
                    (name: parameter.label, type: parameter.type.runtimeType(for: .iOS).name)
                })
            })

        let constraintFields = root.children.flatMap(self.constraintFields)

        let constraintsClass = Structure.class(
            accessibility: viewAccessibility,
            isFinal: true,
            name: "Constraints",
            properties: constraintFields)

        let viewClass = Structure.class(
            accessibility: viewAccessibility,
            isFinal: true,
            name: root.type,
            inheritances: ["HyperViewBase", "HyperView"],
            containers: [stateClass, actionEnum, constraintsClass],
            properties: viewProperties + viewDeclarations,
            functions: [viewInit, loadView, setupConstraints])

        if false && root.type == "ATest" {
            viewClass.describe(into: DebugDescriptionPipe())
            exit(0)
        }

//        let constraintFields = root.children.flatMap(self.constraintFields)
//        try l("extension \(root.type): ReactantUI" + (root.isRootView ? ", RootView" : "")) {
//            if root.isRootView {
//                l("\(modifier)var edgesForExtendedLayout: UIRectEdge") {
//                    if configuration.isLiveEnabled {
//                        if configuration.swiftVersion >= .swift4_1 {
//                            l("#if targetEnvironment(simulator)")
//                        } else {
//                            l("#if (arch(i386) || arch(x86_64)) && (os(iOS) || os(tvOS))")
//                        }
//                        l("return bundleWorker.extendedEdges(of: self)")
//                        l("#else")
//                    }
//                    l("return \(RectEdge.toGeneratedString(root.edgesForExtendedLayout))")
//                    if configuration.isLiveEnabled {
//                        l("#endif")
//                    }
//                }
//            }
//            l()
//            l("\(modifier)var rui: \(root.type).RUIContainer") {
//                l("return Reactant.associatedObject(self, key: &\(root.type).RUIContainer.associatedObjectKey)") {
//                    l("return \(root.type).RUIContainer(target: self)")
//                }
//            }
//            l()
//            l("\(modifier)var __rui: Reactant.ReactantUIContainer") {
//                l("return rui")
//            }
//            l()
//            try l("\(modifier)final class RUIContainer: Reactant.ReactantUIContainer") {
//                l("fileprivate static var associatedObjectKey = 0 as UInt8")
//                l()
//                l("\(modifier)var xmlPath: String") {
//                    l("return \"\(configuration.localXmlPath)\"")
//                }
//                l()
//                l("\(modifier)var typeName: String") {
//                    l("return \"\(root.type)\"")
//                }
//                l()
//                l("\(modifier)let constraints = \(root.type).LayoutContainer()")
//                l()
//                l("private weak var target: \(root.type)?")
//                l()
//
//                tempCounter = 1
//                l()
//                l("fileprivate init(target: \(root.type))") {
//                    l("self.target = target")
//                }
//                l()
//                try l("\(modifier)func setupReactantUI()") {
//                    l("guard let target = self.target else { /* FIXME Should we fatalError here? */ return }")
//                    if configuration.isLiveEnabled {
//                        if configuration.swiftVersion >= .swift4_1 {
//                            l("#if targetEnvironment(simulator)")
//                        } else {
//                            l("#if (arch(i386) || arch(x86_64)) && (os(iOS) || os(tvOS))")
//                        }
//                        // This will register `self` to remove `deinit` from ViewBase
//                        l("bundleWorker.register(target)") {
//
//                            if constraintFields.isEmpty {
//                                l("_, _ in")
//                                l("return false")
//                            } else {
//                                l("[constraints] field, constraint -> Bool in")
//                                l("switch field") {
//                                    for constraintField in constraintFields {
//                                        l("case \"\(constraintField)\":")
//                                        l("    constraints.\(constraintField) = constraint")
//                                        l("    return true")
//                                    }
//                                    l("default:")
//                                    l("    return false")
//                                }
//                            }
//                        }
//                        l("#else")
//                    }
//                    var themedProperties = [:] as [String: [Tokenizer.Property]]
//                    for property in root.properties {
//                        guard !property.anyValue.requiresTheme else {
//                            themedProperties["target", default: []].append(property)
//                            continue
//                        }
//                        let propertyContext = PropertyContext(parentContext: componentContext, property: property)
//                        l(property.application(on: "target", context: propertyContext))
//                    }
//                    try root.children.forEach {
//                        try generate(element: $0, superName: "target", containedIn: root, themedProperties: &themedProperties)
//                    }
//
//                    if !themedProperties.isEmpty {
//                        l("ApplicationTheme.selector.register(target: target, listener: { [weak target] theme in")
//                        l("guard let target = target else { return }")
//                        for (name, properties) in themedProperties {
//                            for property in properties {
//                                let propertyContext = PropertyContext(parentContext: componentContext, property: property)
//                                l(property.application(on: name, context: propertyContext))
//                            }
//                        }
//                        l("})")
//                    }
//
//
//                    tempCounter = 1
//                    root.children.forEach { generateConstraints(element: $0, superName: "target", forUpdate: false) }
//                    if configuration.isLiveEnabled {
//                        l("#endif")
//                    }
//                }
//                l()
//                l("\(modifier)func updateReactantUI()") {
//                    l("guard let target = self.target else { /* FIXME Should we fatalError here? */ return }")
//
//                    if configuration.isLiveEnabled {
//                        if configuration.swiftVersion >= .swift4_1 {
//                            l("#if targetEnvironment(simulator)")
//                        } else {
//                            l("#if (arch(i386) || arch(x86_64)) && (os(iOS) || os(tvOS))")
//                        }
//                        // This will reapply the component definition.
//                        // TODO Do a real "update" instead of "remake" that's being done now
//                        l("bundleWorker.reapply(target)")
//                        l("#else")
//                    }
//
//                    // TODO: Add conditional properties?
////                    for property in root.properties {
////                        l(property.application(on: "target"))
////                    }
////                    try root.children.forEach { try generate(element: $0, superName: "target", containedIn: root) }
//
//                    tempCounter = 1
//                    root.children.forEach { generateConstraints(element: $0, superName: "target", forUpdate: true) }
//
//                    if configuration.isLiveEnabled {
//                        l("#endif")
//                    }
//                }
//                l()
//                l("\(modifier)static func destroyReactantUI(target: UIView)") {
//                    if configuration.isLiveEnabled {
//                        l(ifSimulator("""
//                                      guard let knownTarget = target as? \(root.type) else { /* FIXME Should we fatalError here? */ return }
//                                      bundleWorker.unregister(knownTarget)
//                                """))
//                    }
//
//                    l("ApplicationTheme.selector.unregister(target: target)")
//                }
//            }
//            l()
//            l("\(modifier)final class LayoutContainer") {
//                for constraintField in constraintFields {
//                    l("fileprivate(set) var \(constraintField): SnapKit.Constraint?")
//                }
//            }
//            try generateStyles(modifier: modifier)
//            try generateTemplates(modifier: modifier)
//        }

        let styleExtension = try Structure.extension(
            accessibility: viewAccessibility,
            extendedType: root.type,
            containers: [
                try styleGroupGenerator.generateStyles(accessibility: viewAccessibility),
                try generateTemplates(accessibility: viewAccessibility),
            ])

        return [viewClass, styleExtension]
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
            if case .state = property.anyValue { continue }

            let propertyContext = PropertyContext(parentContext: componentContext, property: property)
            pipe.line(property.application(on: name, context: propertyContext))
        }
        pipe.line("\(superName).\(containedIn.addSubviewMethod)(\(name))")
        pipe.line()
        if let container = element as? UIContainer {
            try container.children.forEach {
                pipe.append(try generate(element: $0, superName: name, containedIn: container, themedProperties: &themedProperties))
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
                    pipe.append(generateConstraints(element: $0, superName: name, forUpdate: forUpdate))
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
                pipe.append(generateConstraintLine(constraint: constraint, superName: superName, name: name, fallback: false))
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
            case .identifier(let id):
                target = id
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
            constraintLine = "layout.\(field) = \(constraintLine).constraint"
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

    private func constraintFields(element: UIElement) -> [SwiftCodeGen.Property] {
        var fields = Set<String>()
        for constraint in element.layout.constraints {
            guard let field = constraint.field else { continue }

            fields.insert(field)
        }

        let properties = fields.map { field in
            SwiftCodeGen.Property.variable(name: field, type: "Constraint?")
        }

        if let container = element as? UIContainer {
            return properties + container.children.flatMap(constraintFields)
        } else {
            return properties
        }
    }

    private func generateTemplates(accessibility: Accessibility) throws -> Structure {
        return try Structure.struct(
            accessibility: accessibility,
            name: root.templatesName,
            functions: root.templates.map { template in
                try generate(accessibility: accessibility, template: template)
            })
    }

    private func generate(accessibility: Accessibility, template: Template) throws -> Function {
        switch template.type {
        case .attributedText(let attributedTextTemplate):
            let property = attributedTextTemplate.attributedText
            let propertyContext = PropertyContext(parentContext: componentContext, property: property)

            return Function(
                accessibility: accessibility,
                modifiers: .static,
                name: template.name.name,
                parameters: attributedTextTemplate.arguments.map {
                    MethodParameter(name: $0, type: "String")
                },
                returnType: "NSMutableAttributedString",
                block: [
                    "return " + property.application(context: propertyContext)
                ])
        }
    }

}
