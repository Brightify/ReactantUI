//
//  View.swift
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

public class ElementIdProvider {
    private let prefix: String

    private var counter: Int = 1
    private var children: [Int: ElementIdProvider] = [:]

    init(prefix: String) {
        self.prefix = prefix
    }

    func next(for type: String) -> UIElementID {
        defer { counter += 1 }
        return .generated("\(prefix)_\(counter)_\(type)")
    }

    func child() -> ElementIdProvider {
        if let child = children[counter] {
            return child
        } else {
            let newChild = ElementIdProvider(prefix: "\(prefix)_\(counter)")
            children[counter] = newChild
            return newChild
        }


    }
}

#if canImport(SwiftCodeGen) && canImport(UIKit)
public protocol SwiftExtensionWorkaround: ProvidesCodeInitialization, CanInitializeUIKitView { }
#elseif canImport(SwiftCodeGen)
public protocol SwiftExtensionWorkaround: ProvidesCodeInitialization { }
#elseif canImport(UIKit)
public protocol SwiftExtensionWorkaround: CanInitializeUIKitView { }
#else
public protocol SwiftExtensionWorkaround { }
#endif

public class View: UIElement, SwiftExtensionWorkaround {
    public class var availableProperties: [PropertyDescription] {
        return Properties.view.allProperties
    }

    public class var availableToolingProperties: [PropertyDescription] {
        return ToolingProperties.view.allProperties
    }

    // runtime type is used in generator for style parameters
    public class func runtimeType() throws -> String {
        return "UI\(self)"
    }
    
    public func runtimeType(for platform: RuntimePlatform) throws -> RuntimeType {
        switch platform {
        case .iOS, .tvOS:
            return RuntimeType(name: "UI\(type(of: self))", module: "UIKit")
//        case .macOS:
//            return RuntimeType(name: "NS\(type(of: self))", module: "AppKit")
        }
    }

    public class var parentModuleImport: String {
        return "UIKit"
    }

    public var requiredImports: Set<String> {
        return ["UIKit"]
    }

    public var id: UIElementID
    public var isExported: Bool
    public var styles: [StyleName]
    public var layout: Layout
    public var properties: [Property]
    public var toolingProperties: [String: Property]
    public var handledActions: [HyperViewAction]

    public func supportedActions(context: DataContext) throws -> [UIElementAction] {
        return [
            ViewTapAction()
        ]
    }

    #if canImport(UIKit)
    public func initialize(context: ReactantLiveUIWorker.Context) throws -> UIView {
        return UIView()
    }
    #endif

    #if canImport(SwiftCodeGen)
    public func initialization(for platform: RuntimePlatform) throws -> Expression {
        return .constant("\(try runtimeType(for: platform).name)()")
    }
    #endif

    public required init(context: UIElementDeserializationContext) throws {
        let node = context.element
        id = try node.value(ofAttribute: "id", defaultValue: context.elementIdProvider.next(for: node.name))
        isExported = try node.value(ofAttribute: "export", defaultValue: false)
        layout = try node.value()
        styles = try node.value(ofAttribute: "style", defaultValue: []) as [StyleName]

        if node.name == "View" && node.count != 0 {
            throw TokenizationError(message: "View must not have any children, use Container instead.")
        }

        properties = try PropertyHelper.deserializeSupportedProperties(properties: type(of: self).availableProperties, in: node)
        toolingProperties = try PropertyHelper.deserializeToolingProperties(properties: type(of: self).availableToolingProperties, in: node)

        handledActions = try node.allAttributes.compactMap { _, value in
            try HyperViewAction(attribute: value)
        }
    }
    
    public init() {
        preconditionFailure("Not implemented!")
//        id = nil
        isExported = false
        styles = []
        layout = Layout(contentCompressionPriorityHorizontal: View.defaultContentCompression.horizontal,
                             contentCompressionPriorityVertical: View.defaultContentCompression.vertical,
                             contentHuggingPriorityHorizontal: View.defaultContentHugging.horizontal,
                             contentHuggingPriorityVertical: View.defaultContentHugging.vertical)
        properties = []
        toolingProperties = [:]
        handledActions = []
    }

