import Foundation
#if ReactantRuntime
import UIKit
#endif

extension XMLElement {
    func value<T: XMLElementDeserializable>() throws -> T {
        return try T.deserialize(self)
    }

    var indexer: XMLIndexer {
        return XMLIndexer(self)
    }

    func elements(named: String) -> [XMLElement] {
        return xmlChildren.filter { $0.name == named }
    }

    func singleElement(named: String) throws -> XMLElement {
        let allNamedElements = elements(named: named)
        guard allNamedElements.count == 1 else {
            throw TokenizationError(message: "Requires element named `\(named)` to be defined!")
        }
        return allNamedElements[0]
    }

    func singleOrNoElement(named: String) throws -> XMLElement? {
        let allNamedElements = elements(named: named)
        guard allNamedElements.count <= 1 else {
            throw TokenizationError(message: "Maximum number of elements named `\(named)` is 1!")
        }
        return allNamedElements.first
    }
}

extension Array where Element == PropertyContainer.Namespace {
    var resolvedKeyPath: String {
        return map { $0.name }.joined(separator: ".")
    }
    
    func resolvedAttributeName(name: String) -> String {
        return (map { $0.name } + [name]).joined(separator: ".")
    }
    
    func resolvedSwiftName(target: String) -> String {
        return ([target] + map { "\($0.name)\($0.isOptional ? "?" : "")" }).joined(separator: ".")
    }
}

open class PropertyContainer {
    public struct Namespace {
        let name: String
        let isOptional: Bool
    }
    public final class Configuration {
        public let namespace: [Namespace]
        public var properties: [PropertyDescription] = []
        
        fileprivate init(namespace: [Namespace]) {
            self.namespace = namespace
        }
        
        func assignable<T>(name: String, swiftName: String, key: String) -> AssignablePropertyDescription<T> {
            let property = AssignablePropertyDescription<T>(namespace: namespace, name: name, swiftName: swiftName, key: key)
            properties.append(property)
            return property
        }
        
        func controlState<T>(name: String, key: String) -> ControlStatePropertyDescription<T> {
            let property = ControlStatePropertyDescription<T>(namespace: namespace, name: name, key: key)
            properties.append(property)
            return property
        }
        
        public func property<T>(name: String) -> AssignablePropertyDescription<T> {
            return assignable(name: name, swiftName: name, key: name)
        }
        
        public func property<T>(name: String, swiftName: String) -> AssignablePropertyDescription<T> {
            return assignable(name: name, swiftName: swiftName, key: name)
        }
        
        public func property<T>(name: String, key: String) -> AssignablePropertyDescription<T> {
            return assignable(name: name, swiftName: name, key: key)
        }
        
        public func property<T>(name: String, swiftName: String, key: String) -> AssignablePropertyDescription<T> {
            return assignable(name: name, swiftName: swiftName, key: key)
        }
        
        public func property<T>(name: String) -> ControlStatePropertyDescription<T> {
            return controlState(name: name, key: name)
        }
        
        public func property<T>(name: String, key: String) -> ControlStatePropertyDescription<T> {
            return controlState(name: name, key: key)
        }
        
        public func namespaced<T: PropertyContainer>(in namespace: String, optional: Bool = false, _ type: T.Type) -> T {
            let configuration = Configuration(namespace: self.namespace + [Namespace(name: namespace, isOptional: optional)])
            let container = T.init(configuration: configuration)
            properties.append(contentsOf: container.allProperties)
            return container
        }
    }
    
    let namespace: [Namespace]
    let allProperties: [PropertyDescription]
    
    public required init(configuration: Configuration) {
        self.namespace = configuration.namespace
        self.allProperties = configuration.properties
    }
}

public struct Properties {
    public static let view = prepare(View.self)
    public static let label = prepare(Label.self)
    public static let button = prepare(Button.self)
    public static let activityIndicator = prepare(ActivityIndicator.self)
    public static let datePicker = prepare(DatePicker.self)
    public static let imageView = prepare(ImageView.self)
    public static let mapView = prepare(MapView.self)
    public static let navigationBar = prepare(NavigationBar.self)
    public static let pageControl = prepare(PageControl.self)
    public static let pickerView = prepare(PickerView.self)
    public static let scrollView = prepare(ScrollView.self)
    public static let searchBar = prepare(SearchBar.self)
    public static let segmentedControl = prepare(SegmentedControl.self)
    public static let slider = prepare(Slider.self)
    public static let stackView = prepare(StackView.self)
    public static let stepper = prepare(Stepper.self)
    public static let `switch` = prepare(Switch.self)
    public static let tabBar = prepare(TabBar.self)
    public static let tableView = prepare(TableView.self)
    public static let textField = prepare(TextField.self)
    public static let textView = prepare(TextView.self)
    public static let toolbar = prepare(Toolbar.self)
    public static let visualEffectView = prepare(VisualEffectView.self)
    public static let webView = prepare(WebView.self)
    
