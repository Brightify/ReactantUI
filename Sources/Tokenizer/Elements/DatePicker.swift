import Foundation

#if ReactantRuntime
    import UIKit
#endif

public class DatePicker: View {
    public static let minuteInterval = assignable(name: "minuteInterval", type: Int.self)
    public static let mode = assignable(name: "mode", swiftName: "datePickerMode", key: "datePickerMode", type: DatePickerMode.self)
    
    override class var availableProperties: [PropertyDescription] {
        return [
            minuteInterval,
            mode,
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
