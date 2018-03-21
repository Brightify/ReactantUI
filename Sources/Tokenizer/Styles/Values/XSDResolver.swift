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
            let propertyName = property.namespace.resolvedAttributeName(name: property.name)
            let typeName: String
            switch property.type.xsdType {
            case .builtin(let builtin):
                typeName = builtin.xsdName
            case .enumeration(let enumeration):
                typeName = enumeration.name
                let type = XSDSimpleType(name: typeName, type: property.type.xsdType)

                file.simpleTypes.insert(type)
            case .pattern(let pattern):
                typeName = pattern.name
                let type = XSDSimpleType(name: typeName, type: property.type.xsdType)

                file.simpleTypes.insert(type)
            case .union(let union):
                typeName = union.name
                let type = XSDSimpleType(name: typeName, type: property.type.xsdType)

                for type in union.memberTypes {
                    let typeName = type.name
                    let type = XSDSimpleType(name: typeName, type: type)
                    file.simpleTypes.insert(type)
                }

                file.simpleTypes.insert(type)
            }

            if property is ControlStatePropertyDescriptionMarker {
                var variations: Set<Set<ControlState>> = []
                for variationClass in 1..<ControlState.allValues.count {
                    variations.formUnion(ControlState.allValues.variations(class: variationClass).map(Set.init))
                }

                for variation in variations {
                    attributes.attributes.insert(XSDAttribute(name: "\(propertyName).\(variation.name)", typeName: typeName))
                }
            }

            attributes.attributes.insert(XSDAttribute(name: propertyName, typeName: typeName))
        }

        xsdElement.attributeGroups.insert("layout:layoutAttributes")

        attributes.attributes.insert(XSDAttribute(name: "field", typeName: BuiltinXSDType.string.xsdName))
        attributes.attributes.insert(XSDAttribute(name: "style", typeName: BuiltinXSDType.string.xsdName))

        file.attributeGroups.insert(attributes)

        return xsdElement
    }

    
}

internal func strike(_ array: [Int], from: [Int]) -> [Int] {
    var result: Array<Int> = []

    for element in from {
        if array.index(of: element) == nil {
            result.append(element)
        }
    }

    return result
}

extension Array where Element: Equatable {
    func variations(class count: Int) -> [[Element]] {
        let length = ((self.count - count + 1)...self.count).reduce(1, { a, b in a * b })
        let indexes = Array<Int>(0..<self.count)
        var repeats = Array<Int>(repeating: length / self.count, count: count)
        var divisor = self.count
        for i in 1..<count {
            divisor -= 1
            repeats[i] = repeats[i - 1] / divisor
        }
        var result = Array<Array<Int>>(repeating: [], count: length)
        var k = 0
        for i in 0..<count {
            k = 0
            while k < length {
                for number in strike(result[k], from: indexes) {
                    for _ in 0..<repeats[i] {
                        result[k].append(number)
                        k += 1
                    }
                }
            }
        }

        return result.map { variation in variation.map { element in self[element] } }
    }
}
