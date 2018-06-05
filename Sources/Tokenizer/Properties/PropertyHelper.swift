//
//  StylingHelper.swift
//  Differentiator-iOS
//
//  Created by Matouš Hýbl on 05/03/2018.
//

import Foundation

public struct PropertyHelper {
    
    public static func deserializeSupportedProperties(properties: [PropertyDescription], in element: SWXMLHash.XMLElement) throws -> [Property] {

        let attributeProperties = properties.compactMap { $0 as? AttributePropertyDescription }
        let elementProperties = properties.compactMap { $0 as? ElementPropertyDescription }
        let multipleAttributeProperties = properties.compactMap { $0 as? MultipleAttributePropertyDescription }

        var result = try PropertyHelper.deserializeSupportedProperties(properties: attributeProperties, from: element.allAttributes.mapValues { $0.text })

        for propertyDescription in multipleAttributeProperties {
            var matchedAttributes = [:] as [String: String]
            for (attributeName, attribute) in element.allAttributes where propertyDescription.matches(attributeName: attributeName) {
                matchedAttributes[attributeName] = attribute.text
            }
            guard !matchedAttributes.isEmpty else { continue }

            let property = try propertyDescription.materialize(attributes: matchedAttributes)
            result.append(property)
        }

        for child in element.xmlChildren {
            guard let propertyDescription = elementProperties.first(where: { $0.matches(element: child) }) else {
                continue
            }

            let property = try propertyDescription.materialize(element: child)

            result.append(property)
        }

        return result
    }

    public static func deserializeSupportedProperties(properties: [AttributePropertyDescription], from dictionary: [String: String]) throws -> [Property] {
        return try dictionary.compactMap { attributeName, attribute in
            guard let propertyDescription = properties.first(where: { $0.matches(attributeName: attributeName) }) else {
                return nil
            }
            return try propertyDescription.materialize(attributeName: attributeName, value: attribute)
        }
    }

    public static func deserializeToolingProperties(properties: [PropertyDescription], in element: SWXMLHash.XMLElement) throws -> [String: Property] {

        let attributeProperties = properties.compactMap { $0 as? AttributePropertyDescription }

        var result = [:] as [String: Property]
        for (attributeName, attribute) in (element.allAttributes.filter { name, _ in name.hasPrefix("tools") }) {
            guard let propertyDescription = attributeProperties.first(where: { $0.matches(attributeName: attributeName) }) else {
                continue
            }
            let property = try propertyDescription.materialize(attributeName: attributeName, value: attribute.text)
            result[attributeName] = property
        }
        return result
    }

}
