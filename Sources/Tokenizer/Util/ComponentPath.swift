//
//  ComponentPath.swift
//  Pods
//
//  Created by Matouš Hýbl on 28/04/2017.
//
//

import Foundation

public func componentType(from path: String) -> String {
    let fileName = (path as NSString).lastPathComponent
    let suffix = ".ui.xml"
    guard fileName.hasSuffix(suffix) else { return fileName }
    return String(fileName.characters.dropLast(suffix.characters.count))
}
