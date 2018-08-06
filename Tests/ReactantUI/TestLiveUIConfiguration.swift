//
//  TestLiveUIConfiguration.swift
//  LiveUI-iOSTests
//
//  Created by Matyáš Kříž on 06/08/2018.
//

import ReactantLiveUI
import UIKit

struct TestLiveUIConfiguration: ReactantLiveUIConfiguration {
    var applicationDescriptionPath: String? = ProcessInfo.processInfo.environment["applicationDescriptionPath"]
    var rootDir = ProcessInfo.processInfo.environment["rootDir"] ?? ""
    var resourceBundle = Bundle()
    var commonStylePaths: [String] = [
        ProcessInfo.processInfo.environment["commonStylesPath"]
        ].compactMap { $0 }
    var componentTypes: [String: UIView.Type] = [:]
}
