//
//  ComponentPath.swift
//  ReactantUI
//
//  Created by Matouš Hýbl on 28/04/2017.
//  Copyright © 2017 Brightify. All rights reserved.
//

import Foundation

public func componentType(from path: String) -> String {
    let fileName = (path as NSString).lastPathComponent
    let suffix = ".ui.xml"
    guard fileName.hasSuffix(suffix) else { return fileName }
    return String(fileName.characters.dropLast(suffix.characters.count))
}
