//
//  VisualEffect.swift
//  ReactantUI
//
//  Created by Tadeas Kriz.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

public enum VisualEffect: SupportedPropertyType {
    case blur(BlurEffect)
    case vibrancy(BlurEffect)

    public var generated: String {
        switch self {
        case .blur(let effect):
            return "UIBlurEffect(style: .\(effect.rawValue))"
        case .vibrancy(let effect):
            return "UIVibrancyEffect(blurEffect: .\(effect.rawValue))"
        }
    }
    
    #if SanAndreas
    public func dematerialize() -> String {
        switch self {
        case .blur(let effect):
            return effect.rawValue
        case .vibrancy(let effect):
            return effect.rawValue
        }
    }
    #endif

    #if ReactantRuntime
    public var runtimeValue: Any? {
        switch self {
        case .blur(let effect):
            return effect.runtimeValue
        case .vibrancy(let effect):
            guard let blurEffect = effect.runtimeValue as? UIBlurEffect else { return nil }
            return UIVibrancyEffect(blurEffect: blurEffect)
        }
    }
    #endif

    public static func materialize(from value: String) throws -> VisualEffect {
        let parts = value.components(separatedBy: ":")
        guard parts.count == 2 && (parts.first == "blur" || parts.first == "vibrancy") else {
            throw PropertyMaterializationError.unknownValue(value)
        }
        guard let effect = BlurEffect(rawValue: parts[1]) else {
            throw PropertyMaterializationError.unknownValue(value)
        }
        return parts.first == "blur" ? .blur(effect) : .vibrancy(effect)
    }
}

public enum BlurEffect: String {
    case extraLight
    case light
    case dark
    case prominent
    case regular
}

#if ReactantRuntime
    import UIKit

    extension BlurEffect {

        public var runtimeValue: Any? {
            switch self {
            case .extraLight:
                return UIBlurEffect(style: .extraLight)
            case .light:
                return UIBlurEffect(style: .light)
            case .dark:
                return UIBlurEffect(style: .dark)
            case .prominent:
                if #available(iOS 10.0, tvOS 10.0, *) {
                    return UIBlurEffect(style: .prominent)
                } else {
                    // FIXME check default values
                    return UIBlurEffect(style: .light)
                }
            case .regular:
                if #available(iOS 10.0, tvOS 10.0, *) {
                    return UIBlurEffect(style: .regular)
                } else {
                    return UIBlurEffect(style: .light)
                }
            }
        }
    }
#endif
