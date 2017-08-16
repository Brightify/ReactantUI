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
    public static let backgroundColor = assignable(name: "backgroundColor", type: UIColorPropertyType.self)
    public static let clipsToBounds = assignable(name: "clipsToBounds", type: Bool.self)
    public static let isUserInteractionEnabled = assignable(name: "isUserInteractionEnabled", key: "userInteractionEnabled", type: Bool.self)
    public static let tintColor = assignable(name: "tintColor", type: UIColorPropertyType.self)
    public static let isHidden = assignable(name: "isHidden", type: Bool.self)
    public static let alpha = assignable(name: "alpha", type: Float.self)
    public static let isOpaque = assignable(name: "isOpaque", type: Bool.self)
    public static let isMultipleTouchEnabled = assignable(name: "isMultipleTouchEnabled", key: "multipleTouchEnabled", type: Bool.self)
    public static let isExclusiveTouch = assignable(name: "isExclusiveTouch", key: "exclusiveTouch", type: Bool.self)
    public static let autoresizesSubviews = assignable(name: "autoresizesSubviews", type: Bool.self)
    public static let contentMode = assignable(name: "contentMode", type: ContentMode.self)
    public static let translatesAutoresizingMaskIntoConstraints = assignable(name: "translatesAutoresizingMaskIntoConstraints", type: Bool.self)
    public static let preservesSuperviewLayoutMargins = assignable(name: "preservesSuperviewLayoutMargins", type: Bool.self)
    public static let tag = assignable(name: "tag", type: Int.self)
    public static let canBecomeFocused = assignable(name: "canBecomeFocused", type: Bool.self)
    public static let visibility = assignable(name: "visibility", type: ViewVisibility.self)
    public static let frame = assignable(name: "frame", type: Rect.self)
    public static let bounds = assignable(name: "bounds", type: Rect.self)
    public static let layoutMargins = assignable(name: "layoutMargins", type: EdgeInsets.self)

    class var availableProperties: [PropertyDescription] {
        return [
            backgroundColor,
            clipsToBounds,
            isUserInteractionEnabled,
            tintColor,
            isHidden,
            alpha,
            isOpaque,
            isMultipleTouchEnabled,
            isExclusiveTouch,
            autoresizesSubviews,
            contentMode,
            translatesAutoresizingMaskIntoConstraints,
            preservesSuperviewLayoutMargins,
            tag,
            canBecomeFocused,
            visibility,
            frame,
            bounds,
            layoutMargins,
            ] + nested(field: "layer", namespace: "layer", properties: View.layerAvailableProperties)
    }
    
    public struct Layer {
        public static let cornerRadius = assignable(name: "cornerRadius", type: Float.self)
        public static let borderWidth = assignable(name: "borderWidth", type: Float.self)
        public static let borderColor = assignable(name: "borderColor", type: CGColorPropertyType.self)
        public static let opacity = assignable(name: "opacity", type: Float.self)
        public static let isHidden = assignable(name: "isHidden", type: Bool.self)
        public static let masksToBounds = assignable(name: "masksToBounds", type: Bool.self)
        public static let isDoubleSided = assignable(name: "isDoubleSided", key: "doubleSided", type: Bool.self)
        public static let backgroundColor = assignable(name: "backgroundColor", type: CGColorPropertyType.self)
        public static let shadowOpacity = assignable(name: "shadowOpacity", type: Float.self)
        public static let shadowRadius = assignable(name: "shadowRadius", type: Float.self)
        public static let shadowColor = assignable(name: "shadowColor", type: CGColorPropertyType.self)
        public static let allowsEdgeAntialiasing = assignable(name: "allowsEdgeAntialiasing", type: Bool.self)
        public static let allowsGroupOpacity = assignable(name: "allowsGroupOpacity", type: Bool.self)
        public static let isOpaque = assignable(name: "isOpaque", key: "opaque", type: Bool.self)
        public static let isGeometryFlipped = assignable(name: "isGeometryFlipped", key: "geometryFlipped", type: Bool.self)
        public static let shouldRasterize = assignable(name: "shouldRasterize", type: Bool.self)
        public static let rasterizationScale = assignable(name: "rasterizationScale", type: Float.self)
        public static let contentsFormat = assignable(name: "contentsFormat", type: TransformedText.self)
        public static let contentsScale = assignable(name: "contentsScale", type: Float.self)
        public static let zPosition = assignable(name: "zPosition", type: Float.self)
        public static let name = assignable(name: "name", type: TransformedText.self)
        public static let contentsRect = assignable(name: "contentsRect", type: Rect.self)
        public static let contentsCenter = assignable(name: "contentsCenter", type: Rect.self)
        public static let shadowOffset = assignable(name: "shadowOffset", type: Size.self)
        public static let frame = assignable(name: "frame", type: Rect.self)
        public static let bounds = assignable(name: "bounds", type: Rect.self)
        public static let position = assignable(name: "position", type: Point.self)
        public static let anchorPoint = assignable(name: "anchorPoint", type: Point.self)
    }

    static let layerAvailableProperties: [PropertyDescription] = [
        Layer.cornerRadius,
        Layer.borderWidth,
        Layer.borderColor,
        Layer.opacity,
        Layer.isHidden,
        Layer.masksToBounds,
        Layer.isDoubleSided,
        Layer.backgroundColor,
        Layer.shadowOpacity,
        Layer.shadowRadius,
        Layer.shadowColor,
        Layer.allowsEdgeAntialiasing,
        Layer.allowsGroupOpacity,
        Layer.isOpaque,
        Layer.isGeometryFlipped,
        Layer.shouldRasterize,
        Layer.rasterizationScale,
        Layer.contentsFormat,
        Layer.contentsScale,
        Layer.zPosition,
        Layer.name,
        Layer.contentsRect,
        Layer.contentsCenter,
        Layer.shadowOffset,
        Layer.frame,
        Layer.bounds,
        Layer.position,
        Layer.anchorPoint,
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
    
    public func serialize() -> MagicElement {
        var builder = MagicAttributeBuilder()
        if let field = field {
            builder.attribute(name: "field", value: field)
        }
        let styleNames = styles.joined(separator: " ")
        if !styleNames.isEmpty {
            builder.attribute(name: "style", value: styleNames)
        }
        
        #if SanAndreas
            properties.map { $0.dematerialize() }.forEach { builder.add(attribute: $0) }
        #endif
        
        layout.serialize().forEach { builder.add(attribute: $0) }
        
        let typeOfSelf = type(of: self)
        let name = Element.elementMapping.first(where: { $0.value == typeOfSelf })?.key ?? "\(typeOfSelf)"
        return MagicElement(name: name, attributes: builder.attributes, children: [])
    }
}
