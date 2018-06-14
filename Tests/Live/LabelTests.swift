//
//  LiveUI_iOSTests.swift
//  LiveUI-iOSTests
//
//  Created by Tadeas Kriz on 26/04/2018.
//

import XCTest
import UIKit
@testable import ReactantLiveUI

class LabelTests: XCTestCase {
    let standardTestSizes = [10, 50, 100, 150, 250, 500, 1000]
        .map { CGSize($0) }

    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testLabelText() {
        let source = """
        <Label text="nice" />
        """
        let expectedView = UILabel().where {
            $0.text = "nice"
        }

        assertEqual(xml: source, view: expectedView, testAtSizes: standardTestSizes)
    }

    func testLabelTextColorStandard() {
        let source = """
        <Label text="nice" textColor="brown" />
        """
        let expectedView = UILabel().where {
            $0.text = "nice"
            $0.textColor = UIColor.brown
        }

        assertEqual(xml: source, view: expectedView, testAtSizes: standardTestSizes)
    }

    func testLabelTextColorCustom() {
        let source = """
        <Label text="nice" textColor="#d800ff" />
        """
        let expectedView = UILabel().where {
            $0.text = "nice"
            $0.textColor = UIColor(rgb: 0xd800ff)
        }

        assertEqual(xml: source, view: expectedView, testAtSizes: standardTestSizes)
    }
}
