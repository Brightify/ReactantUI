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

    public func serialize(context: DataContext) -> String {
        var element = root.serialize(context: context)

        var builder = XMLAttributeBuilder()
        l("<?xml version=\"1.0\" encoding=\"UTF-8\" ?>")
        builder.attribute(name: "xmlns", value: "http://schema.Hyperdrive.tech/ui")
        builder.attribute(name: "xmlns:layout", value: "http://schema.Hyperdrive.tech/layout")
        builder.attribute(name: "xmlns:xsi", value: "http://www.w3.org/2001/XMLSchema-instance")
        builder.attribute(name: "xsi:schemaLocation", value: "http://schema.Hyperdrive.tech/ui https://schema.Hyperdrive.tech/ui.xsd\n" +
            "                        http://schema.Hyperdrive.tech/layout https://schema.Hyperdrive.tech/layout.xsd")
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
