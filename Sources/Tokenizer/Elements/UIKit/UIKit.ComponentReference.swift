//
//  ComponentReference.swift
//  ReactantUI
//
//  Created by Matous Hybl.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation
#if canImport(SwiftCodeGen)
import SwiftCodeGen
#endif

#if canImport(UIKit)
import UIKit
#endif

public class ComponentReference: View, ComponentDefinitionContainer {
    public var module: String?
    public var type: String
    public var definition: ComponentDefinition?
    public var passthroughActions: String?
    public var possibleStateProperties: [String: String]

    public var isAnonymous: Bool {
        return definition?.isAnonymous ?? false
    }

    public var componentTypes: [String] {
        return definition?.componentTypes ?? [type]
    }

    public var componentDefinitions: [ComponentDefinition] {
        return definition?.componentDefinitions ?? []
    }

    public class override func runtimeType() throws -> String {
        return "UIView"
    }
    
    public override func runtimeType(for platform: RuntimePlatform) throws -> RuntimeType {
        return RuntimeType(name: type, modules: module.map { [$0] } ?? [])
    }

    #if canImport(SwiftCodeGen)
    public override func initialization(for platform: RuntimePlatform) throws -> Expression {
//        let handledActionCases = handledActions.flatMap { action -> [String] in
////            let parameters = action.parameters.map { parameter in
////                switch
////            }
//            return [
//                "case ." + action.eventName + ":",
//                "    return .\(action.name)"
//            ]
//        }

//        let pipe = DescriptionPipe()
//        pipe.block(line: "\(type)(initialState: \(type).State(), actionPublisher: actionPublisher.map", encapsulateIn: .custom(open: "{", close: "})"), header: "action") {
//            pipe.block(line: "switch action") {
//                for action in handledActions {
//                    pipe.line("case .\(action.eventName):")
//                    pipe.line("    return .\(action.name)")
//                }
//                pipe.line("default:")
//                pipe.line("    return nil")
//            }
//        }
//        return pipe.result as [Describable]

        let actionMappingBlock = [.switch(
            expression: .constant("action"),
            cases: handledActions.map {
                (Expression.constant(".\($0.eventName)"), [.return(expression: .constant(".\($0.name)"))] as Block)
            },
            default: [.return(expression: .constant("nil"))])] as Block

        return .invoke(target: .constant(type), arguments: [
            MethodArgument(name: "initialState", value: .constant("\(type).State()")),
            MethodArgument(name: "actionPublisher", value: .invoke(target: .constant("actionPublisher.map"), arguments: [
                MethodArgument(value: .closure(Closure(parameters: [(name: "action", type: nil)], block: actionMappingBlock))),
            ]))
        ])

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
    #endif

    public required init(context: UIElementDeserializationContext) throws {
        let node = context.element
        type = try node.value(ofAttribute: "type", defaultValue: node.name)
        guard type != "Component" else { throw TokenizationError(message: "Name `Component` is not allowed for component reference!") }
        
        if !node.xmlChildren.isEmpty {
            definition = try context.deserialize(element: node, type: type)
        } else {
            definition = nil
        }

        passthroughActions = node.attribute(by: "action")?.text
        let viewProperties = Set(ComponentReference.availableProperties.map { $0.name })
        possibleStateProperties = node.allAttributes.filter { name, attribute in
            !viewProperties.contains(name)
        }.mapValues { $0.text }
        
        try super.init(context: context)
    }
    
    public init(type: String, definition: ComponentDefinition?) {
        self.type = type
        self.definition = definition
        self.possibleStateProperties = [:]

        super.init()
    }

    #if canImport(UIKit)
    public override func initialize(context: ReactantLiveUIWorker.Context) throws -> UIView {
        return try context.componentInstantiation(named: type)()
    }
    #endif
    
    public override func serialize(context: DataContext) -> XMLSerializableElement {
        var serialized = super.serialize(context: context)
        #warning("TODO: Fix element serialization")
//        if let type = type {
            serialized.attributes.insert(XMLSerializableAttribute(name: "type", value: type), at: 0)
//        }
        return serialized
    }
}
