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

    public init(group: StyleGroup, localXmlPath: String, isLiveEnabled: Bool) {
        self.group = group
        super.init(localXmlPath: localXmlPath, isLiveEnabled: isLiveEnabled)
    }

    public override func generate(imports: Bool) {
        if imports {
            l("import UIKit")
            l("import Reactant")
            l("import SnapKit")
            if isLiveEnabled {
                l("#if (arch(i386) || arch(x86_64)) && (os(iOS) || os(tvOS))")
                l("import ReactantLiveUI")
                l("#endif")
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
    }
}