    public class Layer: PropertyContainer {
        public let cornerRadius: AssignablePropertyDescription<Float>
        public let borderWidth: AssignablePropertyDescription<Float>
        public let borderColor: AssignablePropertyDescription<CGColorPropertyType>
        public let opacity: AssignablePropertyDescription<Float>
        public let isHidden: AssignablePropertyDescription<Bool>
        public let masksToBounds: AssignablePropertyDescription<Bool>
        public let isDoubleSided: AssignablePropertyDescription<Bool>
        public let backgroundColor: AssignablePropertyDescription<CGColorPropertyType>
        public let shadowOpacity: AssignablePropertyDescription<Float>
        public let shadowRadius: AssignablePropertyDescription<Float>
        public let shadowColor: AssignablePropertyDescription<CGColorPropertyType>
        public let allowsEdgeAntialiasing: AssignablePropertyDescription<Bool>
        public let allowsGroupOpacity: AssignablePropertyDescription<Bool>
        public let isOpaque: AssignablePropertyDescription<Bool>
        public let isGeometryFlipped: AssignablePropertyDescription<Bool>
        public let shouldRasterize: AssignablePropertyDescription<Bool>
        public let rasterizationScale: AssignablePropertyDescription<Float>
        public let contentsFormat: AssignablePropertyDescription<TransformedText>
        public let contentsScale: AssignablePropertyDescription<Float>
        public let zPosition: AssignablePropertyDescription<Float>
        public let name: AssignablePropertyDescription<TransformedText>
        public let contentsRect: AssignablePropertyDescription<Rect>
        public let contentsCenter: AssignablePropertyDescription<Rect>
        public let shadowOffset: AssignablePropertyDescription<Size>
        public let frame: AssignablePropertyDescription<Rect>
        public let bounds: AssignablePropertyDescription<Rect>
        public let position: AssignablePropertyDescription<Point>
        public let anchorPoint: AssignablePropertyDescription<Point>
        
        public required init(configuration: Configuration) {
            cornerRadius = configuration.property(name: "cornerRadius")
            borderWidth = configuration.property(name: "borderWidth")
            borderColor = configuration.property(name: "borderColor")
            opacity = configuration.property(name: "opacity")
            isHidden = configuration.property(name: "isHidden")
            masksToBounds = configuration.property(name: "masksToBounds")
            shadowOpacity = configuration.property(name: "shadowOpacity")
            shadowRadius = configuration.property(name: "shadowRadius")
            shadowColor = configuration.property(name: "shadowColor")
            allowsEdgeAntialiasing = configuration.property(name: "allowsEdgeAntialiasing")
            allowsGroupOpacity = configuration.property(name: "allowsGroupOpacity")
            isOpaque = configuration.property(name: "isOpaque")
            shouldRasterize = configuration.property(name: "shouldRasterize")
            rasterizationScale = configuration.property(name: "rasterizationScale")
            contentsFormat = configuration.property(name: "contentsFormat")
            contentsScale = configuration.property(name: "contentsScale")
            zPosition = configuration.property(name: "zPosition")
            name = configuration.property(name: "name")
            contentsRect = configuration.property(name: "contentsRect")
            contentsCenter = configuration.property(name: "contentsCenter")
            shadowOffset = configuration.property(name: "shadowOffset")
            frame = configuration.property(name: "frame")
            bounds = configuration.property(name: "bounds")
            position = configuration.property(name: "position")
            anchorPoint = configuration.property(name: "anchorPoint")
            backgroundColor = configuration.property(name: "backgroundColor")
            isDoubleSided = configuration.property(name: "isDoubleSided", key: "doubleSided")
            isGeometryFlipped = configuration.property(name: "isGeometryFlipped", key: "geometryFlipped")
            
            super.init(configuration: configuration)
        }
    }
    
    public class View: PropertyContainer {
        public let backgroundColor: AssignablePropertyDescription<UIColorPropertyType>
        public let clipsToBounds: AssignablePropertyDescription<Bool>
        public let isUserInteractionEnabled: AssignablePropertyDescription<Bool>
        public let tintColor: AssignablePropertyDescription<UIColorPropertyType>
        public let isHidden: AssignablePropertyDescription<Bool>
        public let alpha: AssignablePropertyDescription<Float>
        public let isOpaque: AssignablePropertyDescription<Bool>
        public let isMultipleTouchEnabled: AssignablePropertyDescription<Bool>
        public let isExclusiveTouch: AssignablePropertyDescription<Bool>
        public let autoresizesSubviews: AssignablePropertyDescription<Bool>
        public let contentMode: AssignablePropertyDescription<ContentMode>
        public let translatesAutoresizingMaskIntoConstraints: AssignablePropertyDescription<Bool>
        public let preservesSuperviewLayoutMargins: AssignablePropertyDescription<Bool>
        public let tag: AssignablePropertyDescription<Int>
        public let canBecomeFocused: AssignablePropertyDescription<Bool>
        public let visibility: AssignablePropertyDescription<ViewVisibility>
        public let frame: AssignablePropertyDescription<Rect>
        public let bounds: AssignablePropertyDescription<Rect>
        public let layoutMargins: AssignablePropertyDescription<EdgeInsets>
        
        public let layer: Layer
        
