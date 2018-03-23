//
//  ComponentDefinition+Serialization.swift
//  reactant-ui
//
//  Created by Matouš Hýbl on 23/03/2018.
//

import Foundation

extension ComponentDefinition: XMLElementSerializable {

    public func serialize() -> XMLSerializableElement {
        var builder = XMLAttributeBuilder()

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

        let styleNameAttribute = stylesName == "Styles" ? [] : [XMLSerializableAttribute(name: "name", value: stylesName)]
        let stylesElement = styles.isEmpty ? [] : [XMLSerializableElement(name: "styles", attributes: styleNameAttribute, children: styles.map { $0.serialize() })]

        let childElements = children.map { $0.serialize() }

        #if SanAndreas
            properties.map { $0.dematerialize() }.forEach { builder.add(attribute: $0) }
            toolingProperties.map { _, property in property.dematerialize() }.forEach { builder.add(attribute: $0) }
        #endif

        var viewElement = XMLSerializableElement(name: "Component", attributes: builder.attributes, children: stylesElement + childElements)
        viewElement.attributes.insert(XMLSerializableAttribute(name: "type", value: type), at: 0)

        return viewElement
    }
}
