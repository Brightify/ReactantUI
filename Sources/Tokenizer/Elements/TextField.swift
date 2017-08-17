import Foundation

#if ReactantRuntime
import UIKit
import Reactant
#endif

public class TextField: View {

    override class var availableProperties: [PropertyDescription] {
        return Properties.textField.allProperties
    }

    public class override var runtimeType: String {
        return "Reactant.TextField"
    }

    #if ReactantRuntime
    public override func initialize() -> UIView {
        return Reactant.TextField()
    }
    #endif
}
