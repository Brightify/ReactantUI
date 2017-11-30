//
//  OptionSetValue.swift
//  ReactantUI
//
//  Created by Tadeas Kriz.
//  Copyright © 2017 Brightify. All rights reserved.
//

protocol OptionSetValue {
    associatedtype Value: OptionSet

    var value: Value { get }
}

extension Sequence where Iterator.Element: OptionSetValue {
    func resolveUnion() -> Iterator.Element.Value {
        return reduce([] as Iterator.Element.Value) {
            $0.union($1.value)
        }
    }
}