        public required init(configuration: Configuration) {
            backgroundColor = configuration.property(name: "backgroundColor")
            clipsToBounds = configuration.property(name: "clipsToBounds")
            isUserInteractionEnabled = configuration.property(name: "isUserInteractionEnabled", key: "userInteractionEnabled")
            tintColor = configuration.property(name: "tintColor")
            isHidden = configuration.property(name: "isHidden")
            alpha = configuration.property(name: "alpha")
            isOpaque = configuration.property(name: "isOpaque")
            isMultipleTouchEnabled = configuration.property(name: "isMultipleTouchEnabled", key: "multipleTouchEnabled")
            isExclusiveTouch = configuration.property(name: "isExclusiveTouch", key: "exclusiveTouch")
            autoresizesSubviews = configuration.property(name: "autoresizesSubviews")
            contentMode = configuration.property(name: "contentMode")
            translatesAutoresizingMaskIntoConstraints = configuration.property(name: "translatesAutoresizingMaskIntoConstraints")
            preservesSuperviewLayoutMargins = configuration.property(name: "preservesSuperviewLayoutMargins")
            tag = configuration.property(name: "tag")
            canBecomeFocused = configuration.property(name: "canBecomeFocused")
            visibility = configuration.property(name: "visibility")
            frame = configuration.property(name: "frame")
            bounds = configuration.property(name: "bounds")
            layoutMargins = configuration.property(name: "layoutMargins")
            
            layer = configuration.namespaced(in: "layer", Layer.self)
            
            super.init(configuration: configuration)
        }
    }
    
    public class ActivityIndicator: View {
        public let color: AssignablePropertyDescription<UIColorPropertyType>
        public let hidesWhenStopped: AssignablePropertyDescription<Bool>
        public let indicatorStyle: AssignablePropertyDescription<ActivityIndicatorStyle>
        
        public required init(configuration: Configuration) {
            color = configuration.property(name: "color")
            hidesWhenStopped = configuration.property(name: "hidesWhenStopped")
            indicatorStyle = configuration.property(name: "indicatorStyle", swiftName: "activityIndicatorViewStyle", key: "activityIndicatorViewStyle")
            
            super.init(configuration: configuration)
        }
    }
    
    public class Label: View {
        public let text: AssignablePropertyDescription<TransformedText>
        public let textColor: AssignablePropertyDescription<UIColorPropertyType>
        public let highlightedTextColor: AssignablePropertyDescription<UIColorPropertyType>
        public let font: AssignablePropertyDescription<Font>
        public let numberOfLines: AssignablePropertyDescription<Int>
        public let textAlignment: AssignablePropertyDescription<TextAlignment>
        public let isEnabled: AssignablePropertyDescription<Bool>
        public let adjustsFontSizeToFitWidth: AssignablePropertyDescription<Bool>
        public let allowsDefaultTighteningBeforeTruncation: AssignablePropertyDescription<Bool>
        public let minimumScaleFactor: AssignablePropertyDescription<Float>
        public let isHighlighted: AssignablePropertyDescription<Bool>
        public let shadowOffset: AssignablePropertyDescription<Size>
        public let shadowColor: AssignablePropertyDescription<UIColorPropertyType>
        public let preferredMaxLayoutWidth: AssignablePropertyDescription<Float>
        public let lineBreakMode: AssignablePropertyDescription<LineBreakMode>
        
        public required init(configuration: Configuration) {
            text = configuration.property(name: "text")
            textColor = configuration.property(name: "textColor")
            highlightedTextColor = configuration.property(name: "highlightedTextColor")
            font = configuration.property(name: "font")
            numberOfLines = configuration.property(name: "numberOfLines")
            textAlignment = configuration.property(name: "textAlignment")
            isEnabled = configuration.property(name: "isEnabled", key: "enabled")
            adjustsFontSizeToFitWidth = configuration.property(name: "adjustsFontSizeToFitWidth")
            allowsDefaultTighteningBeforeTruncation = configuration.property(name: "allowsDefaultTighteningBeforeTruncation")
            minimumScaleFactor = configuration.property(name: "minimumScaleFactor")
            isHighlighted = configuration.property(name: "isHighlighted", key: "highlighted")
            shadowOffset = configuration.property(name: "shadowOffset")
            shadowColor = configuration.property(name: "shadowColor")
            preferredMaxLayoutWidth = configuration.property(name: "preferredMaxLayoutWidth")
            lineBreakMode = configuration.property(name: "lineBreakMode")
            
            super.init(configuration: configuration)
        }
    }
    
    public class Button: View {
        public let title: ControlStatePropertyDescription<TransformedText>
        public let titleColor: ControlStatePropertyDescription<UIColorPropertyType>
        public let backgroundColorForState: ControlStatePropertyDescription<UIColorPropertyType>
        public let titleShadowColor: ControlStatePropertyDescription<UIColorPropertyType>
        public let image: ControlStatePropertyDescription<Image>
        public let backgroundImage: ControlStatePropertyDescription<Image>
        public let reversesTitleShadowWhenHighlighted: AssignablePropertyDescription<Bool>
        public let adjustsImageWhenHighlighted: AssignablePropertyDescription<Bool>
        public let adjustsImageWhenDisabled: AssignablePropertyDescription<Bool>
        public let showsTouchWhenHighlighted: AssignablePropertyDescription<Bool>
        public let contentEdgeInsets: AssignablePropertyDescription<EdgeInsets>
        public let titleEdgeInsets: AssignablePropertyDescription<EdgeInsets>
        public let imageEdgeInsets: AssignablePropertyDescription<EdgeInsets>
        
        public let titleLabel: Label
        public let imageView: ImageView
        
