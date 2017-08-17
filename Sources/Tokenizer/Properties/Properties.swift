//
//  Properties.swift
//  Pods
//
//  Created by Matous Hybl on 18/08/2017.
//
//

import Foundation

public struct Properties {
    public static let view = prepare(ViewProperties.self)
    public static let label = prepare(LabelProperties.self)
    public static let button = prepare(ButtonProperties.self)
    public static let activityIndicator = prepare(ActivityIndicatorProperties.self)
    public static let datePicker = prepare(DatePickerProperties.self)
    public static let imageView = prepare(ImageViewProperties.self)
    public static let mapView = prepare(MapViewProperties.self)
    public static let navigationBar = prepare(NavigationBarProperties.self)
    public static let pageControl = prepare(PageControlProperties.self)
    public static let pickerView = prepare(PickerViewProperties.self)
    public static let scrollView = prepare(ScrollViewProperties.self)
    public static let searchBar = prepare(SearchBarProperties.self)
    public static let segmentedControl = prepare(SegmentedControlProperties.self)
    public static let slider = prepare(SliderProperties.self)
    public static let stackView = prepare(StackViewProperties.self)
    public static let stepper = prepare(StepperProperties.self)
    public static let `switch` = prepare(SwitchProperties.self)
    public static let tabBar = prepare(TabBarProperties.self)
    public static let tableView = prepare(TableViewProperties.self)
    public static let textField = prepare(TextFieldProperties.self)
    public static let textView = prepare(TextViewProperties.self)
    public static let toolbar = prepare(ToolbarProperties.self)
    public static let visualEffectView = prepare(VisualEffectViewProperties.self)
    public static let webView = prepare(WebViewProperties.self)
    
    static func prepare<T: PropertyContainer>(_ type: T.Type) -> T {
        return T.init(configuration: PropertyContainer.Configuration(namespace: []))
    }
}
