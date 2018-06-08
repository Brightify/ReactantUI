//
//  Container.swift
//  ReactantUI
//
//  Created by Matous Hybl.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

#if canImport(UIKit)
import UIKit
import Reactant
#endif

public class Container: View, UIContainer {
    public var children: [UIElement]

    public var addSubviewMethod: String {
        return "addSubview"
    }

    #if canImport(UIKit)
    public func add(subview: UIView, toInstanceOfSelf: UIView) {
        toInstanceOfSelf.addSubview(subview)
    }
    #endif

    public required init(node: SWXMLHash.XMLElement) throws {
        children = try View.deserialize(nodes: node.xmlChildren)

        try super.init(node: node)
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

    #if canImport(UIKit)
    public override func initialize() -> UIView {
        return ContainerView()
    }
    #endif
}
