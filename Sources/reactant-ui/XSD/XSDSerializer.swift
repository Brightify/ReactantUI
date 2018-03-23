//
//  XSDSerialized.swift
//  reactant-ui
//
//  Created by Matouš Hýbl on 21/03/2018.
//

import Foundation
import Tokenizer

public class XSDSerializer {
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

        builder.attribute(name: "xmlns:xs", value: "http://www.w3.org/2001/XMLSchema")
        builder.attribute(name: "targetNamespace", value: "http://schema.reactant.tech/ui")
        builder.attribute(name: "xmlns", value: "http://schema.reactant.tech/ui")
        builder.attribute(name: "elementFormDefault", value: "qualified")
        builder.attribute(name: "vc:minVersion", value: "1.1")
        builder.attribute(name: "xmlns:vc", value: "http://www.w3.org/2007/XMLSchema-versioning")
        builder.attribute(name: "xmlns:layout", value: "http://schema.reactant.tech/layout")

        element.attributes.insert(contentsOf: builder.attributes, at: 0)

        let `import` = MagicElement(name: "xs:import",
                                    attributes: [MagicAttribute(name: "namespace", value: "http://schema.reactant.tech/layout"),
                                                 MagicAttribute(name: "schemaLocation", value: "layout.xsd")],
                                    children: [])
        element.children.insert(`import`, at: 0)
        element.children.insert(XSDComponentRootElement().serialize(), at: 1)

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

