//
//  ReactantLiveUIConfiguration.swift
//  ReactantUI
//
//  Created by Tadeas Kriz on 4/25/17.
//  Copyright © 2017 Brightify. All rights reserved.
//

import UIKit

public protocol ReactantLiveUIConfiguration {
    var rootDir: String { get }
    var componentTypes: [String: UIView.Type] { get }
    var commonStylePaths: [String] { get }
}
