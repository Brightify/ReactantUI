import Foundation

#if ReactantRuntime
    import UIKit
    import WebKit
    import Reactant
#endif

public class WebView: View {
    
    public static let allowsMagnification = assignable(name: "allowsMagnification", type: Bool.self)
    public static let magnification = assignable(name: "magnification", type: Float.self)
    public static let allowsBackForwardNavigationGestures = assignable(name: "allowsBackForwardNavigationGestures", type: Bool.self)
    
    override class var availableProperties: [PropertyDescription] {
        return [
            allowsMagnification,
            magnification,
            allowsBackForwardNavigationGestures,
            ] + super.availableProperties
    }

    public override var requiredImports: Set<String> {
        return ["WebKit"]
    }

    public class override var runtimeType: String {
        return "WKWebView"
    }

    #if ReactantRuntime
    public override func initialize() -> UIView {
    return WKWebView()
    }
    #endif
}
