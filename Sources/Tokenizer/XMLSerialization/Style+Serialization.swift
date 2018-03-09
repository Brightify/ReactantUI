//
//  Style+Serializable.swift
//  Tokenizer
//
//  Created by Matouš Hýbl on 09/03/2018.
//

import Foundation

extension Style: MagicElementSerializable {
    public func serialize() -> MagicElement {
        //        public let type: String
        //        // this is name with group
        //        public let name: String
        //        // this is name of the style without group name
        //        public let styleName: String
        //        public let extend: [String]
        //        public let properties: [Property]

        /*
         self.type = type
         // FIXME The name has to be done some other way
         let name = try node.value(ofAttribute: "name") as String
         self.styleName = name
         if let groupName = groupName {
         self.name = ":\(groupName):\(name)"
         } else {
         self.name = name
         }
         self.extend = (node.value(ofAttribute: "extend") as String?)?.components(separatedBy: " ") ?? []
         self.properties = properties
         */

        var builder = MagicAttributeBuilder()
        builder.attribute(name: "name", value: name)
        let extendedStyles = extend.joined(separator: " ")
        if !extendedStyles.isEmpty {
            builder.attribute(name: "extend", value: extendedStyles)
        }
        #if SanAndreas
            properties.map { $0.dematerialize() }.forEach { builder.add(attribute: $0) }
        #endif

        return MagicElement(name: "\(type)Style", attributes: builder.attributes, children: [])
    }
}
