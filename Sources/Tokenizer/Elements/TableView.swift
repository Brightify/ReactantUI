import Foundation

#if ReactantRuntime
    import UIKit
#endif

public class TableView: View {
    override class var availableProperties: [PropertyDescription] {
        return Properties.tableView.allProperties
    }

    public override var initialization: String {
        return "UITableView()"
    }

    #if ReactantRuntime
    public override func initialize() -> UIView {
    return UITableView()
    }
    #endif
}
