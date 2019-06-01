////: A UIKit based Playground for presenting user interface
//
import UIKit
import MapKit
import WebKit
import PlaygroundSupport

//class MyViewController : UIViewController {
//    override func loadView() {
//        let view = UIView()
//        view.backgroundColor = .white
//
//        let label = UILabel()
//        label.frame = CGRect(x: 150, y: 200, width: 200, height: 20)
//        label.text = "Hello World!"
//        label.textColor = .black
//
//        view.addSubview(label)
//        self.view = view
//    }
//}
//// Present the view controller in the Live View window
//PlaygroundPage.current.liveView = MyViewController()

func assertEqual<T: Equatable>(_ actual: T, _ expected: T, file: StaticString = #file, line: UInt = #line) -> String {
    assert(actual == expected, "Expected <\(expected)>, but got <\(actual)>!", file: file, line: line)
    return String(describing: actual)
}

let label = UILabel()
assertEqual(label.shadowColor, nil)
assertEqual(label.shadowOffset, CGSize(width: 0, height: -1))
assertEqual(label.lineBreakMode, .byTruncatingTail)
assertEqual(label.attributedText, nil)

let map = MKMapView()
assertEqual(map.mapType, .standard)
assertEqual(map.isZoomEnabled, true)
assertEqual(map.isScrollEnabled, true)
assertEqual(map.isPitchEnabled, true)
assertEqual(map.isRotateEnabled, true)

assertEqual(map.showsPointsOfInterest, true)
assertEqual(map.showsBuildings, true)
assertEqual(map.showsCompass, true)
// assertEqual(map.showsZoomControls)
assertEqual(map.showsScale, false)
assertEqual(map.showsTraffic, false)
assertEqual(map.showsUserLocation, false)
assertEqual(map.isUserLocationVisible, false)

let navigationBar = UINavigationBar()

assertEqual(navigationBar.barTintColor, nil)
assertEqual(navigationBar.backIndicatorImage, nil)
assertEqual(navigationBar.backIndicatorTransitionMaskImage, nil)
assertEqual(navigationBar.shadowImage, nil)
assertEqual(navigationBar.isTranslucent, true)
assertEqual(navigationBar.barStyle, .default)

let pageControl = UIPageControl()
assertEqual(pageControl.currentPage, -1)
assertEqual(pageControl.numberOfPages, 0)
assertEqual(pageControl.hidesForSinglePage, false)
assertEqual(pageControl.pageIndicatorTintColor, nil)
assertEqual(pageControl.currentPageIndicatorTintColor, nil)
assertEqual(pageControl.defersCurrentPageDisplay, false)

let progressView = UIProgressView()

assertEqual(progressView.progress, 0)
assertEqual(progressView.progressViewStyle, .default)
assertEqual(progressView.progressTintColor, nil)
assertEqual(progressView.progressImage, nil)
assertEqual(progressView.trackTintColor, nil)
assertEqual(progressView.trackImage, nil)

let scrollView = UIScrollView()

assertEqual(scrollView.contentOffset, .zero)
assertEqual(scrollView.contentSize, .zero)
assertEqual(scrollView.contentInset, .zero)
assertEqual(scrollView.isScrollEnabled, true)
assertEqual(scrollView.isDirectionalLockEnabled, false)
assertEqual(scrollView.isPagingEnabled, false)
assertEqual(scrollView.bounces, true)
assertEqual(scrollView.alwaysBounceVertical, false)
assertEqual(scrollView.alwaysBounceHorizontal, false)
assertEqual(scrollView.delaysContentTouches, true)
assertEqual(scrollView.decelerationRate, .normal)
assertEqual(scrollView.scrollIndicatorInsets, .zero)
assertEqual(scrollView.showsHorizontalScrollIndicator, true)
assertEqual(scrollView.showsVerticalScrollIndicator, true)
assertEqual(scrollView.zoomScale, 1)
assertEqual(scrollView.maximumZoomScale, 1)
assertEqual(scrollView.minimumZoomScale, 1)
assertEqual(scrollView.bouncesZoom, true)
assertEqual(scrollView.indicatorStyle, .default)

let searchBar = UISearchBar()

