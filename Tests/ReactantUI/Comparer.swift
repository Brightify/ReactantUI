//
//  Comparer.swift
//  LiveUI-iOSTests
//
//  Created by Matyáš Kříž on 14/06/2018.
//

import UIKit

struct Comparer {
    static func fastCompare(lhs: UIImage, rhs: UIImage) throws -> Bool {
        guard lhs.size == rhs.size else { return false }

        let lhsPixelData = try lhs.drawIntoPointer()
        let rhsPixelData = try rhs.drawIntoPointer()

        let squareScale = Int(UIScreen.main.scale * UIScreen.main.scale)
        return memcmp(lhsPixelData, rhsPixelData, squareScale * Int(lhs.size.width * lhs.size.height)) == 0
    }

    /// returns the percentage of similarity
    static func compare(lhs: UIImage, rhs: UIImage) throws -> Double {
        guard lhs.size == rhs.size else { return 0 }

        let lhsPixelData = try lhs.drawIntoPointer()
        let rhsPixelData = try rhs.drawIntoPointer()

        let squareScale = Int(UIScreen.main.scale * UIScreen.main.scale)
        let pixelCount = squareScale * Int(lhs.size.width * lhs.size.height)
        var pixelDiffCount = 0
        for index in 0..<pixelCount {
            pixelDiffCount += lhsPixelData.advanced(by: index).assumingMemoryBound(to: UInt8.self).pointee == rhsPixelData.advanced(by: index).assumingMemoryBound(to: UInt8.self).pointee ? 0 : 1
        }

        // before we start, similarity is 100%, we subtract the differency percentage from this
        return 1 - Double(pixelDiffCount) / Double(pixelCount)
    }
}