        public required init(configuration: Configuration) {
            title = configuration.property(name: "title")
            titleColor = configuration.property(name: "titleColor")
            backgroundColorForState = configuration.property(name: "backgroundColor")
            titleShadowColor = configuration.property(name: "titleShadowColor")
            image = configuration.property(name: "image")
            backgroundImage = configuration.property(name: "backgroundImage")
            reversesTitleShadowWhenHighlighted = configuration.property(name: "reversesTitleShadowWhenHighlighted")
            adjustsImageWhenHighlighted = configuration.property(name: "adjustsImageWhenHighlighted")
            adjustsImageWhenDisabled = configuration.property(name: "adjustsImageWhenDisabled")
            showsTouchWhenHighlighted = configuration.property(name: "showsTouchWhenHighlighted")
            contentEdgeInsets = configuration.property(name: "contentEdgeInsets")
            titleEdgeInsets = configuration.property(name: "titleEdgeInsets")
            imageEdgeInsets = configuration.property(name: "imageEdgeInsets")
            titleLabel = configuration.namespaced(in: "titleLabel", optional: true, Label.self)
            imageView = configuration.namespaced(in: "imageView", ImageView.self)
            
            super.init(configuration: configuration)
        }
    }
    
    public class ImageView: View {
        public let image: AssignablePropertyDescription<Image>
        public let highlightedImage: AssignablePropertyDescription<Image>
        public let animationDuration: AssignablePropertyDescription<Double>
        public let animationRepeatCount: AssignablePropertyDescription<Int>
        public let isHighlighted: AssignablePropertyDescription<Bool>
        public let adjustsImageWhenAncestorFocused: AssignablePropertyDescription<Bool>
        
        public required init(configuration: Configuration) {
            image = configuration.property(name: "image")
            highlightedImage = configuration.property(name: "highlightedImage")
            animationDuration = configuration.property(name: "animationDuration")
            animationRepeatCount = configuration.property(name: "animationRepeatCount")
            isHighlighted = configuration.property(name: "isHighlighted", key: "highlighted")
            adjustsImageWhenAncestorFocused = configuration.property(name: "adjustsImageWhenAncestorFocused")
            
            super.init(configuration: configuration)
        }
    }
    
    public class DatePicker: View {
        public let minuteInterval: AssignablePropertyDescription<Int>
        public let mode: AssignablePropertyDescription<DatePickerMode>
        
        public required init(configuration: Configuration) {
            minuteInterval = configuration.property(name: "minuteInterval")
            mode = configuration.property(name: "mode", swiftName: "datePickerMode", key: "datePickerMode")
            super.init(configuration: configuration)
        }
    }
    
    public class MapView: View {
        public let mapType: AssignablePropertyDescription<MapType>
        public let isZoomEnabled: AssignablePropertyDescription<Bool>
        public let isScrollEnabled: AssignablePropertyDescription<Bool>
        public let isPitchEnabled: AssignablePropertyDescription<Bool>
        public let isRotateEnabled: AssignablePropertyDescription<Bool>
        public let showsPointsOfInterest: AssignablePropertyDescription<Bool>
        public let showsBuildings: AssignablePropertyDescription<Bool>
        public let showsCompass: AssignablePropertyDescription<Bool>
        public let showsZoomControls: AssignablePropertyDescription<Bool>
        public let showsScale: AssignablePropertyDescription<Bool>
        public let showsTraffic: AssignablePropertyDescription<Bool>
        public let showsUserLocation: AssignablePropertyDescription<Bool>
        public let isUserLocationVisible: AssignablePropertyDescription<Bool>
        
        public required init(configuration: Configuration) {
            mapType = configuration.property(name: "mapType")
            isZoomEnabled = configuration.property(name: "isZoomEnabled", key: "zoomEnabled")
            isScrollEnabled = configuration.property(name: "isScrollEnabled", key: "scrollEnabled")
            isPitchEnabled = configuration.property(name: "isPitchEnabled", key: "pitchEnabled")
            isRotateEnabled = configuration.property(name: "isRotateEnabled", key: "rotateEnabled")
            showsPointsOfInterest = configuration.property(name: "showsPointsOfInterest")
            showsBuildings = configuration.property(name: "showsBuildings")
            showsCompass = configuration.property(name: "showsCompass")
            showsZoomControls = configuration.property(name: "showsZoomControls")
            showsScale = configuration.property(name: "showsScale")
            showsTraffic = configuration.property(name: "showsTraffic")
            showsUserLocation = configuration.property(name: "showsUserLocation")
            isUserLocationVisible = configuration.property(name: "isUserLocationVisible", key: "userLocationVisible")
            
            super.init(configuration: configuration)
        }
    }
    
    public class NavigationBar: View {
        public let barTintColor: AssignablePropertyDescription<UIColorPropertyType>
        public let backIndicatorImage: AssignablePropertyDescription<Image>
        public let backIndicatorTransitionMaskImage: AssignablePropertyDescription<Image>
        public let shadowImage: AssignablePropertyDescription<Image>
        public let isTranslucent: AssignablePropertyDescription<Bool>
        public let barStyle: AssignablePropertyDescription<BarStyle>
        
        public required init(configuration: Configuration) {
            barTintColor = configuration.property(name: "barTintColor")
            backIndicatorImage = configuration.property(name: "backIndicatorImage")
            backIndicatorTransitionMaskImage = configuration.property(name: "backIndicatorTransitionMaskImage")
            shadowImage = configuration.property(name: "shadowImage")
            isTranslucent = configuration.property(name: "isTranslucent", key: "translucent")
            barStyle = configuration.property(name: "barStyle")
            
            super.init(configuration: configuration)
        }
    }
    
    public class PageControl: View {
        public let currentPage: AssignablePropertyDescription<Int>
        public let numberOfPages: AssignablePropertyDescription<Int>
        public let hidesForSinglePage: AssignablePropertyDescription<Bool>
        public let pageIndicatorTintColor: AssignablePropertyDescription<UIColorPropertyType>
        public let currentPageIndicatorTintColor: AssignablePropertyDescription<UIColorPropertyType>
        public let defersCurrentPageDisplay: AssignablePropertyDescription<Bool>
        
