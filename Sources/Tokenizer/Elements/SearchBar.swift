import Foundation

#if ReactantRuntime
    import UIKit
#endif

public class SearchBar: View {
    
    override class var availableProperties: [PropertyDescription] {
        return Properties.searchBar.allProperties
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
