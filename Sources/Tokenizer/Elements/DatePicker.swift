import Foundation

#if ReactantRuntime
    import UIKit
#endif

public class DatePicker: View {
    override class var availableProperties: [PropertyDescription] {
        return [
            assignable(name: "minuteInterval", type: Int.self),
            assignable(name: "mode", swiftName: "datePickerMode", key: "datePickerMode", type: DatePickerMode.self),
            ] + super.availableProperties
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
