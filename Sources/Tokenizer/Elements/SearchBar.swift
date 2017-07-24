import Foundation

#if ReactantRuntime
    import UIKit
#endif

public class SearchBar: View {
    override class var availableProperties: [PropertyDescription] {
        return [
            assignable(name: "text", type: TransformedText.self),
            assignable(name: "placeholder", type: TransformedText.self),
            assignable(name: "prompt", type: TransformedText.self),
            assignable(name: "barTintColor", type: UIColorPropertyType.self),
            assignable(name: "barStyle", type: BarStyle.self),
            assignable(name: "searchBarStyle", type: SearchBarStyle.self),
            assignable(name: "isTranslucent", key: "translucent", type: Bool.self),
            assignable(name: "showsBookmarkButton", type: Bool.self),
            assignable(name: "showsCancelButton", type: Bool.self),
            assignable(name: "showsSearchResultsButton", type: Bool.self),
            assignable(name: "isSearchResultsButtonSelected", key: "searchResultsButtonSelected", type: Bool.self),
            assignable(name: "selectedScopeButtonIndex", type: Int.self),
            assignable(name: "showsScopeBar", type: Bool.self),
            assignable(name: "backgroundImage", type: Image.self),
            assignable(name: "scopeBarBackgroundImage", type: Image.self),
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