assertEqual(searchBar.text, "")
assertEqual(searchBar.placeholder, nil)
assertEqual(searchBar.prompt, nil)
assertEqual(searchBar.barTintColor, nil)
assertEqual(searchBar.barStyle, .default)
assertEqual(searchBar.searchBarStyle, .default)
assertEqual(searchBar.isTranslucent, true)
assertEqual(searchBar.showsBookmarkButton, false)
assertEqual(searchBar.showsCancelButton, false)
assertEqual(searchBar.showsSearchResultsButton, false)
assertEqual(searchBar.isSearchResultsButtonSelected, false)
assertEqual(searchBar.selectedScopeButtonIndex, 0)
assertEqual(searchBar.showsScopeBar, false)
assertEqual(searchBar.backgroundImage, nil)
assertEqual(searchBar.scopeBarBackgroundImage, nil)

let slider = UISlider(frame: .zero)

assertEqual(slider.value, 0)
assertEqual(slider.minimumValue, 0)
assertEqual(slider.maximumValue, 1)
assertEqual(slider.isContinuous, true)
assertEqual(slider.minimumValueImage, nil)
assertEqual(slider.maximumValueImage, nil)
assertEqual(slider.minimumTrackTintColor, nil)
assertEqual(slider.currentMinimumTrackImage, nil)
assertEqual(slider.maximumTrackTintColor, nil)
assertEqual(slider.currentMaximumTrackImage, nil)
assertEqual(slider.thumbTintColor, nil)
assertEqual(slider.currentThumbImage, nil)

let stackView = UIStackView()

assertEqual(stackView.axis == .horizontal, true)
assertEqual(stackView.spacing, 0)
assertEqual(stackView.distribution == .fill, true)
assertEqual(stackView.alignment == .fill, true)
assertEqual(stackView.isBaselineRelativeArrangement, false)
assertEqual(stackView.isLayoutMarginsRelativeArrangement, false)

let s = UISwitch()

assertEqual(s.isOn, false)
assertEqual(s.onTintColor, nil)
assertEqual(s.thumbTintColor, nil)
assertEqual(s.onImage, nil)
assertEqual(s.offImage, nil)

let tabBar = UITabBar()

assertEqual(tabBar.isTranslucent, true)
assertEqual(tabBar.barStyle, .default)
assertEqual(tabBar.barTintColor, nil)
assertEqual(tabBar.itemSpacing, 0)
assertEqual(tabBar.itemWidth, 0)
assertEqual(tabBar.backgroundImage, nil)
assertEqual(tabBar.shadowImage, nil)
assertEqual(tabBar.selectionIndicatorImage, nil)

let layer = UIView().layer //CALayer()

assertEqual(layer.cornerRadius, 0)
assertEqual(layer.borderWidth, 0)
assertEqual(layer.borderColor, UIColor(red: 0, green: 0, blue: 0, alpha: 1).cgColor)
assertEqual(layer.opacity, 1)
assertEqual(layer.isHidden, false)
assertEqual(layer.masksToBounds, false)
assertEqual(layer.shadowOpacity, 0)
assertEqual(layer.shadowRadius, 3)
assertEqual(layer.shadowColor, UIColor(red: 0, green: 0, blue: 0, alpha: 1).cgColor)
assertEqual(layer.allowsEdgeAntialiasing, false)
assertEqual(layer.allowsGroupOpacity, true)
assertEqual(layer.isOpaque, true)
assertEqual(layer.shouldRasterize, false)
assertEqual(layer.rasterizationScale, 1)
assertEqual(layer.contentsFormat, .RGBA8Uint)
assertEqual(layer.contentsScale, 1)
assertEqual(layer.zPosition, 0)
assertEqual(layer.name, nil)
assertEqual(layer.contentsRect, CGRect(x: 0, y: 0, width: 1, height: 1))
assertEqual(layer.contentsCenter, CGRect(x: 0, y: 0, width: 1, height: 1))
assertEqual(layer.shadowOffset, CGSize(width: 0, height: -3))
assertEqual(layer.frame, .zero)
assertEqual(layer.bounds, .zero)
assertEqual(layer.position, .zero)
assertEqual(layer.anchorPoint, CGPoint(x: 0.5, y: 0.5))
assertEqual(layer.backgroundColor, nil)
assertEqual(layer.isDoubleSided, true)
assertEqual(layer.isGeometryFlipped, false)

let paragraphStyle = NSParagraphStyle()

paragraphStyle.alignment == .natural
paragraphStyle.firstLineHeadIndent
paragraphStyle.headIndent
paragraphStyle.tailIndent
paragraphStyle.tabStops
paragraphStyle.tabStops.forEach {
    print($0)
}
paragraphStyle.lineBreakMode == .byWordWrapping
paragraphStyle.maximumLineHeight
paragraphStyle.minimumLineHeight
paragraphStyle.lineHeightMultiple
paragraphStyle.lineSpacing
paragraphStyle.paragraphSpacing
paragraphStyle.paragraphSpacingBefore


