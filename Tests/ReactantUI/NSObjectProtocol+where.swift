//
//  NSObjectProtocol+where.swift
//  ReactantUI
//
//  Created by Matyáš Kříž on 12/06/2018.
//

import UIKit

extension NSObjectProtocol {
    func `where`(setup: (Self) -> Void) -> Self {
        setup(self)
        return self
    }
}
