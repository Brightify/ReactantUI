//
//  UIButton+BackgroundColor.swift
//  ReactantUI
//
//  Created by Tadeas Kriz on 02/06/2019.
//

import UIKit

extension UIButton {

    @objc(setBackgroundColor:forState:)
    public func setBackgroundColor(_ color: UIColor, for state: UIControl.State) {
        let rectangle = CGRect(origin: CGPoint.zero, size: CGSize(width: 1, height: 1))
        UIGraphicsBeginImageContext(rectangle.size)

        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(rectangle)

        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        setBackgroundImage(image!, for: state)
    }
}
