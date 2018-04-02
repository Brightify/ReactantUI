//
//  View.swift
//  ReactantUI
//
//  Created by Matous Hybl.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

#if ReactantRuntime
import UIKit
#endif

public class View: XMLElementDeserializable, UIElement {
    public class var availableProperties: [PropertyDescription] {
        return Properties.view.allProperties
    }

    public class var availableToolingProperties: [PropertyDescription] {
        return ToolingProperties.view.allProperties
    }

    // runtime type is used in generator for style parameters
    public class var runtimeType: String {
        return "UIView"
    }

    public class var parentModuleImport: String {
        return "UIKit"
    }

    public var requiredImports: Set<String> {
        return ["UIKit"]
    }

    public var field: String?
    public var styles: [String]
    public var layout: Layout
    public var properties: [Property]
    public var toolingProperties: [String: Property]

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

        properties = try PropertyHelper.deserializeSupportedProperties(properties: type(of: self).availableProperties, in: node)
        toolingProperties = try PropertyHelper.deserializeToolingProperties(properties: type(of: self).availableToolingProperties, in: node)
    }
    
    public init() {
        field = nil
        styles = []
        layout = Layout(contentCompressionPriorityHorizontal: View.defaultContentCompression.horizontal,
                             contentCompressionPriorityVertical: View.defaultContentCompression.vertical,
                             contentHuggingPriorityHorizontal: View.defaultContentHugging.horizontal,
                             contentHuggingPriorityVertical: View.defaultContentHugging.vertical)
        properties = []
        toolingProperties = [:]
    }

    public static func deserialize(_ node: XMLElement) throws -> Self {
        return try self.init(node: node)
    }

    public static func deserialize(nodes: [XMLElement]) throws -> [UIElement] {
        return try nodes.compactMap { node -> UIElement? in
            if let elementType = ElementMapping.mapping[node.name] {
                return try elementType.init(node: node)
            } else if node.name == "styles" {
                // Intentionally ignored as these are parsed directly
                return nil
            } else {
                throw TokenizationError(message: "Unknown tag `\(node.name)`")
            }
        }
    }

    public func serialize() -> XMLSerializableElement {
        var builder = XMLAttributeBuilder()
        if let field = field {
            builder.attribute(name: "field", value: field)
        }
        let styleNames = styles.joined(separator: " ")
        if !styleNames.isEmpty {
            builder.attribute(name: "style", value: styleNames)
        }
        
        #if SanAndreas
            properties.map { $0.dematerialize() }.forEach { builder.add(attribute: $0) }
            toolingProperties.map { _, property in property.dematerialize() }.forEach { builder.add(attribute: $0) }
        #endif
        
        layout.serialize().forEach { builder.add(attribute: $0) }
        
        let typeOfSelf = type(of: self)
        let name = ElementMapping.mapping.first(where: { $0.value == typeOfSelf })?.key ?? "\(typeOfSelf)"
        return XMLSerializableElement(name: name, attributes: builder.attributes, children: [])
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
    public let transform: AssignablePropertyDescription<AffineTransformation>
    
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
        
        transform = configuration.property(name: "transform")
        
        layer = configuration.namespaced(in: "layer", LayerProperties.self)
        
        super.init(configuration: configuration)
    }
}

public final class ViewToolingProperties: PropertyContainer {

    public required init(configuration: Configuration) {
        super.init(configuration: configuration)
    }
}

public enum PreferredDimension {
    case fill
    case wrap
    case numeric(Float)

    public init(_ value: String) throws {
        switch value {
        case "fill":
            self = .fill
        case "wrap":
            self = .wrap
        default:
            guard let floatValue = Float(value) else {
                throw TokenizationError(message: "Unknown preferred dimension \(value)")
            }
            self = .numeric(floatValue)
        }
    }

    var stringValue: String {
        switch self {
        case .fill:
            return "fill"
        case .numeric(let number):
            return "\(number)"
        case .wrap:
            return "wrap"
        }
    }
}

extension PreferredDimension: Equatable {
    public static func ==(lhs: PreferredDimension, rhs: PreferredDimension) -> Bool {
        switch (lhs, rhs) {
        case (.fill, .fill):
            return true
        case (.wrap, .wrap):
            return true
        case (.numeric(let lhsNumber), .numeric(let rhsNumber)):
            return lhsNumber == rhsNumber
        default:
            return false
        }
    }
}

public struct PreferredSize: SupportedPropertyType {
    public var width: PreferredDimension
    public var height: PreferredDimension

    public init(width: PreferredDimension, height: PreferredDimension) {
        self.width = width
        self.height = height
    }

    // FIXME what happens in generated code
    public var generated: String {
        return ""
    }

    #if SanAndreas
    public func dematerialize() -> String {
        if width == height {
            return "\(width.stringValue)"
        }
        return "\(width.stringValue),\(height.stringValue)"
    }
    #endif

    #if ReactantRuntime
    public var runtimeValue: Any? {
        return nil
    }
    #endif

    public static func materialize(from value: String) throws -> PreferredSize {
        if value.contains(",") == false {
            let size = try PreferredDimension(value)
            return PreferredSize(width: size, height: size)
        } else {
            let components = value.components(separatedBy: ",")
            guard components.count == 2, let width = try? PreferredDimension(components[0]), let height = try? PreferredDimension(components[1]) else {
                throw TokenizationError(message: "Failed to materialize PreferredSizeValue")
            }
            return PreferredSize(width: width, height: height)
        }
    }

    public static var xsdType: XSDType {
        return .builtin(.string)
    }
}
