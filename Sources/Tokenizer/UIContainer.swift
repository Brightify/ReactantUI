//
//  UIContainer.swift
//  ReactantUI
//
//  Created by Tadeas Kriz.
//  Copyright © 2017 Brightify. All rights reserved.
//

public protocol UIContainer {
    var children: [UIElement] { get set }

    var addSubviewMethod: String { get }

    #if ReactantRuntime
    func add(subview: UIView, toInstanceOfSelf: UIView)
    #endif
}
