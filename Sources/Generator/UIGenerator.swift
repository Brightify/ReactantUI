//
//  UIGenerator.swift
//  ReactantUIGenerator
//
//  Created by Matouš Hýbl on 26/02/2018.
//

import Foundation
import Tokenizer

public class UIGenerator: Generator {
    public let root: ComponentDefinition

    private var tempCounter: Int = 1

    public init(definition: ComponentDefinition, configuration: GeneratorConfiguration) {
        self.root = definition
        super.init(configuration: configuration)
    }

    public override func generate(imports: Bool) throws -> String {
        if root.isAnonymous {
            l("final class \(root.type): ViewBase<Void, Void>") { }
        }
        let constraintFields = root.children.flatMap(self.constraintFields)
        try l("extension \(root.type): ReactantUI" + (root.isRootView ? ", RootView" : "")) {
            if root.isRootView {
                l("var edgesForExtendedLayout: UIRectEdge") {
                    if configuration.isLiveEnabled {
                        if configuration.swiftVersion >= .swift4_1 {
                            l("#if targetEnvironment(simulator)")
                        } else {
                            l("#if (arch(i386) || arch(x86_64)) && (os(iOS) || os(tvOS))")
                        }
                        l("return ReactantLiveUIManager.shared.extendedEdges(of: self)")
                        l("#else")
                    }
                    l("return \(RectEdge.toGeneratedString(root.edgesForExtendedLayout))")
                    if configuration.isLiveEnabled {
                        l("#endif")
                    }
                }
            }
            l()
            l("var rui: \(root.type).RUIContainer") {
                l("return Reactant.associatedObject(self, key: &\(root.type).RUIContainer.associatedObjectKey)") {
                    l("return \(root.type).RUIContainer(target: self)")
                }
            }
            l()
            l("var __rui: Reactant.ReactantUIContainer") {
                l("return rui")
            }
            l()
            try l("final class RUIContainer: Reactant.ReactantUIContainer") {
                l("fileprivate static var associatedObjectKey = 0 as UInt8")
                l()
                l("var xmlPath: String") {
                    l("return \"\(configuration.localXmlPath)\"")
                }
                l()
                l("var typeName: String") {
                    l("return \"\(root.type)\"")
                }
                l()
                l("let constraints = \(root.type).LayoutContainer()")
                l()
                l("private weak var target: \(root.type)?")
                l()
                for name in root.children.generatedNames(tempCounter: &tempCounter) {
                    l("private weak var \(name): UIView?")
                }
                tempCounter = 1
                l()
                l("fileprivate init(target: \(root.type))") {
                    l("self.target = target")
                }
                l()
                try l("func setupReactantUI()") {
                    l("guard let target = self.target else { /* FIXME Should we fatalError here? */ return }")
                    if configuration.isLiveEnabled {
                        if configuration.swiftVersion >= .swift4_1 {
                            l("#if targetEnvironment(simulator)")
                        } else {
                            l("#if (arch(i386) || arch(x86_64)) && (os(iOS) || os(tvOS))")
                        }
                        // This will register `self` to remove `deinit` from ViewBase
                        l("ReactantLiveUIManager.shared.register(target)") {

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
                    for property in root.properties {
                        l(property.application(on: "target"))
                    }
                    try root.children.forEach { try generate(element: $0, superName: "target", containedIn: root) }
                    tempCounter = 1
                    root.children.forEach { generateConstraints(element: $0, superName: "target", forUpdate: false) }
                    if configuration.isLiveEnabled {
                        l("#endif")
                    }
                }
                l()
                l("func updateReactantUI()") {
                    tempCounter = 1
                    let guardNames = ["target"] + root.children.generatedNames(tempCounter: &tempCounter)
                    l("guard ")
                    for guardName in guardNames {
                        l("  let \(guardName) = self.\(guardName)\(guardName == guardNames.last ? "" : ",")")
                    }
                    l("else { /* FIXME Should we fatalError here? */ return }")

                    if configuration.isLiveEnabled {
                        if configuration.swiftVersion >= .swift4_1 {
                            l("#if targetEnvironment(simulator)")
                        } else {
                            l("#if (arch(i386) || arch(x86_64)) && (os(iOS) || os(tvOS))")
                        }
                        // This will register `self` to remove `deinit` from ViewBase
                        //l("ReactantLiveUIManager.shared.update(target)")
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
                l("static func destroyReactantUI(target: UIView)") {
                    if configuration.isLiveEnabled {
                        l(ifSimulator("""
                                      guard let knownTarget = target as? \(root.type) else { /* FIXME Should we fatalError here? */ return }
                                      ReactantLiveUIManager.shared.unregister(knownTarget)
                                """))
                    }
                }
            }
            l()
            l("final class LayoutContainer") {
                for constraintField in constraintFields {
                    l("fileprivate(set) var \(constraintField): SnapKit.Constraint?")
                }
            }
            try generateStyles()
        }

        return output
    }

    private func generate(element: UIElement, superName: String, containedIn: UIContainer) throws {
        let name: String
        if let field = element.field {
            name = "target.\(field)"
        } else if let layoutId = element.layout.id {
            name = "named_\(layoutId)"
            l("let \(name) = \(try element.initialization())")
            l("self.\(name) = \(name)")
        } else {
            name = "temp_\(type(of: element))_\(tempCounter)"
            tempCounter += 1
            l("let \(name) = \(try element.initialization())")
            l("self.\(name) = \(name)")
        }

        for style in element.styles {
            if style.hasPrefix(":") {
                let components = style[style.index(after: style.startIndex)...].components(separatedBy: ":")
                if components.count != 2 {
                    print("// Global style \(style) assignment has wrong format.")
                }
                let stylesName = components[0].capitalizingFirstLetter() + "Styles"
                let style = components[1]

                l("\(name).apply(style: \(stylesName).\(style))")
            } else {
                l("\(name).apply(style: \(root.stylesName).\(style))")
            }
        }

        for property in element.properties {
            l(property.application(on: name))
        }
        l("\(superName).\(containedIn.addSubviewMethod)(\(name))")
        l()
        if let container = element as? UIContainer {
            try container.children.forEach { try generate(element: $0, superName: name, containedIn: container) }
        }
    }

    private func generateConstraints(element: UIElement, superName: String, forUpdate: Bool) {
        let name: String
        if let field = element.field {
            name = "target.\(field)"
        } else if let layoutId = element.layout.id {
            name = "named_\(layoutId)"
        } else {
            name = "temp_\(type(of: element))_\(tempCounter)"
            tempCounter += 1
        }

        defer {
            if let container = element as? UIContainer {
                container.children.forEach { generateConstraints(element: $0, superName: name, forUpdate: forUpdate) }
            }
        }
        // we want to continue only if we are generating constraints for update AND the layout has conditions
        // on the other hand, if it's the first time this method is called (not from update), we don't want to
        // generate the constraints if the layout has any conditions in it (they will be handled in update later)
        guard forUpdate == element.layout.hasConditions else { return }

        if let horizontalCompressionPriority = element.layout.contentCompressionPriorityHorizontal {
            l("\(name).setContentCompressionResistancePriority(UILayoutPriority(rawValue: \(horizontalCompressionPriority.numeric)), for: .horizontal)")
        }

        if let verticalCompressionPriority = element.layout.contentCompressionPriorityVertical {
            l("\(name).setContentCompressionResistancePriority(UILayoutPriority(rawValue: \(verticalCompressionPriority.numeric)), for: .vertical)")
        }

        if let horizontalHuggingPriority = element.layout.contentHuggingPriorityHorizontal {
            l("\(name).setContentHuggingPriority(UILayoutPriority(rawValue: \(horizontalHuggingPriority.numeric)), for: .horizontal)")
        }

        if let verticalHuggingPriority = element.layout.contentHuggingPriorityVertical {
            l("\(name).setContentHuggingPriority(UILayoutPriority(rawValue: \(verticalHuggingPriority.numeric)), for: .vertical)")
        }
        l()
        // we're calling `remakeConstraints` if we're called from update
        l("\(name).snp.\(forUpdate ? "re" : "")makeConstraints") {
            l("make in")
            for constraint in element.layout.constraints {
                if configuration.minimumMajorVersion < 11 {
                    if case .targeted(target: .safeAreaLayoutGuide, targetAnchor: _, multiplier: _, constant: _) = constraint.type {
                        l("if #available(iOS 11.0, tvOS 11.0, *)") {
                            generateConstraintLine(constraint: constraint, superName: superName, name: name, fallback: false)
                        }
                        l("else") {
                            // If xcode says that there is no such thing as fallback_safeAreaLayoutGuide,
                            // add Reactant/FallbackSafeAreaInsets to your podfile
                            generateConstraintLine(constraint: constraint, superName: superName, name: name, fallback: true)
                        }
                    } else {
                        generateConstraintLine(constraint: constraint, superName: superName, name: name, fallback: false)
                    }
                } else {
                    generateConstraintLine(constraint: constraint, superName: superName, name: name, fallback: false)
                }
            }
        }
    }

    private func generateConstraintLine(constraint: Constraint, superName: String, name: String, fallback: Bool) {
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
                    target = "target.fallback_safeAreaLayoutGuide"
                } else {
                    target = "target.safeAreaLayoutGuide"
                }
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

        if let condition = constraint.condition {
            l("if \(constraint.generateSwiftCondition(condition: condition, viewName: name))") {
                l(constraintLine)
            }
        } else {
            l(constraintLine)
        }
    }

    private func constraintFields(element: UIElement) -> [String] {
        var fields = [] as [String]
        for constraint in element.layout.constraints {
            guard let field = constraint.field else { continue }

            fields.append(field)
        }

        if let container = element as? UIContainer {
            return fields + container.children.flatMap(constraintFields)
        } else {
            return fields
        }
    }

    private func generateStyles() throws {
        try l("struct \(root.stylesName)") {
            for style in root.styles {
                guard let mapping = ElementMapping.mapping[style.type] else {
                    throw GeneratorError(message: "Mapping for type \(style.type) does not exist")
                }
                l("static func \(style.name)(_ view: \(try mapping.runtimeType()))") {
                    for extendedStyle in style.extend {
                        let components = extendedStyle.components(separatedBy: ":").filter { !$0.isEmpty }
                        if let styleName = components.last {
                            if let groupName = components.first, components.count > 1 {
                                l("\(groupName.capitalizingFirstLetter() + "Styles").\(styleName)(view)")
                            } else {
                                l("\(root.stylesName).\(styleName)(view)")
                            }
                        } else {
                            continue
                        }
                    }
                    for property in style.properties {
                        l(property.application(on: "view"))
                    }
                }
            }
        }
    }
}

extension Array where Iterator.Element == UIElement {
    func generatedNames(tempCounter: inout Int) -> [String] {
        var names = [] as [String]
        for child in self {
            defer {
                if let container = child as? UIContainer {
                    names.append(contentsOf: container.children.generatedNames(tempCounter: &tempCounter))
                }
            }

            let name: String
            if child.field != nil {
                continue
            } else if let layoutId = child.layout.id {
                name = "named_\(layoutId)"
            } else {
                name = "temp_\(type(of: child))_\(tempCounter)"
                tempCounter += 1
            }

            names.append(name)
        }

        return names
    }
}
