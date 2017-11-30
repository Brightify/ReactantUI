//
//  ComponentReference.swift
//  ReactantUI
//
//  Created by Matous Hybl.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

#if ReactantRuntime
import UIKit
#endif

public class ComponentReference: View, ComponentDefinitionContainer {
    public var type: String
    public var definition: ComponentDefinition?

    public var isAnonymous: Bool {
        return definition?.isAnonymous ?? false
    }

    public var componentTypes: [String] {
        return definition?.componentTypes ?? [type]
    }

    public var componentDefinitions: [ComponentDefinition] {
        return definition?.componentDefinitions ?? []
    }

    public class override var runtimeType: String {
        return "UIView"
    }

    public override var initialization: String {
        return "\(type)()"
    }

    public required init(node: SWXMLHash.XMLElement) throws {
        type = try node.value(ofAttribute: "type")
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

    #if ReactantRuntime
    public override func initialize() throws -> UIView {
        return try ReactantLiveUIManager.shared.componentInstantiation(named: type)()
    }
    #endif
    
    public override func serialize() -> MagicElement {
        var serialized = super.serialize()
        serialized.attributes.insert(MagicAttribute(name: "type", value: type), at: 0)
        return serialized
    }
}
