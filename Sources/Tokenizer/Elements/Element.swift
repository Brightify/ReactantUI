typealias ElementaryDearWatson = Element

public struct Element {
    public static let elementMapping: [String: View.Type] = [
        "View": View.self,
        "Component": ComponentReference.self,
        "Container": Container.self,
        "Label": Label.self,
        "TextField": TextField.self,
        "Button": Button.self,
        "ImageView": ImageView.self,
        "ScrollView": ScrollView.self,
        "StackView": StackView.self,
        "ActivityIndicator": ActivityIndicatorElement.self,
        "TextView": TextView.self,
        "PlainTableView": PlainTableView.self,
        "DatePicker": DatePicker.self,
        "NavigationBar": NavigationBar.self,
        "PageControl": PageControl.self,
        "PickerView": PickerView.self,
        "SearchBar": SearchBar.self,
        "SegmentedControl": SegmentedControl.self,
        "Slider": Slider.self,
        "Stepper": Stepper.self,
        "Switch": Switch.self,
        "TabBar": TabBar.self,
        "TableView": TableView.self,
        "Toolbar": Toolbar.self,
        "VisualEffectView": VisualEffectView.self,
        "WebView": WebView.self,
        "MapView": MapView.self,
    ]
}
