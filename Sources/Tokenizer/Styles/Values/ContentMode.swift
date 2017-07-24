

public enum ContentMode: String, EnumPropertyType {
    public static let enumName = "UIViewContentMode"

    case scaleAspectFit
    case scaleAspectFill
}

#if ReactantRuntime
import UIKit

extension ContentMode {

    public var runtimeValue: Any? {
        switch self {
        case .scaleAspectFill:
            return UIViewContentMode.scaleAspectFill.rawValue
        case .scaleAspectFit:
            return UIViewContentMode.scaleAspectFit.rawValue
        }
    }
}
#endif