    public func serialize(context: DataContext) -> XMLSerializableElement {
        var builder = XMLAttributeBuilder()
        if case .provided(let id) = id {
            builder.attribute(name: "id", value: id)
        }
        if isExported {
            builder.attribute(name: "export", value: "true")
        }
        let styleNames = styles.map { $0.serialize() }.joined(separator: " ")
        if !styleNames.isEmpty {
            builder.attribute(name: "style", value: styleNames)
        }
        
        #if SanAndreas
        (properties + toolingProperties.values)
            .map {
                $0.dematerialize(context: PropertyContext(parentContext: context, property: $0))
            }
            .forEach {
                builder.add(attribute: $0)
            }
        #endif
        
        layout.serialize().forEach { builder.add(attribute: $0) }
        
        let typeOfSelf = type(of: self)
        #warning("TODO Implement")
        fatalError("Not implemented")
        let name = "" // ElementMapping.mapping.first(where: { $0.value == typeOfSelf })?.key ?? "\(typeOfSelf)"
        return XMLSerializableElement(name: name, attributes: builder.attributes, children: [])
    }
}

public class ViewProperties: PropertyContainer {
    public let backgroundColor: AssignablePropertyDescription<UIColorPropertyType?>
    public let clipsToBounds: AssignablePropertyDescription<Bool>
    public let isUserInteractionEnabled: AssignablePropertyDescription<Bool>
    public let tintColor: AssignablePropertyDescription<UIColorPropertyType?>
    public let isHidden: AssignablePropertyDescription<Bool>
    public let alpha: AssignablePropertyDescription<Double>
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
    public let collapseAxis: AssignablePropertyDescription<ViewCollapseAxis>
    public let frame: AssignablePropertyDescription<Rect>
    public let bounds: AssignablePropertyDescription<Rect>
    public let layoutMargins: AssignablePropertyDescription<EdgeInsets>
    public let transform: AssignablePropertyDescription<AffineTransformation>
    
    public let layer: LayerProperties
    
    public required init(configuration: PropertyContainer.Configuration) {
        backgroundColor = configuration.property(name: "backgroundColor")
        clipsToBounds = configuration.property(name: "clipsToBounds")
        isUserInteractionEnabled = configuration.property(name: "isUserInteractionEnabled", key: "userInteractionEnabled", defaultValue: true)
        tintColor = configuration.property(name: "tintColor")
        isHidden = configuration.property(name: "isHidden", key: "hidden")
        alpha = configuration.property(name: "alpha", defaultValue: 1)
        isOpaque = configuration.property(name: "isOpaque", key: "opaque", defaultValue: true)
        isMultipleTouchEnabled = configuration.property(name: "isMultipleTouchEnabled", key: "multipleTouchEnabled")
        isExclusiveTouch = configuration.property(name: "isExclusiveTouch", key: "exclusiveTouch")
        autoresizesSubviews = configuration.property(name: "autoresizesSubviews", defaultValue: true)
        contentMode = configuration.property(name: "contentMode", defaultValue: .scaleToFill)
        translatesAutoresizingMaskIntoConstraints = configuration.property(name: "translatesAutoresizingMaskIntoConstraints", defaultValue: true)
        preservesSuperviewLayoutMargins = configuration.property(name: "preservesSuperviewLayoutMargins")
        tag = configuration.property(name: "tag")
        canBecomeFocused = configuration.property(name: "canBecomeFocused")
        visibility = configuration.property(name: "visibility", defaultValue: .visible)
        collapseAxis = configuration.property(name: "collapseAxis", defaultValue: .vertical)
        frame = configuration.property(name: "frame", defaultValue: .zero)
        bounds = configuration.property(name: "bounds", defaultValue: .zero)
        layoutMargins = configuration.property(name: "layoutMargins", defaultValue: EdgeInsets(horizontal: 8, vertical: 8))
        
        transform = configuration.property(name: "transform", defaultValue: AffineTransformation(transformations: []))
        
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
    case numeric(Double)

    public init(_ value: String) throws {
        switch value {
        case "fill":
            self = .fill
        case "wrap":
            self = .wrap
        default:
            guard let doubleValue = Double(value) else {
                throw TokenizationError(message: "Unknown preferred dimension \(value)")
            }
            self = .numeric(doubleValue)
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
    #if canImport(SwiftCodeGen)
    public func generate(context: SupportedPropertyTypeContext) -> Expression {
        return .constant("")
    }
    #endif

    #if SanAndreas
    public func dematerialize(context: SupportedPropertyTypeContext) -> String {
        if width == height {
            return "\(width.stringValue)"
        }
        return "\(width.stringValue),\(height.stringValue)"
    }
    #endif

    #if canImport(UIKit)
    public func runtimeValue(context: SupportedPropertyTypeContext) -> Any? {
        return nil
    }
    #endif

    public static var xsdType: XSDType {
        return .builtin(.string)
    }

    public static func runtimeType(for platform: RuntimePlatform) -> RuntimeType {
        return .unsupported
    }
}

extension PreferredSize: AttributeSupportedPropertyType {
    public static func materialize(from value: String) throws -> PreferredSize {
        if !value.contains(",") {
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
}
