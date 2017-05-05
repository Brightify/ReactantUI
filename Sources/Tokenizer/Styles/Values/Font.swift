import Foundation

public enum Font {
    case system(weight: SystemFontWeight, size: Float)
    case named(String, size: Float)
}

#if ReactantRuntime
    import UIKit

    extension Font: Applicable {

        public var value: Any? {
            switch self {
            case .system(let weight, let size):
                return UIFont.systemFont(ofSize: CGFloat(size), weight: weight.value)
            case .named(let name, let size):
                return UIFont(name, CGFloat(size))
            }
        }
    }
#endif
