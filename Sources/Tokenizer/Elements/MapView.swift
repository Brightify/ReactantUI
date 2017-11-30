//
//  MapView.swift
//  ReactantUI
//
//  Created by Matous Hybl.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

#if ReactantRuntime
    import UIKit
    import MapKit
#endif

public class MapView: View {
    
    override class var availableProperties: [PropertyDescription] {
        return Properties.mapView.allProperties
    }

    public override var requiredImports: Set<String> {
        return ["MapKit"]
    }

    public class override var runtimeType: String {
        return "MKMapView"
    }

    #if ReactantRuntime
    public override func initialize() -> UIView {
    return MKMapView()
    }
    #endif
}

public class MapViewProperties: ViewProperties {
    public let mapType: AssignablePropertyDescription<MapType>
    public let isZoomEnabled: AssignablePropertyDescription<Bool>
    public let isScrollEnabled: AssignablePropertyDescription<Bool>
    public let isPitchEnabled: AssignablePropertyDescription<Bool>
    public let isRotateEnabled: AssignablePropertyDescription<Bool>
    public let showsPointsOfInterest: AssignablePropertyDescription<Bool>
    public let showsBuildings: AssignablePropertyDescription<Bool>
    public let showsCompass: AssignablePropertyDescription<Bool>
    public let showsZoomControls: AssignablePropertyDescription<Bool>
    public let showsScale: AssignablePropertyDescription<Bool>
    public let showsTraffic: AssignablePropertyDescription<Bool>
    public let showsUserLocation: AssignablePropertyDescription<Bool>
    public let isUserLocationVisible: AssignablePropertyDescription<Bool>
    
    public required init(configuration: Configuration) {
        mapType = configuration.property(name: "mapType")
        isZoomEnabled = configuration.property(name: "isZoomEnabled", key: "zoomEnabled")
        isScrollEnabled = configuration.property(name: "isScrollEnabled", key: "scrollEnabled")
        isPitchEnabled = configuration.property(name: "isPitchEnabled", key: "pitchEnabled")
        isRotateEnabled = configuration.property(name: "isRotateEnabled", key: "rotateEnabled")
        showsPointsOfInterest = configuration.property(name: "showsPointsOfInterest")
        showsBuildings = configuration.property(name: "showsBuildings")
        showsCompass = configuration.property(name: "showsCompass")
        showsZoomControls = configuration.property(name: "showsZoomControls")
        showsScale = configuration.property(name: "showsScale")
        showsTraffic = configuration.property(name: "showsTraffic")
        showsUserLocation = configuration.property(name: "showsUserLocation")
        isUserLocationVisible = configuration.property(name: "isUserLocationVisible", key: "userLocationVisible")
        
        super.init(configuration: configuration)
    }
}
    
