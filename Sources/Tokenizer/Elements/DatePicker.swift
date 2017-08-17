import Foundation

#if ReactantRuntime
    import UIKit
#endif

public class DatePicker: View {
    override class var availableProperties: [PropertyDescription] {
        return Properties.datePicker.allProperties
    }

    public class override var runtimeType: String {
        return "UIDatePicker"
    }

    #if ReactantRuntime
    public override func initialize() -> UIView {
        return UIDatePicker()
    }
    #endif
}
