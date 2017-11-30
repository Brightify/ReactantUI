//
//  MapType.swift
//  ReactantUI
//
//  Created by Tadeas Kriz.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

public enum MapType: String, EnumPropertyType {
    public static let enumName = "MKMapType"

    case standard
    case satellite
    case hybrid
    case satelliteFlyover
    case hybridFlyover
}

#if ReactantRuntime
    import MapKit

    extension MapType {

        public var runtimeValue: Any? {
            switch self {
            case .standard:
                return MKMapType.standard.rawValue
            case .satellite:
                return MKMapType.satellite.rawValue
            case .hybrid:
                return MKMapType.hybrid.rawValue
            case .satelliteFlyover:
                return MKMapType.satelliteFlyover.rawValue
            case .hybridFlyover:
                return MKMapType.hybridFlyover.rawValue
            }
        }
    }
#endif
