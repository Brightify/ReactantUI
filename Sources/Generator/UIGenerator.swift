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

        let triggerReloadPaths = Expression.arrayLiteral(items:
            [configuration.localXmlPath].map { Expression.constant(#""\#($0)""#) }
        )



        let viewProperties: [SwiftCodeGen.Property] = [
            .constant(accessibility: viewAccessibility, modifiers: .static, name: "triggerReloadPaths", type: "Set<String>", value: triggerReloadPaths),
            .constant(accessibility: viewAccessibility, name: "layout", value: .constant("Constraints()")),
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
        let viewInitializations = try root.allChildren.flatMap { child -> Statement in
            guard let providesInitialization = child as? ProvidesCodeInitialization else {
                #warning("FIXME Replace with throwing an error")
                fatalError()
            }

            return .assignment(target: .constant(child.id.description), expression: try providesInitialization.initialization(for: .iOS))
        }

        let viewInit = Function.initializer(
            accessibility: viewAccessibility,
            parameters: [
                .init(name: "initialState", type: "State", defaultValue: "State()"),
                .init(name: "actionPublisher", type: "ActionPublisher<Action>"),
            ],
            block: Block(statements: viewInitializations + [
                "",
                "state = initialState",
                "self.actionPublisher = actionPublisher",
                "",
                "super.init()",
                "",
                "loadView()",
                "setupConstraints()",
                "initialState.owner = self",
                "observeActions(actionPublisher: actionPublisher)",
            ].map { Statement.expression(.constant($0)) }))

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
                    .expression(.constant("didSet { notify\(item.name.capitalizingFirstLetter())Changed() }"))
                ])
        }

        let stateNotifyFunctions = stateItems.map { _, item -> Function in
            return Function(
                accessibility: .private,
                modifiers: .final,
                name: "notify\(item.name.capitalizingFirstLetter())Changed",
                block: Block(statements:
                    [.guard(conditions: [ConditionExpression.conditionalUnwrap(isConstant: true, name: "owner", expression: .constant("owner"))], else: [.return(expression: nil)])] +
                    item.applications.map { item in
                        let propertyContext = PropertyContext(parentContext: componentContext, property: item.property.property)
                        let view = (item.element as? UIElement).map { "owner.\($0.id.description)" } ?? "owner"
                        return item.property.property.application(on: view, context: propertyContext)
                    }))
        }

        let stateFunctions: [Function] = [
            .initializer(accessibility: viewAccessibility),
            .init(
                accessibility: viewAccessibility,
                name: "apply",
                parameters: [.init(label: "from", name: "otherState", type: "State")],
                block: Block(statements: stateItems.map { _, item in
                    Statement.assignment(target: .constant(item.name), expression: .constant("otherState.\(item.name)"))
                })),
            .init(
                accessibility: viewAccessibility,
                name: "resynchronize",
                block: Block(statements: stateNotifyFunctions.map {
                    Statement.expression(.invoke(target: .constant($0.name), arguments: []))
                })),
        ]


