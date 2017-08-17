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
