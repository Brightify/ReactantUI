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

    private let context: StyleGroupContext
    private let group: StyleGroup
    private var tempCounter: Int = 1

    public init(context: StyleGroupContext, configuration: GeneratorConfiguration) {
        self.group = context.group
        self.context = context
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
                guard let mapping = ElementMapping.mapping[style.type.styleType] else {
                    throw GeneratorError(message: "Mapping for type \(style.type.styleType) does not exist")
                }
                l("static func \(style.name.name)(_ view: \(try mapping.runtimeType()))") {
                    for extendedStyle in style.extend {
                        switch extendedStyle {
                        case .local(let name):
                            l("\(group.swiftName).\(name)(view)")
                        case .global(let group, let name):
                            l("\(group.capitalizingFirstLetter() + "Styles").\(name)(view)")
                        }
                    }
                    for property in style.properties {
                        let propertyContext = PropertyContext(parentContext: context, property: property)
                        l(property.application(on: "view", context: propertyContext))
                    }
                }
            }
        }

        return output
    }
}
