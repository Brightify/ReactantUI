public enum ContentMode: String {
    case scaleAspectFit
    case scaleAspectFill
}

#if ReactantRuntime
import UIKit

extension ContentMode: Applicable {

    public var value: Any? {
        switch self {
        case .scaleAspectFill:
            return UIViewContentMode.scaleAspectFill.rawValue
        case .scaleAspectFit:
            return UIViewContentMode.scaleAspectFit.rawValue
        }
    }
}
#endif
