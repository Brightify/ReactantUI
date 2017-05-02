public protocol UIContainer {
    var children: [UIElement] { get }

    var addSubviewMethod: String { get }

    #if ReactantRuntime
    func add(subview: UIView, toInstanceOfSelf: UIView)
    #endif
}
