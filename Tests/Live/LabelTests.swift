//
//  LiveUI_iOSTests.swift
//  LiveUI-iOSTests
//
//  Created by Tadeas Kriz on 26/04/2018.
//

import XCTest
import UIKit
import Hyperdrive
@testable import ReactantLiveUI

class LabelTests: XCTestCase {
    let standardTestSizes = [10, 50, 100, 150, 250, 500, 1000]
        .map { CGSize($0) }

    let componentTwoStylesTemplate = StringTemplate(
        template: """
    <Component type="aType">
        <styles name="ReactantStyles">
            <attributedTextStyle name="style1">
                <b font=":bold@20" />
            </attributedTextStyle>
            <attributedTextStyle name="style2">
                <i font="20" />
            </attributedTextStyle>
        </styles>

        #{}
    </Component>
    """, wildcard: "#{}")

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

    // MARK:- Text Colors
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

    // MARK:- Attributed Text
    func testLabelAttributedTextFont1() {
        let source = """
        <Label>
        <attributedText>
            <style font="20">fontko</style>
        </attributedText>
        </Label>
        """
        let expectedView = UILabel().where {
            $0.attributedText = "fontko".attributed(.font(UIFont.System.regular.font(size: 20)))
        }

        assertEqual(xml: source, view: expectedView, testAtSizes: standardTestSizes)
    }

    func testLabelAttributedTextFont2() {
        let source = """
        <Label>
        <attributedText>
            <style font=":bold@20">boldko</style>
        </attributedText>
        </Label>
        """
        let expectedView = UILabel().where {
            $0.attributedText = "boldko".attributed(.font(UIFont.System.bold.font(size: 20)))
        }

        assertEqual(xml: source, view: expectedView, testAtSizes: standardTestSizes)
    }

    func testLabelAttributedTextFont3() {
        let source = """
        <Label>
        <attributedText>
            normalko
        </attributedText>
        </Label>
        """
        let expectedView = UILabel().where {
            $0.attributedText = "normalko".attributed()
        }

        assertEqual(xml: source, view: expectedView, testAtSizes: standardTestSizes)
    }

    func testLabelAttributedTextFont4() {
        let source = """
        <Label>
        <attributedText>
            normalko <style font=":bold@20">boldko</style>
        </attributedText>
        </Label>
        """
        let expectedView = UILabel().where {
            $0.attributedText = "normalko ".attributed() + "boldko".attributed(.font(UIFont.System.bold.font(size: 20)))
        }

        assertEqual(xml: source, view: expectedView, testAtSizes: standardTestSizes)
    }

    func testLabelAttributedTextFont5() {
        let source = """
        <Label>
        <attributedText font=":light@25">
            all styled up <style font=":bold@20">boldko</style>
        </attributedText>
        </Label>
        """
        let expectedView = UILabel().where {
            $0.attributedText = "all styled up ".attributed(.font(UIFont.System.light.font(size: 25))) +
                "boldko".attributed(.font(UIFont.System.bold.font(size: 20)))
        }

        assertEqual(xml: source, view: expectedView, testAtSizes: standardTestSizes)
    }

    // MARK:- Local Styles
    func testLabelAttributedTextLocalStyles1() {
        let source = """
        <Label layout:edges="super">
        <attributedText style="style1">
            <b>boldko</b>
        </attributedText>
        </Label>
        """
        let expectedView = UILabel().where {
            $0.attributedText = "boldko".attributed(.font(UIFont.System.bold.font(size: 20)))
        }

        assertEqual(xml: componentTwoStylesTemplate.fill(source), view: expectedView, testAtSizes: standardTestSizes)
    }

    func testLabelAttributedTextLocalStyles2() {
        let source = """
        <Label layout:edges="super">
        <attributedText style="style2">
            <i>fontko</i>
        </attributedText>
        </Label>
        """
        let expectedView = UILabel().where {
            $0.attributedText = "fontko".attributed(.font(UIFont.System.regular.font(size: 20)))
        }

        assertEqual(xml: componentTwoStylesTemplate.fill(source), view: expectedView, testAtSizes: standardTestSizes)
    }

    func testLabelAttributedTextLocalStyles3() {
        let source = """
        <Label layout:edges="super">
        <attributedText>
            <i font=":light@26">fontko</i>
        </attributedText>
        </Label>
        """
        let expectedView = UILabel().where {
            $0.attributedText = "fontko".attributed(.font(UIFont.System.light.font(size: 26)))
        }

        assertEqual(xml: componentTwoStylesTemplate.fill(source), view: expectedView, testAtSizes: standardTestSizes)
    }

    func testLabelAttributedTextLocalStyles4() {
        let source = """
        <Label layout:edges="super">
        <attributedText style="style1">
            normalko
        </attributedText>
        </Label>
        """
        let expectedView = UILabel().where {
            $0.attributedText = "normalko".attributed()
        }

        assertEqual(xml: componentTwoStylesTemplate.fill(source), view: expectedView, testAtSizes: standardTestSizes)
    }

    func testLabelAttributedTextLocalStyles5() {
        let source = """
        <Label layout:edges="super">
        <attributedText style="style1" backgroundColor="red">
            normalko <b backgroundColor="#f5f5f5" font=":bold@20">bold with light background</b> normale
        </attributedText>
        </Label>
        """
        let expectedView = UILabel().where {
            $0.attributedText = "normalko ".attributed(.backgroundColor(UIColor.red)) + "bold with light background".attributed(.font(UIFont.System.bold.font(size: 20)), .backgroundColor(UIColor(rgb: 0xf5f5f5))) + " normale".attributed(.backgroundColor(UIColor.red))
        }

        assertEqual(xml: componentTwoStylesTemplate.fill(source), view: expectedView, testAtSizes: standardTestSizes)
    }
}
