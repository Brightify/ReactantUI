//
//  XSDCommand.swift
//  reactant-ui
//
//  Created by Matouš Hýbl on 09/03/2018.
//

import Generator
import Tokenizer
import Foundation
import SwiftCLI

final class XSDCommand: Command {
    let name = "xsd"
    let shortDescription = "Generate XSD file"

    let outputFile = Key<String>("--outputFile")

    public func execute() throws {
        guard let outputFile = outputFile.value, let outputPathURL = URL(string: "file://\(outputFile)") else {
            throw GenerateCommandError.ouputFileInvalid
        }

        try "".write(to: outputPathURL, atomically: true, encoding: .utf8)
    }
}

struct XSDFile {
    var simpleTypes = Set<XSDSimpleType>()
    var complexTypes = Set<XSDComplexType>()
    var attributeGroups = Set<XSDAttributeGroup>()
    var elements = Set<XSDElement>()
}

class XSDResolver {
    var file = XSDFile()

    func resolve() -> XSDFile {
        for (name, element) in Element.elementMapping {
            resolve(element: element, named: name)
        }

        return file
    }

    func resolve(element: View.Type, named name: String) {
        let xsdElement = XSDElement(name: name)

        for property in element.availableProperties {
            switch property.type.xsdType {
            case .builtin(let builtin):
                break
            case .enumeration(let enumeration):
                break
            case .pattern(let pattern):
                break
            case .union(let union):
                break
            }
        }

        file.elements.insert(xsdElement)
    }
}

struct XSDSimpleType {
    let name: String

    let restrictedValues: [String]

}

extension XSDSimpleType: MagicElementSerializable {
    func serialize() -> MagicElement {
        var attributeBuilder = MagicAttributeBuilder()

        attributeBuilder.attribute(name: "name", value: name)

        let enumerations = restrictedValues.map { value in
            return MagicElement(name: "xs:enumeration", attributes: [ MagicAttribute(name: "value", value: value) ], children: [])
        }

        let restriction = MagicElement(name: "xs:restriction", attributes: [MagicAttribute(name: "base", value: "xs:string")], children: enumerations)

        return MagicElement(name: "xs:simpleType", attributes: attributeBuilder.attributes, children: [restriction])
    }
}

extension XSDSimpleType: Hashable, Equatable {
    var hashValue: Int {
        return name.hashValue
    }

    static func ==(lhs: XSDSimpleType, rhs: XSDSimpleType) -> Bool {
        return lhs.name == rhs.name
    }
}

struct XSDComplexType {
    let name: String
}

extension XSDComplexType: Hashable, Equatable {
    var hashValue: Int {
        return name.hashValue
    }

    static func ==(lhs: XSDComplexType, rhs: XSDComplexType) -> Bool {
        return lhs.name == rhs.name
    }
}

struct XSDAttributeGroup {
    let name: String

    let attributes: [(name: String, typeName: String)]

}

extension XSDAttributeGroup: Hashable, Equatable {
    var hashValue: Int {
        return name.hashValue
    }

    static func ==(lhs: XSDAttributeGroup, rhs: XSDAttributeGroup) -> Bool {
        return lhs.name == rhs.name
    }
}

extension XSDAttributeGroup: MagicElementSerializable {
    func serialize() -> MagicElement {
        let attributes = self.attributes.map {
            MagicElement(name: "xs:attribute",
                         attributes: [MagicAttribute(name: $0.name, value: $0.typeName)],
                         children: [])
        }
        return MagicElement(name: "xs:attributeGroup", attributes: [MagicAttribute(name: "name", value: name)], children: attributes)
    }
}

struct XSDElement {
    let name: String
}

extension XSDElement: Hashable, Equatable {
    var hashValue: Int {
        return name.hashValue
    }

    static func ==(lhs: XSDElement, rhs: XSDElement) -> Bool {
        return lhs.name == rhs.name
    }
}

//public class XSDSerializer {
//    private enum NewLinePosition {
//        case before
//        case after
//        case none
//    }
//
//    public let root: MagicElementSerializable
//    private var nestLevel: Int = 0
//    private var result = ""
//
//    public init(root: MagicElementSerializable) {
//        self.root = root
//    }
//
//    public func serialize() -> String {
//        var element = root.serialize()
//
//        var builder = MagicAttributeBuilder()
//        l("<?xml version=\"1.0\" encoding=\"UTF-8\" ?>")
//        builder.attribute(name: "xmlns", value: "http://schema.reactant.tech/ui")
//        builder.attribute(name: "xmlns:layout", value: "http://schema.reactant.tech/layout")
//        builder.attribute(name: "xmlns:xsi", value: "http://www.w3.org/2001/XMLSchema-instance")
//        builder.attribute(name: "xsi:schemaLocation", value: "http://schema.reactant.tech/ui https://schema.reactant.tech/ui.xsd\n" +
//            "                        http://schema.reactant.tech/layout https://schema.reactant.tech/layout.xsd")
//        element.attributes.insert(contentsOf: builder.attributes, at: 0)
//
//        serialize(element: element)
//
//        return result
//    }
//
//    private func serialize(element: MagicElement) {
//        l("<\(element.name)", newLine: .none) {
//            if !element.attributes.isEmpty {
//                l()
//            }
//            for (index, attribute) in element.attributes.enumerated() {
//                l("\(attribute.name)=\"\(attribute.value)\"", newLine: index != element.attributes.endIndex - 1 ? .after : .none)
//            }
//
//            if element.children.isEmpty {
//                l("/>", indent: false)
//            } else {
//                l(">", indent: false)
//                for child in element.children {
//                    serialize(element: child)
//                }
//            }
//        }
//        if !element.children.isEmpty {
//            l("</\(element.name)>")
//        }
//    }
//
//    //    private func serialize(element: UIElement) {
//    //        let isContainer = element is UIContainer
//    //        let name = "\(type(of: element))"
//    //        l("<\(name)") {
//    //            for property in element.properties {
//    //                l("\(property.attributeName)=\"\(property.value.generated)\"")
//    //            }
//    //            l(">")
//    //            if let container = element as? UIContainer {
//    //                for child in container.children {
//    //                    serialize(element: child)
//    //                }
//    //            }
//    //        }
//    //        l("</\(name)>")
//    //    }
//
//    private func l(_ line: String = "", newLine: NewLinePosition = .after, indent: Bool = true) {
//        if newLine == .before {
//            result += "\n"
//        }
//        if indent {
//            result += (0..<nestLevel).map { _ in "    " }.joined()
//        }
//        result += line
//        if newLine == .after {
//            result += "\n"
//        }
//    }
//
//    private func l(_ line: String = "", newLine: NewLinePosition = .after, _ f: () -> Void) {
//        if newLine == .before {
//            result += "\n"
//        }
//        result += (0..<nestLevel).map { _ in "    " }.joined() + line
//        if newLine == .after {
//            result += "\n"
//        }
//
//        nestLevel += 1
//        f()
//        nestLevel -= 1
//    }
//}