//        UIControlEventObserver.observe(button, to: actionPublisher)

        let resolvedActions = try componentContext.resolve(actions: root.providedActions)

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
            cases: resolvedActions.map { action in
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

        let viewClass = try Structure.class(
            accessibility: viewAccessibility,
            isFinal: true,
            name: root.type,
            inheritances: ["HyperViewBase", "HyperView"],
            containers: [stateClass, actionEnum, constraintsClass],
            properties: viewProperties + viewDeclarations,
            functions: [viewInit, observeActions(resolvedActions: resolvedActions), loadView(), setupConstraints()])

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

        let styleExtension = Structure.extension(
            accessibility: viewAccessibility,
            extendedType: root.type,
            containers: [
                try styleGroupGenerator.generateStyles(accessibility: viewAccessibility),
                try generateTemplates(accessibility: viewAccessibility),
            ])

        return [viewClass, styleExtension]
    }

    private func observeActions(resolvedActions: [ResolvedHyperViewAction]) throws -> Function {
        return try Function(
            accessibility: .private,
            name: "observeActions",
            parameters: [MethodParameter(name: "actionPublisher", type: "ActionPublisher<Action>")],
            block: resolvedActions.reduce(Block()) { accumulator, action in
                try accumulator + action.observeSources(context: componentContext, actionPublisher: .constant("actionPublisher"))
            })
    }

    private func loadView() throws -> Function {
        var block = Block()
        var themedProperties = [:] as [String: [Tokenizer.Property]]
        for property in root.properties {
            guard !property.anyValue.requiresTheme else {
                themedProperties["self", default: []].append(property)
                continue
            }
            if case .state = property.anyValue { continue }
            let propertyContext = PropertyContext(parentContext: componentContext, property: property)

            block += property.application(on: "self", context: propertyContext)
        }

        for child in root.children {
            block += try propertyApplications(element: child, superName: "self", containedIn: root, themedProperties: &themedProperties)
        }

        if !themedProperties.isEmpty {
            var themeApplicationBlock = Block()

            themeApplicationBlock += .guard(conditions: [.conditionalUnwrap(isConstant: true, name: "self", expression: .constant("self"))], else: [.return(expression: nil)])

            for (name, properties) in themedProperties {
                for property in properties {
                    let propertyContext = PropertyContext(parentContext: componentContext, property: property)
                    themeApplicationBlock += property.application(on: "self." + name, context: propertyContext)
                }
            }

            block += Statement.expression(
                .invoke(target: .constant("ApplicationTheme.selector.register"), arguments: [
                    MethodArgument(name: "target", value: .constant("self")),
                    MethodArgument(name: "listener", value: .closure(
                        Closure(captures: ["weak self"], parameters: [(name: "theme", type: nil)], block: themeApplicationBlock))),
                    ])
            )
        }

        return Function(
            accessibility: .private,
            name: "loadView",
            block: block)
    }

    private func propertyApplications(element: UIElement, superName: String, containedIn: UIContainer, themedProperties: inout [String: [Tokenizer.Property]]) throws -> Block {

        var block = Block()

        let name = element.id.description

        let applyStyle = Expression.member(target: .constant(name), name: "apply")
        for style in element.styles {
            let styleExpression: Expression
            switch style {
            case .local(let styleName):
                styleExpression = .constant("\(root.stylesName).\(styleName)")
            case .global(let group, let styleName):
                let stylesGroupName = group.capitalizingFirstLetter() + "Styles"
                styleExpression = .constant("\(stylesGroupName).\(styleName)")
            }

            block += .expression(
                .invoke(target: applyStyle, arguments: [
                    MethodArgument(name: "style", value: styleExpression)
                ]))
        }

        for property in element.properties {
            guard !property.anyValue.requiresTheme else {
                themedProperties[name, default: []].append(property)
                continue
            }
            if case .state = property.anyValue { continue }

            let propertyContext = PropertyContext(parentContext: componentContext, property: property)
            block += property.application(on: name, context: propertyContext)
        }

        block += .expression(
            .invoke(target: .member(target: .constant(superName), name: containedIn.addSubviewMethod), arguments: [
                MethodArgument(value: .constant(name)),
            ])
        )

        if let container = element as? UIContainer {
            for child in container.children {
                block += try propertyApplications(element: child, superName: name, containedIn: container, themedProperties: &themedProperties)
            }
        }

        return block
    }

    private func setupConstraints() -> Function {
        var block = Block()

        for child in root.children {
            block += viewConstraints(element: child, superName: "self", forUpdate: false)
        }

        return Function(
            accessibility: .private,
            name: "setupConstraints",
            block: block)
    }

    private func viewConstraints(element: UIElement, superName: String, forUpdate: Bool) -> Block{
        var block = Block()

        let name = element.id.description

        let children: Block = (element as? UIContainer)?.children.reduce(Block()) { accumulator, child in
            accumulator + viewConstraints(element: child, superName: name, forUpdate: forUpdate)
        } ?? []

        // we want to continue only if we are generating constraints for update AND the layout has conditions
        // on the other hand, if it's the first time this method is called (not from update), we don't want to
        // generate the constraints if the layout has any conditions in it (they will be handled in update later)
        guard forUpdate == element.layout.hasConditions else {
            return children
        }

        let elementExpression = Expression.constant(name)
        let setContentCompressionResistancePriority = Expression.member(target: elementExpression, name: "setContentCompressionResistancePriority")
        let setContentHuggingPriority = Expression.member(target: elementExpression, name: "setContentHuggingPriority")

        if let horizontalCompressionPriority = element.layout.contentCompressionPriorityHorizontal {
            block += .expression(.invoke(target: setContentCompressionResistancePriority, arguments: [
                .init(value: .constant("UILayoutPriority(rawValue: \(horizontalCompressionPriority.numeric))")),
                .init(name: "for", value: .constant(".horizontal")),
            ]))
        }

        if let verticalCompressionPriority = element.layout.contentCompressionPriorityVertical {
            block += .expression(.invoke(target: setContentCompressionResistancePriority, arguments: [
                .init(value: .constant("UILayoutPriority(rawValue: \(verticalCompressionPriority.numeric))")),
                .init(name: "for", value: .constant(".vertical")),
            ]))
        }

        if let horizontalHuggingPriority = element.layout.contentHuggingPriorityHorizontal {
            block += .expression(.invoke(target: setContentHuggingPriority, arguments: [
                .init(value: .constant("UILayoutPriority(rawValue: \(horizontalHuggingPriority.numeric))")),
                .init(name: "for", value: .constant(".horizontal")),
            ]))
        }

        if let verticalHuggingPriority = element.layout.contentHuggingPriorityVertical {
            block += .expression(.invoke(target: setContentHuggingPriority, arguments: [
                .init(value: .constant("UILayoutPriority(rawValue: \(verticalHuggingPriority.numeric))")),
                .init(name: "for", value: .constant(".vertical")),
            ]))
        }

        let makeConstraints = Expression.member(target: elementExpression, name: "snp.makeConstraints")
        let remakeConstraints = Expression.member(target: elementExpression, name: "snp.remakeConstraints")

        let createConstraintsClosure = Closure(
            parameters: [(name: "make", type: nil)],
            block: element.layout.constraints.reduce(into: Block()) { accumulator, constraint in
                accumulator += viewConstraintLine(constraint: constraint, superName: superName, name: name, fallback: false)
            })

        block += .expression(
            .invoke(target: forUpdate ? remakeConstraints : makeConstraints, arguments: [
                .init(value: .closure(createConstraintsClosure)),
            ])
        )

        return block + children
    }

    private func viewConstraintLine(constraint: Constraint, superName: String, name: String, fallback: Bool) -> Statement {
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

        if let condition = constraint.condition {
            return .if(
                condition: [.expression(condition.generateSwift(viewName: name))],
                then: [
                    .expression(.constant(constraintLine))
                ],
                else: nil)
        } else {
            return .expression(.constant(constraintLine))
        }
    }

    private func constraintFields(element: UIElement) -> [SwiftCodeGen.Property] {
        var fields = Set<String>()
        for constraint in element.layout.constraints {
            guard let field = constraint.field else { continue }

            fields.insert(field)
        }

        let properties = fields.map { field in
            SwiftCodeGen.Property.variable(name: field, type: "SnapKit.Constraint?")
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
                    .return(expression: property.application(context: propertyContext))
                ])
        }
    }

}
