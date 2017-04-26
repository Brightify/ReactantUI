import Foundation

public enum SearchBarStyle: String {
    case `default`
    case minimal
    case prominent
}

#if ReactantRuntime
    import UIKit

    extension SearchBarStyle: Applicable {

        public var value: Any? {
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
