//
//  EdgeInsets.swift
//  LiveUI-iOSTests
//
//  Created by Matyáš Kříž on 05/09/2018.
//  Copyright © 2018 Brightify. All rights reserved.
//

import Foundation
import XCTest
@testable import ReactantLiveUI

class EdgeInsetsTests: XCTestCase {
    func testTop() throws {
        for number in stride(from: -10.0 as Float, to: 10.0, by: 1) {
            let edgeInsets = try EdgeInsets.materialize(from: "top: \(number)")
            XCTAssertEqual(edgeInsets.top, number)
            XCTAssertEqual(edgeInsets.left, 0)
            XCTAssertEqual(edgeInsets.bottom, 0)
            XCTAssertEqual(edgeInsets.right, 0)
        }
    }

    func testLeft() throws {
        for number in stride(from: -10.0 as Float, to: 10.0, by: 1) {
            let edgeInsets = try EdgeInsets.materialize(from: "left: \(number)")
            XCTAssertEqual(edgeInsets.left, number)
            XCTAssertEqual(edgeInsets.bottom, 0)
            XCTAssertEqual(edgeInsets.right, 0)
            XCTAssertEqual(edgeInsets.top, 0)
        }
    }

    func testBottom() throws {
        for number in stride(from: -10.0 as Float, to: 10.0, by: 1) {
            let edgeInsets = try EdgeInsets.materialize(from: "bottom: \(number)")
            XCTAssertEqual(edgeInsets.bottom, number)
            XCTAssertEqual(edgeInsets.right, 0)
            XCTAssertEqual(edgeInsets.top, 0)
            XCTAssertEqual(edgeInsets.left, 0)
        }
    }

    func testRight() throws {
        for number in stride(from: -10.0 as Float, to: 10.0, by: 1) {
            let edgeInsets = try EdgeInsets.materialize(from: "right: \(number)")
            XCTAssertEqual(edgeInsets.right, number)
            XCTAssertEqual(edgeInsets.top, 0)
            XCTAssertEqual(edgeInsets.left, 0)
            XCTAssertEqual(edgeInsets.bottom, 0)
        }
    }

    func testHorizontal() throws {
        for number in stride(from: -10.0 as Float, to: 10.0, by: 1) {
            let edgeInsets = try EdgeInsets.materialize(from: "horizontal: \(number)")
            XCTAssertEqual(edgeInsets.left, number)
            XCTAssertEqual(edgeInsets.right, number)
            XCTAssertEqual(edgeInsets.top, 0)
            XCTAssertEqual(edgeInsets.bottom, 0)
        }
    }

    func testVertical() throws {
        for number in stride(from: -10.0 as Float, to: 10.0, by: 1) {
            let edgeInsets = try EdgeInsets.materialize(from: "vertical: \(number)")
            XCTAssertEqual(edgeInsets.top, number)
            XCTAssertEqual(edgeInsets.bottom, number)
            XCTAssertEqual(edgeInsets.left, 0)
            XCTAssertEqual(edgeInsets.right, 0)
        }
    }

    func testAll() throws {
        for number in stride(from: -10.0 as Float, to: 10.0, by: 1) {
            let edgeInsets = try EdgeInsets.materialize(from: "all: \(number)")
            XCTAssertEqual(edgeInsets.top, number)
            XCTAssertEqual(edgeInsets.left, number)
            XCTAssertEqual(edgeInsets.bottom, number)
            XCTAssertEqual(edgeInsets.right, number)
        }
    }

    func testAllNoLabel() throws {
        for number in stride(from: -10.0 as Float, to: 10.0, by: 1) {
            let edgeInsets = try EdgeInsets.materialize(from: "\(number)")
            XCTAssertEqual(edgeInsets.top, number)
            XCTAssertEqual(edgeInsets.left, number)
            XCTAssertEqual(edgeInsets.bottom, number)
            XCTAssertEqual(edgeInsets.right, number)
        }
    }

    func testHorizontalVerticalNoLabel() throws {
        for number in stride(from: -10.0 as Float, to: 10.0, by: 1) {
            let edgeInsets = try EdgeInsets.materialize(from: "\(number), \(number / 2)")
            XCTAssertEqual(edgeInsets.top, number / 2)
            XCTAssertEqual(edgeInsets.left, number)
            XCTAssertEqual(edgeInsets.bottom, number / 2)
            XCTAssertEqual(edgeInsets.right, number)
        }
    }

