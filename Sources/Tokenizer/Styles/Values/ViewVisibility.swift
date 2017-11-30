//
//  ViewVisibility.swift
//  ReactantUI
//
//  Created by Matouš Hýbl on 26/04/2017.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

public enum ViewVisibility: String, EnumPropertyType {
    public static let enumName = "Visibility"

    case visible
    case hidden
    case collapsed
}

public enum ViewCollapseAxis: String, EnumPropertyType {
    public static let enumName = "CollapseAxis"

    case horizontal
    case vertical
    case both
}

#if ReactantRuntime
    import Reactant

    extension ViewVisibility {

        public var runtimeValue: Any? {
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

    extension ViewCollapseAxis {

        public var runtimeValue: Any? {
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
