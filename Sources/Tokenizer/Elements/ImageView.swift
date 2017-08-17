import Foundation

#if ReactantRuntime
import UIKit
#endif

public struct Image: SupportedPropertyType {
    public let name: String

    public var generated: String {
        return "UIImage(named: \"\(name)\")"
    }

    #if ReactantRuntime
    public var runtimeValue: Any? {
        return UIImage(named: name)
    }
    #endif
    
    #if SanAndreas
    public func dematerialize() -> String {
    return name
    }
    #endif

    public init(named name: String) {
        self.name = name
    }

    public static func materialize(from value: String) throws -> Image {
        return Image(named: value)
    }
}

public class ImageView: View {
    override class var availableProperties: [PropertyDescription] {
        return Properties.imageView.allProperties
    }

    public class override var runtimeType: String {
        return "UIImageView"
    }

    #if ReactantRuntime
    public override func initialize() -> UIView {
        return UIImageView()
    }
    #endif
}
