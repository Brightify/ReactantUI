import Foundation

public enum MapType: String {
    case standard
    case satellite
    case hybrid
    case satelliteFlyover
    case hybridFlyover
}

#if ReactantRuntime
    import MapKit

    extension MapType: Appliable {

        public var value: Any? {
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
