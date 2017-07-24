import Foundation

#if ReactantRuntime
    import UIKit
    import MapKit
#endif

public class MapView: View {
    override class var availableProperties: [PropertyDescription] {
        return [
            assignable(name: "mapType", type: MapType.self),
            assignable(name: "isZoomEnabled", key: "zoomEnabled", type: Bool.self),
            assignable(name: "isScrollEnabled", key: "scrollEnabled", type: Bool.self),
            assignable(name: "isPitchEnabled", key: "pitchEnabled", type: Bool.self),
            assignable(name: "isRotateEnabled", key: "rotateEnabled", type: Bool.self),
            assignable(name: "showsPointsOfInterest", type: Bool.self),
            assignable(name: "showsBuildings", type: Bool.self),
            assignable(name: "showsCompass", type: Bool.self),
            assignable(name: "showsZoomControls", type: Bool.self),
            assignable(name: "showsScale", type: Bool.self),
            assignable(name: "showsTraffic", type: Bool.self),
            assignable(name: "showsUserLocation", type: Bool.self),
            assignable(name: "isUserLocationVisible", key: "userLocationVisible", type: Bool.self),
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
