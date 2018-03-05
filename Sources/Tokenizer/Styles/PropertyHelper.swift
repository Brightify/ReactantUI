//
//  StylingHelper.swift
//  Differentiator-iOS
//
//  Created by Matouš Hýbl on 05/03/2018.
//

import Foundation

public struct PropertyHelper {
    
    public static func deserializeSupportedProperties(properties: [PropertyDescription], in element: SWXMLHash.XMLElement) throws -> [Property] {
        var result = [] as [Property]
        for (attributeName, attribute) in element.allAttributes {
            guard let propertyDescription = properties.first(where: { $0.matches(attributeName: attributeName) }) else {
                continue
            }
            //            guard
            let property = try propertyDescription.materialize(attributeName: attributeName, value: attribute.text)
            //            else {
            //                #if ReactantRuntime
            //                throw LiveUIError(message: "// Could not materialize property `\(propertyDescription)` from `\(attribute)`")
            //                #else
            //                throw TokenizationError(message: "// Could not materialize property `\(propertyDescription)` from `\(attribute)`")
            //                #endif
            //            }
            result.append(property)
        }
        return result
    }

    public static func deserializeToolingProperties(properties: [PropertyDescription], in element: SWXMLHash.XMLElement) throws -> [String: Property] {
        var result = [:] as [String: Property]
        for (attributeName, attribute) in (element.allAttributes.filter { name, _ in name.hasPrefix("tools") }) {
            guard let propertyDescription = properties.first(where: { $0.matches(attributeName: attributeName) }) else {
                continue
            }
            let property = try propertyDescription.materialize(attributeName: attributeName, value: attribute.text)
            result[attributeName] = property
        }
        return result
    }

}