(1...12).map { i in
    NSTextTab(textAlignment: .left, location: CGFloat(28 * i), options: [:])
}

let activityIndicator = UIActivityIndicatorView()

activityIndicator.color
activityIndicator.hidesWhenStopped
activityIndicator.style == .white

let control = UIControl(frame: .zero)

control.isEnabled
control.isSelected
control.isHighlighted
control.contentVerticalAlignment == .top
control.contentHorizontalAlignment == .center

let datePicker = UIDatePicker()

datePicker.minuteInterval
datePicker.datePickerMode == .dateAndTime

let tableView = UITableView()

tableView.rowHeight
tableView.separatorStyle
tableView.separatorColor
tableView.separatorEffect
print(tableView.separatorInset)
tableView.separatorInsetReference == .fromCellEdges
tableView.cellLayoutMarginsFollowReadableWidth
tableView.sectionHeaderHeight
tableView.sectionFooterHeight
tableView.estimatedRowHeight
tableView.estimatedSectionHeaderHeight
tableView.estimatedSectionFooterHeight
tableView.allowsSelection
tableView.allowsMultipleSelection
tableView.allowsSelectionDuringEditing
tableView.allowsMultipleSelectionDuringEditing
tableView.dragInteractionEnabled
tableView.isEditing
tableView.sectionIndexMinimumDisplayRowCount
tableView.sectionIndexColor
tableView.sectionIndexBackgroundColor
tableView.sectionIndexTrackingBackgroundColor
tableView.remembersLastFocusedIndexPath
tableView.insetsContentViewsToSafeArea

let textField = UITextField()

textField.text
textField.placeholder
textField.font
textField.textColor
textField.textAlignment == .natural
textField.adjustsFontSizeToFitWidth
textField.minimumFontSize
textField.clearsOnBeginEditing
textField.clearsOnInsertion
textField.allowsEditingTextAttributes
textField.background
textField.disabledBackground
textField.borderStyle == .none
textField.clearButtonMode == .never
textField.leftViewMode == .never
textField.rightViewMode == .never
//textField.contentEdgeInsets
//textField.placeholderColor
//textField.placeholderFont
textField.isSecureTextEntry
textField.keyboardType == .default
textField.keyboardAppearance == .default
textField.textContentType
textField.returnKeyType == .default
textField.enablesReturnKeyAutomatically
textField.autocapitalizationType == .sentences
textField.autocorrectionType == .default
textField.spellCheckingType == .default
textField.smartQuotesType == .default
textField.smartDashesType == .default
textField.smartInsertDeleteType == .default

let textView = UITextView()

textView.text
textView.font
textView.textColor
textView.textAlignment == .natural
print(textView.textContainerInset)
textView.allowsEditingTextAttributes

let toolbar = UIToolbar()

assertEqual(toolbar.isTranslucent, true)
assertEqual(toolbar.barStyle, .default)
assertEqual(toolbar.barTintColor, nil)

let view = UIView()

assertEqual(view.backgroundColor, nil)
assertEqual(view.clipsToBounds, false)
assertEqual(view.isUserInteractionEnabled, true)
assertEqual(view.tintColor, UIColor(red: 0, green: 122/255, blue: 1, alpha: 1))
assertEqual(view.isHidden, false)
assertEqual(view.alpha, 1)
assertEqual(view.isOpaque, true)
assertEqual(view.isMultipleTouchEnabled, false)
assertEqual(view.isExclusiveTouch, false)
assertEqual(view.autoresizesSubviews, true)
assertEqual(view.contentMode, .scaleToFill)
assertEqual(view.translatesAutoresizingMaskIntoConstraints, true)
assertEqual(view.preservesSuperviewLayoutMargins, false)
assertEqual(view.tag, 0)
assertEqual(view.canBecomeFocused, false)
//assertEqual(view.visibility, )
//assertEqual(view.collapseAxis, )
assertEqual(view.frame, .zero)
assertEqual(view.bounds, .zero)
assertEqual(view.layoutMargins, UIEdgeInsets(top: 8, left: 8, bottom: 8, right: 8))

assertEqual(view.transform, .identity)

let visualEffectView = UIVisualEffectView()

assertEqual(visualEffectView.effect, nil)

let c = WKWebViewConfiguration()

let webView = WKWebView(frame: .zero)

//webView.allowsMagnification
//webView.magnification
//webView.allows
assertEqual(webView.allowsBackForwardNavigationGestures, false)





























































































