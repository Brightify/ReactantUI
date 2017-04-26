import Foundation

public enum VisualEffect {
    case blur(BlurEffect)
    case vibrancy(BlurEffect)
}

public enum BlurEffect: String {
    case extraLight
    case light
    case dark
    case prominent
    case regular
}

#if ReactantRuntime
    import UIKit

    extension BlurEffect: Appliable {

        public var value: Any? {
            switch self {
            case .extraLight:
                return UIBlurEffect(style: .extraLight)
            case .light:
                return UIBlurEffect(style: .light)
            case .dark:
                return UIBlurEffect(style: .dark)
            case .prominent:
                if #available(iOS 10.0, *) {
                    return UIBlurEffect(style: .prominent)
                } else {
                    // FIXME check default values
                    return UIBlurEffect(style: .light)
                }
            case .regular:
                if #available(iOS 10.0, *) {
                    return UIBlurEffect(style: .regular)
                } else {
                    return UIBlurEffect(style: .light)
                }
            }
        }
    }
#endif
