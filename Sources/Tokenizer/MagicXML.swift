//
//  MagicXML.swift
//  ReactantUI
//
//  Created by Tadeas Kriz.
//  Copyright © 2017 Brightify. All rights reserved.
//

public class Generator {
}


public protocol MagicElementSerializable {
    func serialize() -> MagicElement
}

public protocol MagicAttributeSerializable {
    func serialize() -> MagicAttribute
}

public struct MagicElement {
    var name: String
    var attributes: [MagicAttribute]
    var children: [MagicElement]
}

public struct MagicAttribute {
    var name: String
    var value: String
}

public struct MagicAttributeBuilder {
    let namespace: String
    private(set) var attributes: [MagicAttribute] = []

    public init(namespace: String = "") {
        self.namespace = namespace
    }

    mutating func add(attribute: MagicAttribute) {
        var newAttribute = attribute
        if !namespace.isEmpty {
            newAttribute.name = "\(namespace):\(newAttribute.name)"
        }

        if let index = attributes.index(where: { $0.name == attribute.name }) {
            swap(&attributes[index], &newAttribute)
        } else {
            attributes.append(newAttribute)
        }
    }

    mutating func attribute(name: String, value: String) {
        add(attribute: MagicAttribute(name: name, value: value))
    }
}

public class MagicSerializer {
    private enum NewLinePosition {
        case before
        case after
        case none
    }

    public let root: MagicElementSerializable
    private var nestLevel: Int = 0
    private var result = ""

    public init(root: MagicElementSerializable) {
        self.root = root
    }

    public func serialize() -> String {
        var element = root.serialize()

        var builder = MagicAttributeBuilder()
        l("<?xml version=\"1.0\" encoding=\"UTF-8\" ?>")
        builder.attribute(name: "xmlns", value: "http://schema.reactant.tech/ui")
        builder.attribute(name: "xmlns:layout", value: "http://schema.reactant.tech/layout")
        builder.attribute(name: "xmlns:xsi", value: "http://www.w3.org/2001/XMLSchema-instance")
        builder.attribute(name: "xsi:schemaLocation", value: "http://schema.reactant.tech/ui https://schema.reactant.tech/ui.xsd\n" +
            "                        http://schema.reactant.tech/layout https://schema.reactant.tech/layout.xsd")
        element.attributes.insert(contentsOf: builder.attributes, at: 0)

        serialize(element: element)

        return result
    }

    private func serialize(element: MagicElement) {
        l("<\(element.name)", newLine: .none) {
            if !element.attributes.isEmpty {
                l()
            }
            for (index, attribute) in element.attributes.enumerated() {
                l("\(attribute.name)=\"\(attribute.value)\"", newLine: index != element.attributes.endIndex - 1 ? .after : .none)
            }

            if element.children.isEmpty {
                l("/>", indent: false)
            } else {
                l(">", indent: false)
                for child in element.children {
                    serialize(element: child)
                }
            }
        }
        if !element.children.isEmpty {
            l("</\(element.name)>")
        }
    }

//    private func serialize(element: UIElement) {
//        let isContainer = element is UIContainer
//        let name = "\(type(of: element))"
//        l("<\(name)") {
//            for property in element.properties {
//                l("\(property.attributeName)=\"\(property.value.generated)\"")
//            }
//            l(">")
//            if let container = element as? UIContainer {
//                for child in container.children {
//                    serialize(element: child)
//                }
//            }
//        }
//        l("</\(name)>")
//    }

    private func l(_ line: String = "", newLine: NewLinePosition = .after, indent: Bool = true) {
        if newLine == .before {
            result += "\n"
        }
        if indent {
            result += (0..<nestLevel).map { _ in "    " }.joined()
        }
        result += line
        if newLine == .after {
            result += "\n"
        }
    }

    private func l(_ line: String = "", newLine: NewLinePosition = .after, _ f: () -> Void) {
        if newLine == .before {
            result += "\n"
        }
        result += (0..<nestLevel).map { _ in "    " }.joined() + line
        if newLine == .after {
            result += "\n"
        }

        nestLevel += 1
        f()
        nestLevel -= 1
    }
}

extension ComponentDefinition: MagicElementSerializable {

