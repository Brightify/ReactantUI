//
//  StyleGenerator.swift
//  Reactant
//
//  Created by Matouš Hýbl on 17/04/2017.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation
import Tokenizer

public class StyleGenerator: Generator {

    private let group: StyleGroup
    private var tempCounter: Int = 1

    public init(group: StyleGroup, configuration: GeneratorConfiguration) {
        self.group = group
        super.init(configuration: configuration)
    }

    public override func generate(imports: Bool) throws -> String {
        if imports {
            l("""
              import UIKit
              import Reactant
              import SnapKit
              """)
            if configuration.isLiveEnabled {
                l(ifSimulator("import ReactantLiveUI"))
            }
        }
        let styleImports = Set(group.styles.map { $0.parentModuleImport })
        for styleImport in styleImports {
            l("import \(styleImport)")
        }
        l()
        try l("struct \(group.swiftName)") {
            for style in group.styles {
                guard let mapping = ElementMapping.mapping[style.type] else {
                    throw GeneratorError(message: "Mapping for type \(style.type) does not exist")
                }
                l("static func \(style.styleName)(_ view: \(try mapping.runtimeType()))") {
                    for extendedStyle in style.extend {
                        let components = extendedStyle.components(separatedBy: ":").filter { !$0.isEmpty }
                        if let styleName = components.last {
                            if let groupName = components.first, components.count > 1 {
                                l("\(groupName.capitalizingFirstLetter() + "Styles").\(styleName)(view)")
                            } else {
                                l("\(group.swiftName).\(styleName)(view)")
                            }
                        } else {
                            continue
                        }
                    }
                    for property in style.properties {
                        l(property.application(on: "view"))
                    }
                }
            }
        }

        return output
    }
}