    func testAllSidesNoLabel() throws {
        for number in stride(from: -10.0 as Float, to: 10.0, by: 1) {
            let edgeInsets = try EdgeInsets.materialize(from: "\(number), \(number / 2), \(number / 4), \(number / 8)")
            XCTAssertEqual(edgeInsets.top, number)
            XCTAssertEqual(edgeInsets.left, number / 2)
            XCTAssertEqual(edgeInsets.bottom, number / 4)
            XCTAssertEqual(edgeInsets.right, number / 8)
        }
    }

    func testAllSides() throws {
        for number in stride(from: -10.0 as Float, to: 10.0, by: 1) {
            let edgeInsets = try EdgeInsets.materialize(from: "top: \(number), left: \(number / 2), bottom: \(number / 4), right: \(number / 8)")
            XCTAssertEqual(edgeInsets.top, number)
            XCTAssertEqual(edgeInsets.left, number / 2)
            XCTAssertEqual(edgeInsets.bottom, number / 4)
            XCTAssertEqual(edgeInsets.right, number / 8)
        }
    }

    func testAllSidesDifferentPositioning() throws {
        for number in stride(from: -10.0 as Float, to: 10.0, by: 1) {
            let edgeInsets = try EdgeInsets.materialize(from: "bottom: \(number), left: \(number / 2), right: \(number / 4), top: \(number / 8)")
            XCTAssertEqual(edgeInsets.top, number / 8)
            XCTAssertEqual(edgeInsets.left, number / 2)
            XCTAssertEqual(edgeInsets.bottom, number)
            XCTAssertEqual(edgeInsets.right, number / 4)
        }
    }

    func testThreeSides() throws {
        for number in stride(from: -10.0 as Float, to: 10.0, by: 1) {
            let edgeInsets = try EdgeInsets.materialize(from: "bottom: \(number), left: \(number / 2), right: \(number / 4)")
            XCTAssertEqual(edgeInsets.top, 0)
            XCTAssertEqual(edgeInsets.left, number / 2)
            XCTAssertEqual(edgeInsets.bottom, number)
            XCTAssertEqual(edgeInsets.right, number / 4)
        }
    }

    func testTwoSides() throws {
        for number in stride(from: -10.0 as Float, to: 10.0, by: 1) {
            let edgeInsets = try EdgeInsets.materialize(from: "bottom: \(number), right: \(number / 4)")
            XCTAssertEqual(edgeInsets.top, 0)
            XCTAssertEqual(edgeInsets.left, 0)
            XCTAssertEqual(edgeInsets.bottom, number)
            XCTAssertEqual(edgeInsets.right, number / 4)
        }

        for number in stride(from: -10.0 as Float, to: 10.0, by: 1) {
            let edgeInsets = try EdgeInsets.materialize(from: "left: \(number / 2), right: \(number / 4)")
            XCTAssertEqual(edgeInsets.top, 0)
            XCTAssertEqual(edgeInsets.left, number / 2)
            XCTAssertEqual(edgeInsets.bottom, 0)
            XCTAssertEqual(edgeInsets.right, number / 4)
        }
    }

    func testOneSideAndOneDimension() throws {
        for number in stride(from: -10.0 as Float, to: 10.0, by: 1) {
            let edgeInsets = try EdgeInsets.materialize(from: "bottom: \(number), horizontal: \(number / 2)")
            XCTAssertEqual(edgeInsets.top, 0)
            XCTAssertEqual(edgeInsets.left, number / 2)
            XCTAssertEqual(edgeInsets.bottom, number)
            XCTAssertEqual(edgeInsets.right, number / 2)
        }

        for number in stride(from: -10.0 as Float, to: 10.0, by: 1) {
            let edgeInsets = try EdgeInsets.materialize(from: "right: \(number), vertical: \(number / 2)")
            XCTAssertEqual(edgeInsets.top, number / 2)
            XCTAssertEqual(edgeInsets.left, 0)
            XCTAssertEqual(edgeInsets.bottom, number / 2)
            XCTAssertEqual(edgeInsets.right, number)
        }
    }

