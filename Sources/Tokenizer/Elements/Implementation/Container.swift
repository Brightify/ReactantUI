//
//  Container.swift
//  ReactantUI
//
//  Created by Matous Hybl.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

#if ReactantRuntime
import UIKit
import Reactant
#endif

public class Container: View, UIContainer {
    public var children: [UIElement]

    public var addSubviewMethod: String {
        return "addSubview"
    }

    #if ReactantRuntime
    public func add(subview: UIView, toInstanceOfSelf: UIView) {
        toInstanceOfSelf.addSubview(subview)
    }
    #endif

    public required init(node: SWXMLHash.XMLElement) throws {
        children = try View.deserialize(nodes: node.xmlChildren)

        try super.init(node: node)

        let stackChildren = node.elements(named: "stack")
        guard !stackChildren.isEmpty else { return }
        guard let stackElement = stackChildren.first, stackChildren.count == 1 else {
            throw TokenizationError(message: "Container can contain only one stack element.")
        }

        let stack = try ContainerStack(node: stackElement)
        // TODO: do something with the `ContainerStack`
    }
    
    public override init() {
        children = []
        super.init()
    }

    public override var requiredImports: Set<String> {
        return Set(arrayLiteral: "UIKit").union(children.flatMap { $0.requiredImports })
    }

    public class override func runtimeType() throws -> String {
        return "ContainerView"
    }

    public override func serialize() -> XMLSerializableElement {
        var viewElement = super.serialize()
        
        viewElement.children.append(contentsOf: children.map { $0.serialize() })
        
        return viewElement
    }

    #if ReactantRuntime
    public override func initialize() -> UIView {
        return ContainerView()
    }
    #endif
}

public class ContainerStack: XMLElementDeserializable {
    public class var availableProperties: [PropertyDescription] {
        return Properties.stack.allProperties
    }

    public var axis: LayoutAxis
    public var spacing: Float

    public required init(node: XMLElement) throws {
        guard let axisText = node.attribute(by: "axis")?.text else {
            throw TokenizationError(message: "Unable to parse the axis attribute of stack element.")
        }
        axis = try LayoutAxis.materialize(from: axisText)
        spacing = try node.value(ofAttribute: "spacing")
    }
}

public class StackProperties: PropertyContainer {
    public let axis: AssignablePropertyDescription<LayoutAxis>
    public let spacing: AssignablePropertyDescription<Float>

    public required init(configuration: Configuration) {
        axis = configuration.property(name: "axis")
        spacing = configuration.property(name: "spacing")

        super.init(configuration: configuration)
    }
}
