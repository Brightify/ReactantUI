import Foundation
#if ReactantRuntime
import UIKit
#endif

public class View: XMLElementDeserializable, UIElement {
    
    class var availableProperties: [PropertyDescription] {
        return Properties.view.allProperties
    }

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

public class ViewProperties: PropertyContainer {
    public let backgroundColor: AssignablePropertyDescription<UIColorPropertyType>
    public let clipsToBounds: AssignablePropertyDescription<Bool>
    public let isUserInteractionEnabled: AssignablePropertyDescription<Bool>
    public let tintColor: AssignablePropertyDescription<UIColorPropertyType>
    public let isHidden: AssignablePropertyDescription<Bool>
    public let alpha: AssignablePropertyDescription<Float>
    public let isOpaque: AssignablePropertyDescription<Bool>
    public let isMultipleTouchEnabled: AssignablePropertyDescription<Bool>
    public let isExclusiveTouch: AssignablePropertyDescription<Bool>
    public let autoresizesSubviews: AssignablePropertyDescription<Bool>
    public let contentMode: AssignablePropertyDescription<ContentMode>
    public let translatesAutoresizingMaskIntoConstraints: AssignablePropertyDescription<Bool>
    public let preservesSuperviewLayoutMargins: AssignablePropertyDescription<Bool>
    public let tag: AssignablePropertyDescription<Int>
    public let canBecomeFocused: AssignablePropertyDescription<Bool>
    public let visibility: AssignablePropertyDescription<ViewVisibility>
    public let frame: AssignablePropertyDescription<Rect>
    public let bounds: AssignablePropertyDescription<Rect>
    public let layoutMargins: AssignablePropertyDescription<EdgeInsets>
    
    public let layer: LayerProperties
    
    public required init(configuration: PropertyContainer.Configuration) {
        backgroundColor = configuration.property(name: "backgroundColor")
        clipsToBounds = configuration.property(name: "clipsToBounds")
        isUserInteractionEnabled = configuration.property(name: "isUserInteractionEnabled", key: "userInteractionEnabled")
        tintColor = configuration.property(name: "tintColor")
        isHidden = configuration.property(name: "isHidden", key: "hidden")
        alpha = configuration.property(name: "alpha")
        isOpaque = configuration.property(name: "isOpaque", key: "opaque")
        isMultipleTouchEnabled = configuration.property(name: "isMultipleTouchEnabled", key: "multipleTouchEnabled")
        isExclusiveTouch = configuration.property(name: "isExclusiveTouch", key: "exclusiveTouch")
        autoresizesSubviews = configuration.property(name: "autoresizesSubviews")
        contentMode = configuration.property(name: "contentMode")
        translatesAutoresizingMaskIntoConstraints = configuration.property(name: "translatesAutoresizingMaskIntoConstraints")
        preservesSuperviewLayoutMargins = configuration.property(name: "preservesSuperviewLayoutMargins")
        tag = configuration.property(name: "tag")
        canBecomeFocused = configuration.property(name: "canBecomeFocused")
        visibility = configuration.property(name: "visibility")
        frame = configuration.property(name: "frame")
        bounds = configuration.property(name: "bounds")
        layoutMargins = configuration.property(name: "layoutMargins")
        
        layer = configuration.namespaced(in: "layer", LayerProperties.self)
        
        super.init(configuration: configuration)
    }
}
