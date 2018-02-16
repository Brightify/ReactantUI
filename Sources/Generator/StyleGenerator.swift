//
//  StyleGenerator.swift
//  Reactant
//
//  Created by Matouš Hýbl on 17/04/2017.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Tokenizer

public class StyleGenerator: Generator {

    private let group: StyleGroup
    private var tempCounter: Int = 1

    public init(group: StyleGroup, configuration: GeneratorConfiguration) {
        self.group = group
        super.init(configuration: configuration)
    }

    public override func generate(imports: Bool) -> String {
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
        l()
        l("struct \(group.swiftName)") {
            for style in group.styles {
                l("static func \(style.styleName)(_ view: \(Element.elementMapping[style.type]?.runtimeType ?? "UIView"))") {
                    for extendedStyle in style.extend {
                        guard let styleName = extendedStyle.components(separatedBy: ":").last else {
                            continue
                        }
                        l("\(group.swiftName).\(styleName)(view)")
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
