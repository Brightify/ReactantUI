//
//  LayerProperties.swift
//  ReactantUI
//
//  Created by Matous Hybl on 18/08/2017.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

public class LayerProperties: PropertyContainer {
    public let cornerRadius: AssignablePropertyDescription<Double>
    public let borderWidth: AssignablePropertyDescription<Double>
    public let borderColor: AssignablePropertyDescription<CGColorPropertyType?>
    public let opacity: AssignablePropertyDescription<Double>
    public let isHidden: AssignablePropertyDescription<Bool>
    public let masksToBounds: AssignablePropertyDescription<Bool>
    public let isDoubleSided: AssignablePropertyDescription<Bool>
    public let backgroundColor: AssignablePropertyDescription<CGColorPropertyType?>
    public let shadowOpacity: AssignablePropertyDescription<Double>
    public let shadowRadius: AssignablePropertyDescription<Double>
    public let shadowColor: AssignablePropertyDescription<CGColorPropertyType?>
    public let allowsEdgeAntialiasing: AssignablePropertyDescription<Bool>
    public let allowsGroupOpacity: AssignablePropertyDescription<Bool>
    public let isOpaque: AssignablePropertyDescription<Bool>
    public let isGeometryFlipped: AssignablePropertyDescription<Bool>
    public let shouldRasterize: AssignablePropertyDescription<Bool>
    public let rasterizationScale: AssignablePropertyDescription<Double>
    public let contentsFormat: AssignablePropertyDescription<TransformedText>
    public let contentsScale: AssignablePropertyDescription<Double>
    public let zPosition: AssignablePropertyDescription<Double>
    public let name: AssignablePropertyDescription<TransformedText?>
    public let contentsRect: AssignablePropertyDescription<Rect>
    public let contentsCenter: AssignablePropertyDescription<Rect>
    public let shadowOffset: AssignablePropertyDescription<Size>
    public let frame: AssignablePropertyDescription<Rect>
    public let bounds: AssignablePropertyDescription<Rect>
    public let position: AssignablePropertyDescription<Point>
    public let anchorPoint: AssignablePropertyDescription<Point>
    
    public required init(configuration: Configuration) {
        cornerRadius = configuration.property(name: "cornerRadius")
        borderWidth = configuration.property(name: "borderWidth")
        borderColor = configuration.property(name: "borderColor", defaultValue: .black)
        opacity = configuration.property(name: "opacity", defaultValue: 1)
        isHidden = configuration.property(name: "isHidden", key: "hidden")
        masksToBounds = configuration.property(name: "masksToBounds")
        shadowOpacity = configuration.property(name: "shadowOpacity")
        shadowRadius = configuration.property(name: "shadowRadius", defaultValue: 3)
        shadowColor = configuration.property(name: "shadowColor", defaultValue: .black)
        allowsEdgeAntialiasing = configuration.property(name: "allowsEdgeAntialiasing")
        allowsGroupOpacity = configuration.property(name: "allowsGroupOpacity", defaultValue: true)
        isOpaque = configuration.property(name: "isOpaque", key: "opaque", defaultValue: true)
        shouldRasterize = configuration.property(name: "shouldRasterize")
        rasterizationScale = configuration.property(name: "rasterizationScale", defaultValue: 1)
        contentsFormat = configuration.property(name: "contentsFormat", defaultValue: .text("RGBA8Uint"))
        contentsScale = configuration.property(name: "contentsScale")
        zPosition = configuration.property(name: "zPosition")
        name = configuration.property(name: "name")
        contentsRect = configuration.property(name: "contentsRect", defaultValue: Rect(width: 1, height: 1))
        contentsCenter = configuration.property(name: "contentsCenter", defaultValue: Rect(width: 1, height: 1))
        shadowOffset = configuration.property(name: "shadowOffset", defaultValue: Size(width: 0, height: -3))
        frame = configuration.property(name: "frame", defaultValue: .zero)
        bounds = configuration.property(name: "bounds", defaultValue: .zero)
        position = configuration.property(name: "position", defaultValue: .zero)
        anchorPoint = configuration.property(name: "anchorPoint", defaultValue: Point(x: 0.5, y: 0.5))
        backgroundColor = configuration.property(name: "backgroundColor")
        isDoubleSided = configuration.property(name: "isDoubleSided", key: "doubleSided", defaultValue: true)
        isGeometryFlipped = configuration.property(name: "isGeometryFlipped", key: "geometryFlipped")
        
        super.init(configuration: configuration)
    }
}
