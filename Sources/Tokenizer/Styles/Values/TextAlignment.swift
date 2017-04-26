public enum TextAlignment: String {
    case left
    case right
    case center
    case justified
    case natural
}

#if ReactantRuntime
    import UIKit

    extension TextAlignment: Applicable {

        public var value: Any? {
            switch self {
            case .center:
                return NSTextAlignment.center.rawValue
            case .left:
                return NSTextAlignment.left.rawValue
            case .right:
                return NSTextAlignment.right.rawValue
            case .justified:
                return NSTextAlignment.justified.rawValue
            case .natural:
                return NSTextAlignment.natural.rawValue
            }
        }
    }
#endif
