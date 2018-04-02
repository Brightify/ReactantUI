//
//  XMLSerializer.swift
//  ReactantUI
//
//  Created by Tadeas Kriz.
//  Copyright © 2017 Brightify. All rights reserved.
//

public class XMLSerializer {
    private enum NewLinePosition {
        case before
        case after
        case none
    }

    public let root: XMLElementSerializable
    private var nestLevel: Int = 0
    private var result = ""

    public init(root: XMLElementSerializable) {
        self.root = root
    }

    public func serialize() -> String {
        var element = root.serialize()

        var builder = XMLAttributeBuilder()
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

    private func serialize(element: XMLSerializableElement) {
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