    func testTwoSidesAndOneDimension() throws {
        for number in stride(from: -10.0 as Float, to: 10.0, by: 1) {
            let edgeInsets = try EdgeInsets.materialize(from: "right: \(number), vertical: \(number / 2), left: \(number / 4)")
            XCTAssertEqual(edgeInsets.top, number / 2)
            XCTAssertEqual(edgeInsets.left, number / 4)
            XCTAssertEqual(edgeInsets.bottom, number / 2)
            XCTAssertEqual(edgeInsets.right, number)
        }

        for number in stride(from: -10.0 as Float, to: 10.0, by: 1) {
            let edgeInsets = try EdgeInsets.materialize(from: "bottom: \(number), top: \(number / 2), horizontal: \(number / 4)")
            XCTAssertEqual(edgeInsets.top, number / 2)
            XCTAssertEqual(edgeInsets.left, number / 4)
            XCTAssertEqual(edgeInsets.bottom, number)
            XCTAssertEqual(edgeInsets.right, number / 4)
        }
    }

    func testTwoDimensions() throws {
        for number in stride(from: -10.0 as Float, to: 10.0, by: 1) {
            let edgeInsets = try EdgeInsets.materialize(from: "vertical: \(number), horizontal: \(number / 2)")
            XCTAssertEqual(edgeInsets.top, number)
            XCTAssertEqual(edgeInsets.left, number / 2)
            XCTAssertEqual(edgeInsets.bottom, number)
            XCTAssertEqual(edgeInsets.right, number / 2)
        }
    }

    // MARK:- Failure scenario tests
    func testMultipleTop() throws {
        for number in stride(from: -10.0 as Float, to: 10.0, by: 1) {
            XCTAssertThrowsError {
                _ = try EdgeInsets.materialize(from: "top: \(number), top: \(number / 2)")
            }
        }

        for number in stride(from: -10.0 as Float, to: 10.0, by: 1) {
            XCTAssertThrowsError {
                _ = try EdgeInsets.materialize(from: "top: \(number), vertical: \(number / 2)")
            }
        }

        for number in stride(from: -10.0 as Float, to: 10.0, by: 1) {
            XCTAssertThrowsError {
                _ = try EdgeInsets.materialize(from: "all: \(number), top: \(number / 2)")
            }
        }
    }

    func testMultipleLeft() throws {
        for number in stride(from: -10.0 as Float, to: 10.0, by: 1) {
            XCTAssertThrowsError {
                _ = try EdgeInsets.materialize(from: "left: \(number), left: \(number / 2)")
            }
        }

        for number in stride(from: -10.0 as Float, to: 10.0, by: 1) {
            XCTAssertThrowsError {
                _ = try EdgeInsets.materialize(from: "left: \(number), horizontal: \(number / 2)")
            }
        }

        for number in stride(from: -10.0 as Float, to: 10.0, by: 1) {
            XCTAssertThrowsError {
                _ = try EdgeInsets.materialize(from: "all: \(number), left: \(number / 2)")
            }
        }
    }

    func testMultipleBottom() throws {
        for number in stride(from: -10.0 as Float, to: 10.0, by: 1) {
            XCTAssertThrowsError {
                _ = try EdgeInsets.materialize(from: "bottom: \(number), bottom: \(number / 2)")
            }
        }

        for number in stride(from: -10.0 as Float, to: 10.0, by: 1) {
            XCTAssertThrowsError {
                _ = try EdgeInsets.materialize(from: "bottom: \(number), vertical: \(number / 2)")
            }
        }

        for number in stride(from: -10.0 as Float, to: 10.0, by: 1) {
            XCTAssertThrowsError {
                _ = try EdgeInsets.materialize(from: "all: \(number), bottom: \(number / 2)")
            }
        }
    }

    func testMultipleRight() throws {
        for number in stride(from: -10.0 as Float, to: 10.0, by: 1) {
            XCTAssertThrowsError {
                _ = try EdgeInsets.materialize(from: "right: \(number), right: \(number / 2)")
            }
        }

        for number in stride(from: -10.0 as Float, to: 10.0, by: 1) {
            XCTAssertThrowsError {
                _ = try EdgeInsets.materialize(from: "right: \(number), horizontal: \(number / 2)")
            }
        }

        for number in stride(from: -10.0 as Float, to: 10.0, by: 1) {
            XCTAssertThrowsError {
                _ = try EdgeInsets.materialize(from: "right: \(number / 2), all: \(number)")
            }
        }
    }
}
