//
//  ComponentDefinition+Serialization.swift
//  Hyperdrive-ui
//
//  Created by Matouš Hýbl on 23/03/2018.
//

import Foundation

extension ComponentDefinition: XMLElementSerializable {
    public func serialize(context: DataContext) -> XMLSerializableElement {
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
        // FIXME We should create an intermediate context
        let stylesElement: [XMLSerializableElement]
        if styles.isEmpty {
            stylesElement = []
        } else {
            let styleChildren = styles.map { $0.serialize(context: context) }
            stylesElement = [XMLSerializableElement(name: "styles", attributes: styleNameAttribute, children: styleChildren)]
        }

        // FIXME We should create an intermediate context
        let childElements = children.map { $0.serialize(context: context) }

        #if SanAndreas
        properties
            .map {
                $0.dematerialize(context: PropertyContext(parentContext: context, property: $0))
            }
            .forEach {
                builder.add(attribute: $0)
            }
        toolingProperties.values
            .map {
                $0.dematerialize(context: PropertyContext(parentContext: context, property: $0))
            }
            .forEach {
                builder.add(attribute: $0)
            }
        #endif

        var viewElement = XMLSerializableElement(name: "Component", attributes: builder.attributes, children: stylesElement + childElements)
        viewElement.attributes.insert(XMLSerializableAttribute(name: "type", value: type), at: 0)

        return viewElement
    }
}
