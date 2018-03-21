//
//  XSDResolver.swift
//  reactant-ui
//
//  Created by Matouš Hýbl on 21/03/2018.
//

import Foundation
import Tokenizer

class XSDResolver {
    var file = XSDFile()

    func resolve() -> XSDFile {
        var viewGroup = XSDGroup(name: "viewGroup", elements: [])

        for (name, element) in Element.elementMapping {
            viewGroup.elements.insert(resolve(element: element, named: name))
        }

        file.groups.insert(viewGroup)

        let rectEdge = XSDSimpleType(name: "rectEdge", type: .enumeration(EnumerationXSDType(name: "rectEdge",
                                                                                             base: .string,
                                                                                             values: Set(arrayLiteral: "all", "top", "bottom"))))

        file.simpleTypes.insert(rectEdge)

        return file
    }

    func resolve(element: View.Type, named name: String) -> XSDElement {
        var xsdElement = XSDElement(name: name, isContainer: element is Container.Type, attributeGroups: [])
        var attributes = XSDAttributeGroup(name: name + "Attributes", attributes: [])
        xsdElement.attributeGroups.insert(name + "Attributes")

        for property in element.availableProperties {
            switch property.type.xsdType {
            case .builtin(let builtin):

                attributes.attributes.insert(XSDAttribute(name: property.namespace.resolvedAttributeName(name: property.name), typeName: builtin.xsdName))
                break
            case .enumeration(let enumeration):
                let typeName = enumeration.name
                let type = XSDSimpleType(name: typeName, type: property.type.xsdType)

                file.simpleTypes.insert(type)

                attributes.attributes.insert(XSDAttribute(name: property.namespace.resolvedAttributeName(name: property.name), typeName: typeName))
            case .pattern(let pattern):
                let typeName = pattern.name
                let type = XSDSimpleType(name: typeName, type: property.type.xsdType)

                file.simpleTypes.insert(type)

                attributes.attributes.insert(XSDAttribute(name: property.namespace.resolvedAttributeName(name: property.name), typeName: typeName))
            case .union(let union):
                let typeName = union.name
                let type = XSDSimpleType(name: typeName, type: property.type.xsdType)

                for type in union.memberTypes {
                    let typeName = type.name
                    let type = XSDSimpleType(name: typeName, type: type)
                    file.simpleTypes.insert(type)
                }

                file.simpleTypes.insert(type)

                attributes.attributes.insert(XSDAttribute(name: property.namespace.resolvedAttributeName(name: property.name), typeName: typeName))
            }
        }

        xsdElement.attributeGroups.insert("layout:layoutAttributes")

        attributes.attributes.insert(XSDAttribute(name: "field", typeName: BuiltinXSDType.string.xsdName))
        attributes.attributes.insert(XSDAttribute(name: "style", typeName: BuiltinXSDType.string.xsdName))

        file.attributeGroups.insert(attributes)

        return xsdElement
    }
}