        public required init(configuration: Configuration) {
            currentPage = configuration.property(name: "currentPage")
            numberOfPages = configuration.property(name: "numberOfPages")
            hidesForSinglePage = configuration.property(name: "hidesForSinglePage")
            pageIndicatorTintColor = configuration.property(name: "pageIndicatorTintColor")
            currentPageIndicatorTintColor = configuration.property(name: "currentPageIndicatorTintColor")
            defersCurrentPageDisplay = configuration.property(name: "defersCurrentPageDisplay")
            
            super.init(configuration: configuration)
        }
    }
    
    public class PickerView: View {
        public required init(configuration: Configuration) {
            
            super.init(configuration: configuration)
        }
    }
    
    public class ScrollView: View {
        public let contentOffset: AssignablePropertyDescription<Point>
        public let contentSize: AssignablePropertyDescription<Size>
        public let contentInset: AssignablePropertyDescription<EdgeInsets>
        public let isScrollEnabled: AssignablePropertyDescription<Bool>
        public let isDirectionalLockEnabled: AssignablePropertyDescription<Bool>
        public let isPagingEnabled: AssignablePropertyDescription<Bool>
        public let bounces: AssignablePropertyDescription<Bool>
        public let alwaysBounceVertical: AssignablePropertyDescription<Bool>
        public let alwaysBounceHorizontal: AssignablePropertyDescription<Bool>
        public let delaysContentTouches: AssignablePropertyDescription<Bool>
        public let decelerationRate: AssignablePropertyDescription<Float>
        public let scrollIndicatorInsets: AssignablePropertyDescription<EdgeInsets>
        public let showsHorizontalScrollIndicator: AssignablePropertyDescription<Bool>
        public let showsVerticalScrollIndicator: AssignablePropertyDescription<Bool>
        public let zoomScale: AssignablePropertyDescription<Float>
        public let maximumZoomScale: AssignablePropertyDescription<Float>
        public let minimumZoomScale: AssignablePropertyDescription<Float>
        public let bouncesZoom: AssignablePropertyDescription<Bool>
        public let indicatorStyle: AssignablePropertyDescription<ScrollViewIndicatorStyle>
        
        public required init(configuration: Configuration) {
            contentOffset = configuration.property(name: "contentOffset")
            contentSize = configuration.property(name: "contentSize")
            contentInset = configuration.property(name: "contentInset")
            isScrollEnabled = configuration.property(name: "isScrollEnabled", key: "scrollEnabled")
            isDirectionalLockEnabled = configuration.property(name: "isDirectionalLockEnabled", key: "directionalLockEnabled")
            isPagingEnabled = configuration.property(name: "isPagingEnabled", key: "pagingEnabled")
            bounces = configuration.property(name: "bounces")
            alwaysBounceVertical = configuration.property(name: "alwaysBounceVertical")
            alwaysBounceHorizontal = configuration.property(name: "alwaysBounceHorizontal")
            delaysContentTouches = configuration.property(name: "delaysContentTouches")
            decelerationRate = configuration.property(name: "decelerationRate")
            scrollIndicatorInsets = configuration.property(name: "scrollIndicatorInsets")
            showsHorizontalScrollIndicator = configuration.property(name: "showsHorizontalScrollIndicator")
            showsVerticalScrollIndicator = configuration.property(name: "showsVerticalScrollIndicator")
            zoomScale = configuration.property(name: "zoomScale")
            maximumZoomScale = configuration.property(name: "maximumZoomScale")
            minimumZoomScale = configuration.property(name: "minimumZoomScale")
            bouncesZoom = configuration.property(name: "bouncesZoom")
            indicatorStyle = configuration.property(name: "indicatorStyle")
            
            super.init(configuration: configuration)
        }
        
    }
    
    public class SearchBar: View {
        public let text: AssignablePropertyDescription<TransformedText>
        public let placeholder: AssignablePropertyDescription<TransformedText>
        public let prompt: AssignablePropertyDescription<TransformedText>
        public let barTintColor: AssignablePropertyDescription<UIColorPropertyType>
        public let barStyle: AssignablePropertyDescription<BarStyle>
        public let searchBarStyle: AssignablePropertyDescription<SearchBarStyle>
        public let isTranslucent: AssignablePropertyDescription<Bool>
        public let showsBookmarkButton: AssignablePropertyDescription<Bool>
        public let showsCancelButton: AssignablePropertyDescription<Bool>
        public let showsSearchResultsButton: AssignablePropertyDescription<Bool>
        public let isSearchResultsButtonSelected: AssignablePropertyDescription<Bool>
        public let selectedScopeButtonIndex: AssignablePropertyDescription<Int>
        public let showsScopeBar: AssignablePropertyDescription<Bool>
        public let backgroundImage: AssignablePropertyDescription<Image>
        public let scopeBarBackgroundImage: AssignablePropertyDescription<Image>
        
