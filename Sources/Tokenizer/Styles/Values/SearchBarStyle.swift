import Foundation

public enum SearchBarStyle: String, EnumPropertyType {
    public static let enumName = "UISearchBarStyle"

    case `default`
    case minimal
    case prominent
}

#if ReactantRuntime
    import UIKit

    extension SearchBarStyle {

        public var runtimeValue: Any? {
            switch self {
            case .`default`:
                return UISearchBarStyle.default.rawValue
            case .minimal:
                return UISearchBarStyle.minimal.rawValue
            case .prominent:
                return UISearchBarStyle.prominent.rawValue
            }
        }
    }
#endif