    public func serialize() -> MagicElement {
        var builder = MagicAttributeBuilder()
        
        if isRootView {
            builder.attribute(name: "rootView", value: "true")
        }
        
        let extend = edgesForExtendedLayout.map { $0.rawValue }.joined(separator: " ")
        if !extend.isEmpty {
            builder.attribute(name: "extend", value: extend)
        }
        if isAnonymous {
            builder.attribute(name: "anonymous", value: "true")
        }
        
        let styleNameAttribute = stylesName == "Styles" ? [] : [MagicAttribute(name: "name", value: stylesName)]
        let stylesElement = styles.isEmpty ? [] : [MagicElement(name: "styles", attributes: styleNameAttribute, children: styles.map { $0.serialize() })]
        
        let childElements = children.map { $0.serialize() }

        #if SanAndreas
        toolingProperties.map { _, property in property.dematerialize() }.forEach { builder.add(attribute: $0) }
        #endif

        var viewElement = MagicElement(name: "Component", attributes: builder.attributes, children: stylesElement + childElements)
        viewElement.attributes.insert(MagicAttribute(name: "type", value: type), at: 0)
        
        return viewElement
    }
}

extension Container {
}

extension Style: MagicElementSerializable {
    public func serialize() -> MagicElement {
        //        public let type: String
        //        // this is name with group
        //        public let name: String
        //        // this is name of the style without group name
        //        public let styleName: String
        //        public let extend: [String]
        //        public let properties: [Property]
        
        /*
         self.type = type
         // FIXME The name has to be done some other way
         let name = try node.value(ofAttribute: "name") as String
         self.styleName = name
         if let groupName = groupName {
         self.name = ":\(groupName):\(name)"
         } else {
         self.name = name
         }
         self.extend = (node.value(ofAttribute: "extend") as String?)?.components(separatedBy: " ") ?? []
         self.properties = properties
         */
        
        var builder = MagicAttributeBuilder()
        builder.attribute(name: "name", value: name)
        let extendedStyles = extend.joined(separator: " ")
        if !extendedStyles.isEmpty {
            builder.attribute(name: "extend", value: extendedStyles)
        }
        #if SanAndreas
        properties.map { $0.dematerialize() }.forEach { builder.add(attribute: $0) }
        #endif
        
        return MagicElement(name: "\(type)Style", attributes: builder.attributes, children: [])
    }
}

extension Layout {
    public func serialize() -> [MagicAttribute] {
        var builder = MagicAttributeBuilder(namespace: "layout")
        
        if let id = id {
            builder.attribute(name: "id", value: id)
        }
        
        if let horizontalCompressionPriority = contentCompressionPriorityHorizontal,
            let verticalCompressionPriority = contentCompressionPriorityVertical,
            horizontalCompressionPriority == verticalCompressionPriority {
            
            builder.attribute(name: "compressionPriority", value: horizontalCompressionPriority.serialized)
        } else {
            if let horizontalCompressionPriority = contentCompressionPriorityHorizontal {
                builder.attribute(name: "compressionPriority.horizontal", value: horizontalCompressionPriority.serialized)
            }
            if let verticalCompressionPriority = contentCompressionPriorityVertical {
                builder.attribute(name: "compressionPriority.vertical", value: verticalCompressionPriority.serialized)
            }
        }
        
        if let horizontalHuggingPriority = contentCompressionPriorityHorizontal,
            let verticalHuggingPriority = contentCompressionPriorityVertical,
            horizontalHuggingPriority == verticalHuggingPriority {
            
            builder.attribute(name: "huggingPriority", value: horizontalHuggingPriority.serialized)
        } else {
            if let horizontalHuggingPriority = contentCompressionPriorityHorizontal {
                builder.attribute(name: "huggingPriority.horizontal", value: horizontalHuggingPriority.serialized)
            }
            if let verticalHuggingPriority = contentHuggingPriorityVertical {
                builder.attribute(name: "huggingPriority.vertical", value: verticalHuggingPriority.serialized)
            }
        }
        
        ConstraintShortcutOrConstraint.detect(in: constraints)
            .map { $0.serialize() }
            .forEach { builder.add(attribute: $0) }
        
        return builder.attributes
    }
}

extension ConstraintPriority: Equatable {
    public static func ==(lhs: ConstraintPriority, rhs: ConstraintPriority) -> Bool {
        switch (lhs, rhs) {
        case (.required, .required), (.high, .high), (.medium, .medium), (.low, .low):
            return true
        case (.custom(let lhsValue), .custom(let rhsValue)):
            return lhsValue == rhsValue
        default:
            return false
        }
    }
}

extension ConstraintPriority {
    
    public var serialized: String {
        switch self {
        case .required:
            return "required"
        case .high:
            return "high"
        case .medium:
            return "medium"
        case .low:
            return "low"
        case .custom(let value):
            return "\(value)"
        }
    }
}

extension ConstraintRelation {
    
