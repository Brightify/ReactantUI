import Foundation

#if ReactantRuntime
    import UIKit
#endif

// TODO might be replaced with our generic implementation
public class PickerView: View {
    override class var availableProperties: [PropertyDescription] {
        return Properties.pickerView.allProperties
    }

    public class override var runtimeType: String {
        return "UIPickerView"
    }

    #if ReactantRuntime
    public override func initialize() -> UIView {
    return UIPickerView()
    }
    #endif
}
