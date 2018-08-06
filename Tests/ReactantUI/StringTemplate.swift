//
//  StringTemplate.swift
//  LiveUI-iOSTests
//
//  Created by Matyáš Kříž on 06/08/2018.
//  Copyright © 2018 Brightify. All rights reserved.
//

import Foundation

/**
 * Helper class for testing Reactant UI by giving it an XML template along with the wildcard (what should be replaced in the template).
 */
struct StringTemplate {
    private let template: String
    private let wildcard: String

    init(template: String, wildcard: String) {
        self.template = template
        self.wildcard = wildcard
    }

    func fill(_ replacement: String) -> String {
        return template.replacingOccurrences(of: wildcard, with: replacement)
    }
}
