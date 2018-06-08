//
//  UIContainer.swift
//  ReactantUI
//
//  Created by Tadeas Kriz.
//  Copyright © 2017 Brightify. All rights reserved.
//

#if canImport(UIKit)
    import UIKit
#endif

public protocol UIContainer {
    var children: [UIElement] { get set }

    var addSubviewMethod: String { get }

    #if canImport(UIKit)
    func add(subview: UIView, toInstanceOfSelf: UIView)
    #endif
}
