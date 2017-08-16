import Foundation

#if ReactantRuntime
    import UIKit
#endif

public class SearchBar: View {
    public static let text = assignable(name: "text", type: TransformedText.self)
    public static let placeholder = assignable(name: "placeholder", type: TransformedText.self)
    public static let prompt = assignable(name: "prompt", type: TransformedText.self)
    public static let barTintColor = assignable(name: "barTintColor", type: UIColorPropertyType.self)
    public static let barStyle = assignable(name: "barStyle", type: BarStyle.self)
    public static let searchBarStyle = assignable(name: "searchBarStyle", type: SearchBarStyle.self)
    public static let isTranslucent = assignable(name: "isTranslucent", key: "translucent", type: Bool.self)
    public static let showsBookmarkButton = assignable(name: "showsBookmarkButton", type: Bool.self)
    public static let showsCancelButton = assignable(name: "showsCancelButton", type: Bool.self)
    public static let showsSearchResultsButton = assignable(name: "showsSearchResultsButton", type: Bool.self)
    public static let isSearchResultsButtonSelected = assignable(name: "isSearchResultsButtonSelected", key: "searchResultsButtonSelected", type: Bool.self)
    public static let selectedScopeButtonIndex = assignable(name: "selectedScopeButtonIndex", type: Int.self)
    public static let showsScopeBar = assignable(name: "showsScopeBar", type: Bool.self)
    public static let backgroundImage = assignable(name: "backgroundImage", type: Image.self)
    public static let scopeBarBackgroundImage = assignable(name: "scopeBarBackgroundImage", type: Image.self)
    
    override class var availableProperties: [PropertyDescription] {
        return [
            text,
            placeholder,
            prompt,
            barTintColor,
            barStyle,
            searchBarStyle,
            isTranslucent,
            showsBookmarkButton,
            showsCancelButton,
            showsSearchResultsButton,
            isSearchResultsButtonSelected,
            selectedScopeButtonIndex,
            showsScopeBar,
            backgroundImage,
            scopeBarBackgroundImage,
            ] + super.availableProperties
    }

    public class override var runtimeType: String {
        return "UISearchBar"
    }

    #if ReactantRuntime
    public override func initialize() -> UIView {
    return UISearchBar()
    }
    #endif
}