        public required init(configuration: Configuration) {
            text = configuration.property(name: "text")
            placeholder = configuration.property(name: "placeholder")
            prompt = configuration.property(name: "prompt")
            barTintColor = configuration.property(name: "barTintColor")
            barStyle = configuration.property(name: "barStyle")
            searchBarStyle = configuration.property(name: "searchBarStyle")
            isTranslucent = configuration.property(name: "isTranslucent", key: "translucent")
            showsBookmarkButton = configuration.property(name: "showsBookmarkButton")
            showsCancelButton = configuration.property(name: "showsCancelButton")
            showsSearchResultsButton = configuration.property(name: "showsSearchResultsButton")
            isSearchResultsButtonSelected = configuration.property(name: "isSearchResultsButtonSelected", key: "searchResultsButtonSelected")
            selectedScopeButtonIndex = configuration.property(name: "selectedScopeButtonIndex")
            showsScopeBar = configuration.property(name: "showsScopeBar")
            backgroundImage = configuration.property(name: "backgroundImage")
            scopeBarBackgroundImage = configuration.property(name: "scopeBarBackgroundImage")
            
            super.init(configuration: configuration)
        }
    }
    
    public class SegmentedControl: View {
        public let selectedSegmentIndex: AssignablePropertyDescription<Int>
        public let isMomentary: AssignablePropertyDescription<Bool>
        public let apportionsSegmentWidthsByContent: AssignablePropertyDescription<Bool>
        
        public required init(configuration: Configuration) {
            selectedSegmentIndex = configuration.property(name: "selectedSegmentIndex")
            isMomentary = configuration.property(name: "isMomentary")
            apportionsSegmentWidthsByContent = configuration.property(name: "apportionsSegmentWidthsByContent")
            
            super.init(configuration: configuration)
        }
    }
    
    public class Slider: View {
        public let value: AssignablePropertyDescription<Float>
        public let minimumValue: AssignablePropertyDescription<Float>
        public let maximumValue: AssignablePropertyDescription<Float>
        public let isContinuous: AssignablePropertyDescription<Bool>
        public let minimumValueImage: AssignablePropertyDescription<Image>
        public let maximumValueImage: AssignablePropertyDescription<Image>
        public let minimumTrackTintColor: AssignablePropertyDescription<UIColorPropertyType>
        public let currentMinimumTrackImage: AssignablePropertyDescription<Image>
        public let maximumTrackTintColor: AssignablePropertyDescription<UIColorPropertyType>
        public let currentMaximumTrackImage: AssignablePropertyDescription<Image>
        public let thumbTintColor: AssignablePropertyDescription<UIColorPropertyType>
        public let currentThumbImage: AssignablePropertyDescription<Image>
        
        public required init(configuration: Configuration) {
            value = configuration.property(name: "value")
            minimumValue = configuration.property(name: "minimumValue")
            maximumValue = configuration.property(name: "maximumValue")
            isContinuous = configuration.property(name: "isContinuous")
            minimumValueImage = configuration.property(name: "minimumValueImage")
            maximumValueImage = configuration.property(name: "maximumValueImage")
            minimumTrackTintColor = configuration.property(name: "minimumTrackTintColor")
            currentMinimumTrackImage = configuration.property(name: "currentMinimumTrackImage")
            maximumTrackTintColor = configuration.property(name: "maximumTrackTintColor")
            currentMaximumTrackImage = configuration.property(name: "currentMaximumTrackImage")
            thumbTintColor = configuration.property(name: "thumbTintColor")
            currentThumbImage = configuration.property(name: "currentThumbImage")
            
            super.init(configuration: configuration)
        }
    }
    
    public class StackView: View {
        public let axis: AssignablePropertyDescription<LayoutAxis>
        public let spacing: AssignablePropertyDescription<Float>
        public let distribution: AssignablePropertyDescription<LayoutDistribution>
        public let alignment: AssignablePropertyDescription<LayoutAlignment>
        public let isBaselineRelativeArrangement: AssignablePropertyDescription<Bool>
        public let isLayoutMarginsRelativeArrangement: AssignablePropertyDescription<Bool>
        
        public required init(configuration: Configuration) {
            axis = configuration.property(name: "axis")
            spacing = configuration.property(name: "spacing")
            distribution = configuration.property(name: "distribution")
            alignment = configuration.property(name: "alignment")
            isBaselineRelativeArrangement = configuration.property(name: "isBaselineRelativeArrangement", key: "baselineRelativeArrangement")
            isLayoutMarginsRelativeArrangement = configuration.property(name: "isLayoutMarginsRelativeArrangement", key: "layoutMarginsRelativeArrangement")
            
            super.init(configuration: configuration)
        }
    }
    
    public class Stepper: View {
        public let value: AssignablePropertyDescription<Double>
        public let minimumValue: AssignablePropertyDescription<Double>
        public let maximumValue: AssignablePropertyDescription<Double>
        public let stepValue: AssignablePropertyDescription<Double>
        public let isContinuous: AssignablePropertyDescription<Bool>
        public let autorepeat: AssignablePropertyDescription<Bool>
        public let wraps: AssignablePropertyDescription<Bool>
        
        public required init(configuration: Configuration) {
            value = configuration.property(name: "value")
            minimumValue = configuration.property(name: "minimumValue")
            maximumValue = configuration.property(name: "maximumValue")
            stepValue = configuration.property(name: "stepValue")
            isContinuous = configuration.property(name: "isContinuous", key: "continuous")
            autorepeat = configuration.property(name: "autorepeat")
            wraps = configuration.property(name: "wraps")
            
            super.init(configuration: configuration)
        }
    }
    
    public class Switch: View {
        public let isOn: AssignablePropertyDescription<Bool>
        public let onTintColor: AssignablePropertyDescription<UIColorPropertyType>
        public let thumbTintColor: AssignablePropertyDescription<UIColorPropertyType>
        public let onImage: AssignablePropertyDescription<Image>
        public let offImage: AssignablePropertyDescription<Image>
        
