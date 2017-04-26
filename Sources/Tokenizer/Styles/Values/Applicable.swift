//
//  Applicable.swift
//  Pods
//
//  Created by Matouš Hýbl on 26/04/2017.
//
//

import Foundation

public protocol Applicable {

    associatedtype ValueType
    var value: ValueType { get }
}
