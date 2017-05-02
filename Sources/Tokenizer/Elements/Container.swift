import Foundation

#if ReactantRuntime
import UIKit
import Reactant
#endif

public class Container: View, UIContainer {
    public let children: [UIElement]

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
    }

    public override var requiredImports: Set<String> {
        return Set(arrayLiteral: "UIKit").union(children.flatMap { $0.requiredImports })
    }

    public class override var runtimeType: String {
        return "ContainerView"
    }

    #if ReactantRuntime
    public override func initialize() -> UIView {
        return ContainerView()
    }
    #endif
}