        public required init(configuration: Configuration) {
            isOn = configuration.property(name: "isOn")
            onTintColor = configuration.property(name: "onTintColor")
            thumbTintColor = configuration.property(name: "thumbTintColor")
            onImage = configuration.property(name: "onImage")
            offImage = configuration.property(name: "offImage")
            
            super.init(configuration: configuration)
        }
    }
    
    public class TabBar: View {
        public let isTranslucent: AssignablePropertyDescription<Bool>
        public let barStyle: AssignablePropertyDescription<BarStyle>
        public let barTintColor: AssignablePropertyDescription<UIColorPropertyType>
        public let itemSpacing: AssignablePropertyDescription<Float>
        public let itemWidth: AssignablePropertyDescription<Float>
        public let backgroundImage: AssignablePropertyDescription<Image>
        public let shadowImage: AssignablePropertyDescription<Image>
        public let selectionIndicatorImage: AssignablePropertyDescription<Image>
        
        public required init(configuration: Configuration) {
            isTranslucent = configuration.property(name: "isTranslucent", key: "translucent")
            barStyle = configuration.property(name: "barStyle")
            barTintColor = configuration.property(name: "barTintColor")
            itemSpacing = configuration.property(name: "itemSpacing")
            itemWidth = configuration.property(name: "itemWidth")
            backgroundImage = configuration.property(name: "backgroundImage")
            shadowImage = configuration.property(name: "shadowImage")
            selectionIndicatorImage = configuration.property(name: "selectionIndicatorImage")
            
            super.init(configuration: configuration)
        }
    }
    
    public class TableView: View {
        
        public required init(configuration: Configuration) {
            
            super.init(configuration: configuration)
        }
    }
    
    public class TextField: View {
        public let text: AssignablePropertyDescription<TransformedText>
        public let placeholder: AssignablePropertyDescription<TransformedText>
        public let font: AssignablePropertyDescription<Font>
        public let textColor: AssignablePropertyDescription<UIColorPropertyType>
        public let textAlignment: AssignablePropertyDescription<TextAlignment>
        public let adjustsFontSizeToWidth: AssignablePropertyDescription<Bool>
        public let minimumFontSize: AssignablePropertyDescription<Float>
        public let clearsOnBeginEditing: AssignablePropertyDescription<Bool>
        public let clearsOnInsertion: AssignablePropertyDescription<Bool>
        public let allowsEditingTextAttributes: AssignablePropertyDescription<Bool>
        public let background: AssignablePropertyDescription<Image>
        public let disabledBackground: AssignablePropertyDescription<Image>
        public let borderStyle: AssignablePropertyDescription<TextBorderStyle>
        public let clearButtonMode: AssignablePropertyDescription<TextFieldViewMode>
        public let leftViewMode: AssignablePropertyDescription<TextFieldViewMode>
        public let rightViewMode: AssignablePropertyDescription<TextFieldViewMode>
        public let contentEdgeInsets: AssignablePropertyDescription<EdgeInsets>
        public let placeholderColor: AssignablePropertyDescription<UIColorPropertyType>
        public let placeholderFont: AssignablePropertyDescription<Font>
        public let isSecureTextEntry: AssignablePropertyDescription<Bool>
        public let keyboardType: AssignablePropertyDescription<KeyboardType>
        public let keyboardAppearance: AssignablePropertyDescription<KeyboardAppearance>
        public let contentType: AssignablePropertyDescription<TextContentType>
        public let returnKey: AssignablePropertyDescription<ReturnKeyType>
        
        public required init(configuration: Configuration) {
            text = configuration.property(name: "text")
            placeholder = configuration.property(name: "placeholder")
            font = configuration.property(name: "font")
            textColor = configuration.property(name: "textColor")
            textAlignment = configuration.property(name: "textAlignment")
            adjustsFontSizeToWidth = configuration.property(name: "adjustsFontSizeToWidth")
            minimumFontSize = configuration.property(name: "minimumFontSize")
            clearsOnBeginEditing = configuration.property(name: "clearsOnBeginEditing")
            clearsOnInsertion = configuration.property(name: "clearsOnInsertion")
            allowsEditingTextAttributes = configuration.property(name: "allowsEditingTextAttributes")
            background = configuration.property(name: "background")
            disabledBackground = configuration.property(name: "disabledBackground")
            borderStyle = configuration.property(name: "borderStyle")
            clearButtonMode = configuration.property(name: "clearButtonMode")
            leftViewMode = configuration.property(name: "leftViewMode")
            rightViewMode = configuration.property(name: "rightViewMode")
            contentEdgeInsets = configuration.property(name: "contentEdgeInsets")
            placeholderColor = configuration.property(name: "placeholderColor")
            placeholderFont = configuration.property(name: "placeholderFont")
            isSecureTextEntry = configuration.property(name: "secure", swiftName: "isSecureTextEntry", key: "secureTextEntry")
            keyboardType = configuration.property(name: "keyboardType")
            keyboardAppearance = configuration.property(name: "keyboardAppearance")
            contentType = configuration.property(name: "contentType")
            returnKey = configuration.property(name: "returnKey")
            
            super.init(configuration: configuration)
        }
        
    }
    
