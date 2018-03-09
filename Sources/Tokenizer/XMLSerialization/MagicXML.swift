//
//  MagicXML.swift
//  ReactantUI
//
//  Created by Tadeas Kriz.
//  Copyright © 2017 Brightify. All rights reserved.
//

public protocol MagicElementSerializable {
    func serialize() -> MagicElement
}

public protocol MagicAttributeSerializable {
    func serialize() -> MagicAttribute
}

public struct MagicElement {
    public var name: String
    public var attributes: [MagicAttribute]
    public var children: [MagicElement]

    public init(name: String, attributes: [MagicAttribute], children: [MagicElement]) {
        self.name = name
        self.attributes = attributes
        self.children = children
    }
}

public struct MagicAttribute {
    public var name: String
    public var value: String

    public init(name: String, value: String) {
        self.name = name
        self.value = value
    }
}

public struct MagicAttributeBuilder {
    public let namespace: String
    public private(set) var attributes: [MagicAttribute] = []

    public init(namespace: String = "") {
        self.namespace = namespace
    }

    public mutating func add(attribute: MagicAttribute) {
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

    public mutating func attribute(name: String, value: String) {
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
