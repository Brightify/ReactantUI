//
//  NSShadow+convenienceInit.swift
//  LiveUI-iOS
//
//  Created by Matyáš Kříž on 05/06/2018.
//

import UIKit

extension NSShadow {
    public convenience init(offset: CGSize?, blurRadius: CGFloat, color: UIColor?) {
        self.init()
        if let offset = offset {
            self.shadowOffset = offset
        }
        self.shadowBlurRadius = blurRadius
        if let color = color {
            self.shadowColor = color
        }
    }
}
