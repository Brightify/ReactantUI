//
//  GlobalContext.swift
//  Tokenizer
//
//  Created by Tadeas Kriz on 01/06/2018.
//

import Foundation

#if canImport(Reactant)
import Reactant
#else
extension Dictionary {
    public init(keyValueTuples: [(Key, Value)]) {
        var result: [Key: Value] = [:]
        for item in keyValueTuples {
            result[item.0] = item.1
        }
        self = result
    }
}
#endif

public struct GlobalContext: DataContext {
    private let styles: StyleSheets
//    public let fonts: [String]
//    public let colors: [UIColor]

    private typealias StyleSheets = [String: [String: Style]]

    public init(styleSheetDictionary: [String: StyleGroup]) {
        styles = Dictionary(keyValueTuples: styleSheetDictionary.map { arg in
            let (key, value) = arg
            return (key, Dictionary(keyValueTuples: value.styles.map { ($0.name.name, $0) }))
        })
    }

    public init(styleSheets: [StyleGroup]) {
        let groups = (styleSheets
            .flatMap { $0.styles }
            .groupBy { style -> String? in
                guard case .global(let groupName, _) = style.name else { return nil }
                return groupName
            } as [(name: String, styles: [Style])])
            .map { ($0.name, Dictionary(keyValueTuples: $0.styles.map { ($0.name.name, $0) })) }

        styles = Dictionary(keyValueTuples: groups)
    }

    public func resolvedStyleName(named styleName: StyleName) -> String {
        guard case .global(let groupName, let name) = styleName else {
            fatalError("Global context cannot resolve local style name \(styleName.name).")
        }
        return "\(groupName.capitalizingFirstLetter())Styles.\(name)"
    }

    public func style(named styleName: StyleName) -> Style? {
        guard case .global(let groupName, let name) = styleName else { return nil }
        return styles[groupName]?[name]
    }
}
