import Foundation
#if ReactantRuntime
import UIKit
#endif

extension XMLElement {
    func value<T: XMLElementDeserializable>() throws -> T {
        return try T.deserialize(self)
    }

    var indexer: XMLIndexer {
        return XMLIndexer(self)
    }

    func elements(named: String) -> [XMLElement] {
        return xmlChildren.filter { $0.name == named }
    }

    func singleElement(named: String) throws -> XMLElement {
        let allNamedElements = elements(named: named)
        guard allNamedElements.count == 1 else {
            throw TokenizationError(message: "Requires element named `\(named)` to be defined!")
        }
        return allNamedElements[0]
    }

    func singleOrNoElement(named: String) throws -> XMLElement? {
        let allNamedElements = elements(named: named)
        guard allNamedElements.count <= 1 else {
            throw TokenizationError(message: "Maximum number of elements named `\(named)` is 1!")
        }
        return allNamedElements.first
    }
}

public class View: XMLElementDeserializable, UIElement {
    static let backgroundColor = assignable(name: "backgroundColor", type: UIColorPropertyType.self)

    class var availableProperties: [PropertyDescription] {
        return [
            backgroundColor,
            assignable(name: "clipsToBounds", type: Bool.self),
            assignable(name: "isUserInteractionEnabled", key: "userInteractionEnabled", type: Bool.self),
            assignable(name: "tintColor", type: UIColorPropertyType.self),
            assignable(name: "isHidden", type: Bool.self),
            assignable(name: "alpha", type: Float.self),
            assignable(name: "isOpaque", type: Bool.self),
            assignable(name: "isMultipleTouchEnabled", key: "multipleTouchEnabled", type: Bool.self),
            assignable(name: "isExclusiveTouch", key: "exclusiveTouch", type: Bool.self),
            assignable(name: "autoresizesSubviews", type: Bool.self),
            assignable(name: "contentMode", type: ContentMode.self),
            assignable(name: "translatesAutoresizingMaskIntoConstraints", type: Bool.self),
            assignable(name: "preservesSuperviewLayoutMargins", type: Bool.self),
            assignable(name: "tag", type: Int.self),
            assignable(name: "canBecomeFocused", type: Bool.self),
            assignable(name: "visibility", type: ViewVisibility.self),
            assignable(name: "frame", type: Rect.self),
            assignable(name: "bounds", type: Rect.self),
            assignable(name: "layoutMargins", type: EdgeInsets.self)
            ] + nested(field: "layer", namespace: "layer", properties: View.layerAvailableProperties)
    }

    static let layerAvailableProperties: [PropertyDescription] = [
        assignable(name: "cornerRadius", type: Float.self),
        assignable(name: "borderWidth", type: Float.self),
        assignable(name: "borderColor", type: CGColorPropertyType.self),
        assignable(name: "opacity", type: Float.self),
        assignable(name: "isHidden", type: Bool.self),
        assignable(name: "masksToBounds", type: Bool.self),
        assignable(name: "isDoubleSided", key: "doubleSided", type: Bool.self),
        assignable(name: "backgroundColor", type: CGColorPropertyType.self),
        assignable(name: "shadowOpacity", type: Float.self),
        assignable(name: "shadowRadius", type: Float.self),
        assignable(name: "shadowColor", type: CGColorPropertyType.self),
        assignable(name: "allowsEdgeAntialiasing", type: Bool.self),
        assignable(name: "allowsGroupOpacity", type: Bool.self),
        assignable(name: "isOpaque", key: "opaque", type: Bool.self),
        assignable(name: "isGeometryFlipped", key: "geometryFlipped", type: Bool.self),
        assignable(name: "shouldRasterize", type: Bool.self),
        assignable(name: "rasterizationScale", type: Float.self),
        assignable(name: "contentsFormat", type: TransformedText.self),
        assignable(name: "contentsScale", type: Float.self),
        assignable(name: "zPosition", type: Float.self),
        assignable(name: "name", type: TransformedText.self),
        assignable(name: "contentsRect", type: Rect.self),
        assignable(name: "contentsCenter", type: Rect.self),
        assignable(name: "shadowOffset", type: Size.self),
        assignable(name: "frame", type: Rect.self),
        assignable(name: "bounds", type: Rect.self),
        assignable(name: "position", type: Point.self),
        assignable(name: "anchorPoint", type: Point.self),
    ]

    public class var runtimeType: String {
        return "UIView"
    }

    public var requiredImports: Set<String> {
        return ["UIKit"]
    }

    public var field: String?
    public var styles: [String]
    public var layout: Layout
    public var properties: [Property]

    public var initialization: String {
        return "\(type(of: self).runtimeType)()"
    }

    #if ReactantRuntime
    public func initialize() throws -> UIView {
        return UIView()
    }
    #endif

    public required init(node: XMLElement) throws {
        field = node.value(ofAttribute: "field")
        layout = try node.value()
        styles = (node.value(ofAttribute: "style") as String?)?
            .components(separatedBy: CharacterSet.whitespacesAndNewlines) ?? []

        if node.name == "View" && node.count != 0 {
            throw TokenizationError(message: "View must not have any children, use Container instead.")
        }

        properties = try View.deserializeSupportedProperties(properties: type(of: self).availableProperties, in: node)
    }

    public static func deserialize(_ node: XMLElement) throws -> Self {
        return try self.init(node: node)
    }

    public static func deserialize(nodes: [XMLElement]) throws -> [UIElement] {
        return try nodes.flatMap { node -> UIElement? in
            if let elementType = Element.elementMapping[node.name] {
                return try elementType.init(node: node)
            } else if node.name == "styles" {
                // Intentionally ignored as these are parsed directly
                return nil
            } else {
                throw TokenizationError(message: "Unknown tag `\(node.name)`")
            }
        }
    }

    static func deserializeSupportedProperties(properties: [PropertyDescription], in element: SWXMLHash.XMLElement) throws -> [Property] {
        var result = [] as [Property]
        for (attributeName, attribute) in element.allAttributes {
            guard let propertyDescription = properties.first(where: { $0.matches(attributeName: attributeName) }) else {
                continue
            }
//            guard
            let property = try propertyDescription.materialize(attributeName: attributeName, value: attribute.text)
//            else {
//                #if ReactantRuntime
//                throw LiveUIError(message: "// Could not materialize property `\(propertyDescription)` from `\(attribute)`")
//                #else
//                throw TokenizationError(message: "// Could not materialize property `\(propertyDescription)` from `\(attribute)`")
//                #endif
//            }
            result.append(property)
        }
        return result
    }
}
