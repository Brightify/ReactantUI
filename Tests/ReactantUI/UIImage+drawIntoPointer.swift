//
//  UIImage+drawIntoPointer.swift
//  LiveUI-iOSTests
//
//  Created by Matyáš Kříž on 14/06/2018.
//

import UIKit

extension UIImage {
    func drawIntoPointer() throws -> UnsafeMutableRawPointer {
        guard let cgImage = cgImage else {
            throw SnapshotError.noCgImage(self)
        }

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)


        let bytes = cgImage.height * cgImage.bytesPerRow
        guard let pointer = UnsafeMutableRawPointer(calloc(1, bytes)) else { throw SnapshotError.noPointer(self) }

        guard let context = CGContext(data: pointer,
                                      width: Int(size.width),
                                      height: Int(size.height),
                                      bitsPerComponent: 8,
                                      bytesPerRow: cgImage.bytesPerRow,
                                      space: colorSpace,
                                      bitmapInfo: bitmapInfo.rawValue)
            else {
                throw SnapshotError.noContext(self)
        }

        context.draw(cgImage, in: CGRect(size: size))

        return pointer
    }
}
