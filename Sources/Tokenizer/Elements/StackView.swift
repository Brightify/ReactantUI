import Foundation

#if ReactantRuntime
import UIKit
#endif

public enum LayoutAxis: String, SupportedPropertyType {
    case vertical
    case horizontal

    public var generated: String {
        switch self {
        case .vertical:
            return "UILayoutConstraintAxis.vertical"
        case .horizontal:
            return "UILayoutConstraintAxis.horizontal"
        }
    }
}

#if ReactantRuntime
    import UIKit

    extension LayoutAxis {
        public var runtimeValue: Any? {
            switch self {
            case .vertical:
                return UILayoutConstraintAxis.vertical
            case .horizontal:
                return UILayoutConstraintAxis.horizontal
            }
        }
    }
#endif

public class StackView: Container {
    
    public static let axis = assignable(name: "axis", type: LayoutAxis.self)
    public static let spacing = assignable(name: "spacing", type: Float.self)
    public static let distribution = assignable(name: "distribution", type: LayoutDistribution.self)
    public static let alignment = assignable(name: "alignment", type: LayoutAlignment.self)
    public static let isBaselineRelativeArrangement = assignable(name: "isBaselineRelativeArrangement", key: "baselineRelativeArrangement", type: Bool.self)
    public static let isLayoutMarginsRelativeArrangement = assignable(name: "isLayoutMarginsRelativeArrangement", key: "layoutMarginsRelativeArrangement", type: Bool.self)
    
    override class var availableProperties: [PropertyDescription] {
        return [
            axis,
            spacing,
            distribution,
            alignment,
            isBaselineRelativeArrangement,
            isLayoutMarginsRelativeArrangement,
        ] + super.availableProperties
    }

    public override var addSubviewMethod: String {
        return "addArrangedSubview"
    }

    #if ReactantRuntime
    public override func add(subview: UIView, toInstanceOfSelf: UIView) {
        guard let stackView = toInstanceOfSelf as? UIStackView else {
            return super.add(subview: subview, toInstanceOfSelf: toInstanceOfSelf)
        }
        stackView.addArrangedSubview(subview)
    }
    #endif

    public class override var runtimeType: String {
        return "UIStackView"
    }

    #if ReactantRuntime
    public override func initialize() -> UIView {
        return UIStackView()
    }
    #endif
}
