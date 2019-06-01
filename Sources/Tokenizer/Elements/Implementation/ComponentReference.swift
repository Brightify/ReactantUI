//
//  ComponentReference.swift
//  ReactantUI
//
//  Created by Matous Hybl.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation
import SwiftCodeGen

#if canImport(UIKit)
import UIKit
#endif

public class ComponentReference: View, ComponentDefinitionContainer {
    public var module: String?
    public var type: String?
    public var definition: ComponentDefinition?
    public var passthroughActions: String?

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
    
    public override func runtimeType(for platform: RuntimePlatform) throws -> RuntimeType {
        if let type = type {
            return RuntimeType(name: type, modules: module.map { [$0] } ?? [])
        } else {
            return RuntimeType(name: "UIView", module: "UIKit")
        }
    }

    public override func initialization(for platform: RuntimePlatform, describeInto pipe: DescriptionPipe) throws {
        guard let type = type else {
            throw TokenizationError(message: "Should never initialize when type is undefined.")
        }

//        let handledActionCases = handledActions.flatMap { action -> [String] in
////            let parameters = action.parameters.map { parameter in
////                switch
////            }
//            return [
//                "case ." + action.eventName + ":",
//                "    return .\(action.name)"
//            ]
//        }

        pipe.block(line: "\(type)(initialState: \(type).State(), actionPublisher: actionPublisher.map", header: "action") {
            pipe.block(line: "switch action") {
                for action in handledActions {
                    pipe.line("case .\(action.eventName):")
                    pipe.line("    return .\(action.name)")
                }
                pipe.line("default:")
                pipe.line("    return nil")
            }
        }.string(")")
//
//        return """
//         { action in
//            switch action {
//        \(handledActionCases.map { "    \($0)"}.joined(separator: "\n"))
//            default:
//                return nil
//            }
//        })
//        """
    }

    public required init(node: SWXMLHash.XMLElement, idProvider: ElementIdProvider) throws {
        type = try? node.value(ofAttribute: "type")
        
        if !node.xmlChildren.isEmpty {
            definition = try node.value() as ComponentDefinition
        } else {
            definition = nil
        }

        passthroughActions = node.attribute(by: "action")?.text
        
        try super.init(node: node, idProvider: idProvider)
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
