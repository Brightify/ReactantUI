import Foundation

#if ReactantRuntime
    import UIKit
    import MapKit
#endif

public class MapView: View {
    
    public static let mapType = assignable(name: "mapType", type: MapType.self)
    public static let isZoomEnabled = assignable(name: "isZoomEnabled", key: "zoomEnabled", type: Bool.self)
    public static let isScrollEnabled = assignable(name: "isScrollEnabled", key: "scrollEnabled", type: Bool.self)
    public static let isPitchEnabled = assignable(name: "isPitchEnabled", key: "pitchEnabled", type: Bool.self)
    public static let isRotateEnabled = assignable(name: "isRotateEnabled", key: "rotateEnabled", type: Bool.self)
    public static let showsPointsOfInterest = assignable(name: "showsPointsOfInterest", type: Bool.self)
    public static let showsBuildings = assignable(name: "showsBuildings", type: Bool.self)
    public static let showsCompass = assignable(name: "showsCompass", type: Bool.self)
    public static let showsZoomControls = assignable(name: "showsZoomControls", type: Bool.self)
    public static let showsScale = assignable(name: "showsScale", type: Bool.self)
    public static let showsTraffic = assignable(name: "showsTraffic", type: Bool.self)
    public static let showsUserLocation = assignable(name: "showsUserLocation", type: Bool.self)
    public static let isUserLocationVisible = assignable(name: "isUserLocationVisible", key: "userLocationVisible", type: Bool.self)
    
    override class var availableProperties: [PropertyDescription] {
        return [
            mapType,
            isZoomEnabled,
            isScrollEnabled,
            isPitchEnabled,
            isRotateEnabled,
            showsPointsOfInterest,
            showsBuildings,
            showsCompass,
            showsZoomControls,
            showsScale,
            showsTraffic,
            showsUserLocation,
            isUserLocationVisible,
            ] + super.availableProperties
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
