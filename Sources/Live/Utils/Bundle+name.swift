//
//  Bundle+name.swift
//  ReactantUI
//
//  Created by Matyáš Kříž on 30/07/2018.
//

import Foundation

internal extension Bundle {
    var name: String? {
        return infoDictionary?["CFBundleName"] as? String
    }
    var displayName: String? {
        return infoDictionary?["CFBundleDisplayName"] as? String
    }
}
