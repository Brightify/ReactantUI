//
//  ComponentReference.swift
//  ReactantUI
//
//  Created by Matous Hybl.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

#if canImport(UIKit)
import UIKit
#endif

public class ComponentReference: View, ComponentDefinitionContainer {
    public var type: String?
    public var definition: ComponentDefinition?

    public var isAnonymous: Bool {
        return definition?.isAnonymous ?? false
    }

    public var componentTypes: [String] {
        if let type = type {
            return definition?.componentTypes ?? [type]
        } else {
            return []
        }
    }

    public var componentDefinitions: [ComponentDefinition] {
        return definition?.componentDefinitions ?? []
    }

    public class override func runtimeType() throws -> String {
        return "UIView"
    }

    public override func initialization() throws -> String {
        guard let type = type else {
            throw TokenizationError(message: "Should never initialize when type is undefined.")
        }
        return "\(type)()"
    }

    public required init(node: SWXMLHash.XMLElement) throws {
        type = node.value(ofAttribute: "type")
        
        if !node.xmlChildren.isEmpty {
            definition = try node.value() as ComponentDefinition
        } else {
            definition = nil
        }
        
        try super.init(node: node)
    }
    
    public init(type: String, definition: ComponentDefinition?) {
        self.type = type
        self.definition = definition
        
        super.init()
    }

    #if canImport(UIKit)
    public override func initialize(context: ReactantLiveUIWorker.Context) throws -> UIView {
        guard let type = type else { throw LiveUIError(message: "Should never initialize when type is undefined.") }
        return try context.componentInstantiation(named: type)()
    }
    #endif
    
    public override func serialize(context: DataContext) -> XMLSerializableElement {
        var serialized = super.serialize(context: context)
        if let type = type {
            serialized.attributes.insert(XMLSerializableAttribute(name: "type", value: type), at: 0)
        }
        return serialized
    }
}