    public var serialized: String {
        switch self {
        case .equal:
            return "eq"
        case .lessThanOrEqual:
            return "lt"
        case .greaterThanOrEqual:
            return "gt"
        }
    }

}

private enum ConstraintShortcutOrConstraint {
    case shortcut(shortcut: ConstraintShortcut, Constraint)
    case constraint(Constraint)
    
    func serialize() -> MagicAttribute {
        switch self {
        case .shortcut(let shortcut, let constraint):
            var attribute = constraint.serialize()
            attribute.name = shortcut.rawValue
            return attribute
            
        case .constraint(let constraint):
            return constraint.serialize()
        }
    }
    
    static func detect(in constraints: [Constraint]) -> [ConstraintShortcutOrConstraint] {
        var mutableConstraints = constraints
        
        var result = [] as [ConstraintShortcutOrConstraint]
        for shortcut in ConstraintShortcut.allValues {
            let constraintsForShortcut = mutableConstraints.filter { shortcut.attributes.contains($0.attribute) }
            guard constraintsForShortcut.count == shortcut.attributes.count else { continue }
            let grouped = constraintsForShortcut.groupBy { $0.serialize().value }
            for (key, group) in grouped {
                let groupAttributes = Set(group.map { $0.attribute })
                guard groupAttributes == shortcut.attributes else { continue }
                guard let firstConstraint = group.first else { continue }
                
                result.append(.shortcut(shortcut: shortcut, firstConstraint))
                constraintsForShortcut.forEach { constraint in
                    guard let index = mutableConstraints.index(of: constraint) else { return }
                    mutableConstraints.remove(at: index)
                }
            }
            
//            let allConstraintsEqual = equal(constraintsForShortcut) { lhs, rhs in
//                guard lhs.field == rhs.field else { return false }
//                guard lhs.relation == rhs.relation else { return false }
//                guard lhs.priority == rhs.priority else { return false }
//                
//                switch (lhs.type, rhs.type) {
//                case (.targeted(let lhsTargeted), .targeted(let rhsTargeted)):
//                    let conditions: [Bool] = [
//                        lhsTargeted.targetAnchor == lhs.anchor,
//                        rhsTargeted.targetAnchor == rhs.anchor,
//                        lhsTargeted.target == rhsTargeted.target,
//                        lhsTargeted.constant == rhsTargeted.constant
//                    ]
//                    
//                    // Check if all conditions are true
//                    guard conditions.first(where: { $0 == false }) == nil else { return false }
//                case (.constant(let lhsConstant), .constant(let rhsConstant)):
//                    guard lhsConstant == rhsConstant else { return false }
//                default:
//                    return false
//                }
//                
//                // If we get all the way here they are equal
//                return true
//            }
//            
//            guard allConstraintsEqual else { continue }
//            
//            removedAttributes.append(contentsOf: shortcut.attributes)
//            shortcut.attributes.forEach { constraintDictionary.removeValue(forKey: $0) }
            
            
        }
        
        result.append(contentsOf: mutableConstraints.map(ConstraintShortcutOrConstraint.constraint))
        
        return result
    }
}

private enum ConstraintShortcut: String {
    case edges
    case fillHorizontally
    case fillVertically
    case center
    case before
    case after
    
    var attributes: Set<LayoutAttribute> {
        switch self {
        case .edges:
            return [.left, .right, .top, .bottom]
        case .fillHorizontally:
            return [.left, .right]
        case .fillVertically:
            return [.top, .bottom]
        case .center:
            return [.centerX, .centerY]
        case .before:
            return [.before]
        case .after:
            return [.after]
        }
    }
    
    static let allValues: [ConstraintShortcut] = [.edges, .fillHorizontally, .fillVertically, .center, .before, .after]
}

extension Collection {
    
    public func groupBy<KEY: Hashable>(_ extractKey: (Iterator.Element) -> KEY) -> [(KEY, [Iterator.Element])] {
        return groupBy { Optional(extractKey($0)) }
    }
    
    public func groupBy<KEY: Hashable>(_ extractKey: (Iterator.Element) -> KEY?) -> [(KEY, [Iterator.Element])] {
        var grouped: [(KEY, [Iterator.Element])] = []
        var t: [String] = []
        func add(_ item: Iterator.Element, forKey key: KEY) {
            if let index = grouped.index(where: { $0.0 == key }) {
                var value = grouped[index]
                value.1.append(item)
                grouped[index] = (key, value.1)
            } else {
                grouped.append((key, [item]))
            }
        }
        
        for item in self {
            guard let key = extractKey(item) else {
                continue
            }
            add(item, forKey: key)
        }
        return grouped
    }
}
