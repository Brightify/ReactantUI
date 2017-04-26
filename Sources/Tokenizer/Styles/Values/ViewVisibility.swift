//
//  ViewVisibility.swift
//  Pods
//
//  Created by Matouš Hýbl on 26/04/2017.
//
//

import Foundation

public enum ViewVisibility: String {
    case visible
    case hidden
    case collapsed
}

public enum ViewCollapseAxis: String {
    case horizontal
    case vertical
    case both
}

#if ReactantRuntime
    extension ViewVisibility: Appliable {

        public var value: Any? {
            switch self {
            case .visible:
                return Visibility.visible.rawValue
            case .collapsed:
                return Visibility.collapsed.rawValue
            case .hidden:
                return Visibility.hidden.rawValue
            }
        }
    }
#endif

#if ReactantRuntime
    extension ViewCollapseAxis: Appliable {

        public var value: Any? {
            switch self {
            case .both:
                return CollapseAxis.both.rawValue
            case .horizontal:
                return CollapseAxis.horizontal.rawValue
            case .vertical:
                return CollapseAxis.vertical.rawValue
            }
        }
    }
#endif
