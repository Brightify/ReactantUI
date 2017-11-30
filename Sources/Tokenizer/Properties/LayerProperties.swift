//
//  LayerProperties.swift
//  ReactantUI
//
//  Created by Matous Hybl on 18/08/2017.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

public class LayerProperties: PropertyContainer {
    public let cornerRadius: AssignablePropertyDescription<Float>
    public let borderWidth: AssignablePropertyDescription<Float>
    public let borderColor: AssignablePropertyDescription<CGColorPropertyType>
    public let opacity: AssignablePropertyDescription<Float>
    public let isHidden: AssignablePropertyDescription<Bool>
    public let masksToBounds: AssignablePropertyDescription<Bool>
    public let isDoubleSided: AssignablePropertyDescription<Bool>
    public let backgroundColor: AssignablePropertyDescription<CGColorPropertyType>
    public let shadowOpacity: AssignablePropertyDescription<Float>
    public let shadowRadius: AssignablePropertyDescription<Float>
    public let shadowColor: AssignablePropertyDescription<CGColorPropertyType>
    public let allowsEdgeAntialiasing: AssignablePropertyDescription<Bool>
    public let allowsGroupOpacity: AssignablePropertyDescription<Bool>
    public let isOpaque: AssignablePropertyDescription<Bool>
    public let isGeometryFlipped: AssignablePropertyDescription<Bool>
    public let shouldRasterize: AssignablePropertyDescription<Bool>
    public let rasterizationScale: AssignablePropertyDescription<Float>
    public let contentsFormat: AssignablePropertyDescription<TransformedText>
    public let contentsScale: AssignablePropertyDescription<Float>
    public let zPosition: AssignablePropertyDescription<Float>
    public let name: AssignablePropertyDescription<TransformedText>
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
        borderColor = configuration.property(name: "borderColor")
        opacity = configuration.property(name: "opacity")
        isHidden = configuration.property(name: "isHidden", key: "hidden")
        masksToBounds = configuration.property(name: "masksToBounds")
        shadowOpacity = configuration.property(name: "shadowOpacity")
        shadowRadius = configuration.property(name: "shadowRadius")
        shadowColor = configuration.property(name: "shadowColor")
        allowsEdgeAntialiasing = configuration.property(name: "allowsEdgeAntialiasing")
        allowsGroupOpacity = configuration.property(name: "allowsGroupOpacity")
        isOpaque = configuration.property(name: "isOpaque", key: "opaque")
        shouldRasterize = configuration.property(name: "shouldRasterize")
        rasterizationScale = configuration.property(name: "rasterizationScale")
        contentsFormat = configuration.property(name: "contentsFormat")
        contentsScale = configuration.property(name: "contentsScale")
        zPosition = configuration.property(name: "zPosition")
        name = configuration.property(name: "name")
        contentsRect = configuration.property(name: "contentsRect")
        contentsCenter = configuration.property(name: "contentsCenter")
        shadowOffset = configuration.property(name: "shadowOffset")
        frame = configuration.property(name: "frame")
        bounds = configuration.property(name: "bounds")
        position = configuration.property(name: "position")
        anchorPoint = configuration.property(name: "anchorPoint")
        backgroundColor = configuration.property(name: "backgroundColor")
        isDoubleSided = configuration.property(name: "isDoubleSided", key: "doubleSided")
        isGeometryFlipped = configuration.property(name: "isGeometryFlipped", key: "geometryFlipped")
        
        super.init(configuration: configuration)
    }
}
