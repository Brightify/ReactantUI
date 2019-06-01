//
//  MapView.swift
//  ReactantUI
//
//  Created by Matous Hybl.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

#if canImport(UIKit)
import UIKit
import MapKit
#endif

public class MapView: View {
    public override class var availableProperties: [PropertyDescription] {
        return Properties.mapView.allProperties
    }

    public override class var parentModuleImport: String {
        return "MapKit"
    }

    public override var requiredImports: Set<String> {
        return ["MapKit"]
    }

    public class override func runtimeType() -> String {
        return "MKMapView"
    }

    public override func runtimeType(for platform: RuntimePlatform) throws -> RuntimeType {
        switch platform {
        case .iOS:
            return RuntimeType(name: "MKMapView", module: "MapKit")
        case .tvOS:
            fatalError("Not implemented, check if tvOS has this view.")
        }
    }

    #if canImport(UIKit)
    public override func initialize(context: ReactantLiveUIWorker.Context) -> UIView {
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
        mapType = configuration.property(name: "mapType", defaultValue: .standard)
        isZoomEnabled = configuration.property(name: "isZoomEnabled", key: "zoomEnabled", defaultValue: true)
        isScrollEnabled = configuration.property(name: "isScrollEnabled", key: "scrollEnabled", defaultValue: true)
        isPitchEnabled = configuration.property(name: "isPitchEnabled", key: "pitchEnabled", defaultValue: true)
        isRotateEnabled = configuration.property(name: "isRotateEnabled", key: "rotateEnabled", defaultValue: true)
        showsPointsOfInterest = configuration.property(name: "showsPointsOfInterest", defaultValue: true)
        showsBuildings = configuration.property(name: "showsBuildings", defaultValue: true)
        showsCompass = configuration.property(name: "showsCompass", defaultValue: true)
        showsZoomControls = configuration.property(name: "showsZoomControls")
        showsScale = configuration.property(name: "showsScale")
        showsTraffic = configuration.property(name: "showsTraffic")
        showsUserLocation = configuration.property(name: "showsUserLocation")
        isUserLocationVisible = configuration.property(name: "isUserLocationVisible", key: "userLocationVisible")

        super.init(configuration: configuration)
    }
}
    
