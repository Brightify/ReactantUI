//
//  UIView+traits.swift
//  ReactantUI
//
//  Created by Tadeáš Kříž on 04/05/2018.
//

import Foundation
import UIKit

public extension UIView {
    public var traits: UITraitHelper {
        return UITraitHelper(for: self)
    }
}
