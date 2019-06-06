//
//  Module+UIKit.swift
//  Tokenizer
//
//  Created by Tadeas Kriz on 02/06/2019.
//

import Foundation

extension Module {
    public static let uiKit = UIKit()

    public struct UIKit: RuntimeModule {
        public let supportedPlatforms: Set<RuntimePlatform> = [
            .iOS,
            .tvOS,
        ]

        public var referenceFactory: ComponentReferenceFactory {
            return ComponentReferenceFactory(baseFactory: factory(named: "View", for: View.init))
        }

        public func elements(for platform: RuntimePlatform) -> [UIElementFactory] {
            return [
                factory(named: "View", for: View.init),
                factory(named: "Component", for: ComponentReference.init),
                factory(named: "Container", for: Container.init),
                factory(named: "Label", for: Label.init),
                factory(named: "TextField", for: TextField.init),
                factory(named: "Button", for: Button.init),
                factory(named: "ImageView", for: ImageView.init),
                factory(named: "ScrollView", for: ScrollView.init),
                factory(named: "StackView", for: StackView.init),
                factory(named: "ActivityIndicator", for: ActivityIndicatorElement.init),
                factory(named: "TextView", for: TextView.init),
                factory(named: "PlainTableView", for: PlainTableView.init),
                factory(named: "HeaderTableView", for: HeaderTableView.init),
                factory(named: "FooterTableView", for: FooterTableView.init),
                factory(named: "SimpleTableView", for: SimpleTableView.init),
                factory(named: "SimulatedSeparatorTableView", for: SimulatedSeparatorTableView.init),
                factory(named: "DatePicker", for: DatePicker.init),
                factory(named: "NavigationBar", for: NavigationBar.init),
                factory(named: "PageControl", for: PageControl.init),
                factory(named: "PickerView", for: PickerView.init),
                factory(named: "SearchBar", for: SearchBar.init),
                factory(named: "SegmentedControl", for: SegmentedControl.init),
                factory(named: "Slider", for: Slider.init),
                factory(named: "Stepper", for: Stepper.init),
                factory(named: "Switch", for: Switch.init),
                factory(named: "TabBar", for: TabBar.init),
                factory(named: "TableView", for: TableView.init),
                factory(named: "Toolbar", for: Toolbar.init),
                factory(named: "VisualEffectView", for: VisualEffectView.init),
                factory(named: "ProgressView", for: ProgressView.init),
            ]
        }
    }
}