    public class TextView: View {
        public let text: AssignablePropertyDescription<TransformedText>
        public let font: AssignablePropertyDescription<Font>
        public let textColor: AssignablePropertyDescription<UIColorPropertyType>
        public let textAlignment: AssignablePropertyDescription<TextAlignment>
        public let textContainerInset: AssignablePropertyDescription<EdgeInsets>
        public let allowsEditingTextAttributes: AssignablePropertyDescription<Bool>
        
        public required init(configuration: Configuration) {
            text = configuration.property(name: "text")
            font = configuration.property(name: "font")
            textColor = configuration.property(name: "textColor")
            textAlignment = configuration.property(name: "textAlignment")
            textContainerInset = configuration.property(name: "textContainerInset")
            allowsEditingTextAttributes = configuration.property(name: "allowsEditingTextAttributes")
            
            super.init(configuration: configuration)
        }
    }
    
    public class Toolbar: View {
        public let isTranslucent: AssignablePropertyDescription<Bool>
        public let barStyle: AssignablePropertyDescription<BarStyle>
        public let barTintColor: AssignablePropertyDescription<UIColorPropertyType>
        
        public required init(configuration: Configuration) {
            isTranslucent = configuration.property(name: "isTranslucent", key: "translucent")
            barStyle = configuration.property(name: "barStyle")
            barTintColor = configuration.property(name: "barTintColor")
            
            super.init(configuration: configuration)
        }
    }
    
    public class VisualEffectView: View {
        public let effect: AssignablePropertyDescription<VisualEffect>
        
        public required init(configuration: Configuration) {
            effect = configuration.property(name: "effect")
            
            super.init(configuration: configuration)
        }
    }
    
    public class WebView: View {
        public let allowsMagnification: AssignablePropertyDescription<Bool>
        public let magnification: AssignablePropertyDescription<Float>
        public let allowsBackForwardNavigationGestures: AssignablePropertyDescription<Bool>
        
        public required init(configuration: Configuration) {
            allowsMagnification = configuration.property(name: "allowsMagnification")
            magnification = configuration.property(name: "magnification")
            allowsBackForwardNavigationGestures = configuration.property(name: "allowsBackForwardNavigationGestures")
            
            super.init(configuration: configuration)
        }
    }
    
    static func prepare<T: PropertyContainer>(_ type: T.Type) -> T {
        return T.init(configuration: PropertyContainer.Configuration(namespace: []))
    }
}

public class View: XMLElementDeserializable, UIElement {
    
    class var availableProperties: [PropertyDescription] {
        return Properties.view.allProperties
    }

    public class var runtimeType: String {
        return "UIView"
    }

    public var requiredImports: Set<String> {
        return ["UIKit"]
    }

    public var field: String?
    public var styles: [String]
    public var layout: Layout
    public var properties: [Property]

    public var initialization: String {
        return "\(type(of: self).runtimeType)()"
    }

    #if ReactantRuntime
    public func initialize() throws -> UIView {
        return UIView()
    }
    #endif

    public required init(node: XMLElement) throws {
        field = node.value(ofAttribute: "field")
        layout = try node.value()
        styles = (node.value(ofAttribute: "style") as String?)?
            .components(separatedBy: CharacterSet.whitespacesAndNewlines) ?? []

        if node.name == "View" && node.count != 0 {
            throw TokenizationError(message: "View must not have any children, use Container instead.")
        }

        properties = try View.deserializeSupportedProperties(properties: type(of: self).availableProperties, in: node)
    }

    public static func deserialize(_ node: XMLElement) throws -> Self {
        return try self.init(node: node)
    }

    public static func deserialize(nodes: [XMLElement]) throws -> [UIElement] {
        return try nodes.flatMap { node -> UIElement? in
            if let elementType = Element.elementMapping[node.name] {
                return try elementType.init(node: node)
            } else if node.name == "styles" {
                // Intentionally ignored as these are parsed directly
                return nil
            } else {
                throw TokenizationError(message: "Unknown tag `\(node.name)`")
            }
        }
    }

    static func deserializeSupportedProperties(properties: [PropertyDescription], in element: SWXMLHash.XMLElement) throws -> [Property] {
        var result = [] as [Property]
        for (attributeName, attribute) in element.allAttributes {
            guard let propertyDescription = properties.first(where: { $0.matches(attributeName: attributeName) }) else {
                continue
            }
//            guard
            let property = try propertyDescription.materialize(attributeName: attributeName, value: attribute.text)
//            else {
//                #if ReactantRuntime
//                throw LiveUIError(message: "// Could not materialize property `\(propertyDescription)` from `\(attribute)`")
//                #else
//                throw TokenizationError(message: "// Could not materialize property `\(propertyDescription)` from `\(attribute)`")
//                #endif
//            }
            result.append(property)
        }
        return result
    }
    
    public func serialize() -> MagicElement {
        var builder = MagicAttributeBuilder()
        if let field = field {
            builder.attribute(name: "field", value: field)
        }
        let styleNames = styles.joined(separator: " ")
        if !styleNames.isEmpty {
            builder.attribute(name: "style", value: styleNames)
        }
        
        #if SanAndreas
            properties.map { $0.dematerialize() }.forEach { builder.add(attribute: $0) }
        #endif
        
        layout.serialize().forEach { builder.add(attribute: $0) }
        
        let typeOfSelf = type(of: self)
        let name = Element.elementMapping.first(where: { $0.value == typeOfSelf })?.key ?? "\(typeOfSelf)"
        return MagicElement(name: name, attributes: builder.attributes, children: [])
    }
}
