//
//  Style.swift
//  ReactantUI
//
//  Created by Tadeas Kriz.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

public struct Style: XMLElementDeserializable {
    public var type: String
    // this is name with group
    public var name: String
    // this is name of the style without group name
    public var styleName: String
    public var extend: [String]
    public var properties: [Property]
    public var groupName: String?

    public var imports: [String]

    init(node: XMLElement, groupName: String? = nil) throws {
        let properties: [Property]
        let type: String
        switch node.name {
        case "ViewStyle":
            properties = try View.deserializeSupportedProperties(properties: View.availableProperties, in: node)
            type = "View"
            imports = []
        case "ContainerStyle":
            properties = try View.deserializeSupportedProperties(properties: Container.availableProperties, in: node)
            type = "Container"
            imports = []
        case "LabelStyle":
            properties = try View.deserializeSupportedProperties(properties: Label.availableProperties, in: node)
            type = "Label"
            imports = []
        case "ButtonStyle":
            properties = try View.deserializeSupportedProperties(properties: Button.availableProperties, in: node)
            type = "Button"
            imports = []
        case "TextFieldStyle":
            properties = try View.deserializeSupportedProperties(properties: TextField.availableProperties, in: node)
            type = "TextField"
            imports = []
        case "ImageViewStyle":
            properties = try View.deserializeSupportedProperties(properties: ImageView.availableProperties, in: node)
            type = "ImageView"
            imports = []
        case "StackViewStyle":
            properties = try View.deserializeSupportedProperties(properties: StackView.availableProperties, in: node)
            type = "StackView"
            imports = []
        case "ActivityIndicatorStyle":
            properties = try View.deserializeSupportedProperties(properties: ActivityIndicatorElement.availableProperties, in: node)
            type = "ActivityIndicator"
            imports = []
        case "DatePickerStyle":
            properties = try View.deserializeSupportedProperties(properties: DatePicker.availableProperties, in: node)
            type = "DatePicker"
            imports = []
        case "NavigationBarStyle":
            properties = try View.deserializeSupportedProperties(properties: NavigationBar.availableProperties, in: node)
            type = "NavigationBar"
            imports = []
        case "PageControlStyle":
            properties = try View.deserializeSupportedProperties(properties: PageControl.availableProperties, in: node)
            type = "PageControl"
            imports = []
        case "PickerViewStyle":
            properties = try View.deserializeSupportedProperties(properties: PickerView.availableProperties, in: node)
            type = "PickerView"
            imports = []
        case "SearchBarStyle":
            properties = try View.deserializeSupportedProperties(properties: SearchBar.availableProperties, in: node)
            type = "SearchBar"
            imports = []
        case "SegmentedControlStyle":
            properties = try View.deserializeSupportedProperties(properties: SegmentedControl.availableProperties, in: node)
            type = "SegmentedControl"
            imports = []
        case "SliderStyle":
            properties = try View.deserializeSupportedProperties(properties: Slider.availableProperties, in: node)
            type = "Slider"
            imports = []
        case "StepperStyle":
            properties = try View.deserializeSupportedProperties(properties: Stepper.availableProperties, in: node)
            type = "Stepper"
            imports = []
        case "SwitchStyle":
            properties = try View.deserializeSupportedProperties(properties: Switch.availableProperties, in: node)
            type = "Switch"
            imports = []
        case "TableViewStyle":
            properties = try View.deserializeSupportedProperties(properties: TableView.availableProperties, in: node)
            type = "TableView"
            imports = []
        case "ToolbarStyle":
            properties = try View.deserializeSupportedProperties(properties: Toolbar.availableProperties, in: node)
            type = "Toolbar"
            imports = []
        case "VisualEffectViewStyle":
            properties = try View.deserializeSupportedProperties(properties: VisualEffectView.availableProperties, in: node)
            type = "VisualEffectView"
            imports = []
        case "WebViewStyle":
            properties = try View.deserializeSupportedProperties(properties: WebView.availableProperties, in: node)
            type = "WebView"
            imports = ["WebKit"]
        case "MapViewStyle":
            properties = try View.deserializeSupportedProperties(properties: MapView.availableProperties, in: node)
            type = "MapView"
            imports = ["MapKit"]
        default:
            throw TokenizationError(message: "Unknown style \(node.name). (\(node))")
        }

        self.type = type
        // FIXME The name has to be done some other way
        let name = try node.value(ofAttribute: "name") as String
        self.styleName = name
        let extendedStyles = (node.value(ofAttribute: "extend") as String?)?.components(separatedBy: " ") ?? []
        self.groupName = groupName
        if let groupName = groupName {
            self.name = ":\(groupName):\(name)"
            self.extend = extendedStyles.map {
                                if $0.contains(":") {
                                    return $0
                                } else {
                                    return ":\(groupName):\($0)"
                                }
                            }
        } else {
            self.name = name
            self.extend = extendedStyles
        }
        self.properties = properties
    }

    public static func deserialize(_ node: XMLElement) throws -> Style {
        return try Style(node: node, groupName: nil)
    }
}

extension Sequence where Iterator.Element == Style {
    public func resolveStyle(for element: UIElement) throws -> [Property] {
        guard !element.styles.isEmpty else { return element.properties }
        guard let type = ElementaryDearWatson.elementMapping.first(where: { $0.value == type(of: element) })?.key else {
            print("// No type found for \(element)")
            return element.properties
        }
        // FIXME This will be slow
        var result = Dictionary<String, Property>(minimumCapacity: element.properties.count)
        for name in element.styles {
            for property in try resolveStyle(for: type, named: name) {
                result[property.attributeName] = property
            }
        }
        for property in element.properties {
            result[property.attributeName] = property
        }
        return Array(result.values)
    }

    public func resolveStyle(for type: String, named name: String) throws -> [Property] {
        guard let style = first(where: { $0.type == type && $0.name == name }) else {
            // FIXME wrong type of error
            throw TokenizationError(message: "Style \(name) for type \(type) doesn't exist!")
        }

        let baseProperties = try style.extend.flatMap { base in
            try resolveStyle(for: type, named: base)
        }
        // FIXME This will be slow
        var result = Dictionary<String, Property>(minimumCapacity: style.properties.count)
        for property in baseProperties + style.properties {
            result[property.attributeName] = property
        }
        return Array(result.values)
    }
}




















