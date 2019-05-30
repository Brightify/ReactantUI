//
//  ButtonTests.swift
//  LiveUI-iOSTests
//
//  Created by Matyáš Kříž on 15/06/2018.
//  Copyright © 2018 Brightify. All rights reserved.
//

import XCTest
import UIKit
import Hyperdrive
@testable import ReactantLiveUI

class ButtonTests: XCTestCase {
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

    func testButtonBare() {
        let source = """
        <Button />
        """
        let expectedView = UIButton()

        assertEqual(xml: source, view: expectedView, testAtSizes: standardTestSizes)
    }

    func testButtonTitle() {
        let source = """
        <Button title="Get a Life." />
        """
        let expectedView = UIButton().where {
            $0.setTitle("Get a Life.", for: .normal)
        }

        assertEqual(xml: source, view: expectedView, testAtSizes: standardTestSizes)
    }

    // MARK:- Title Colors
    func testButtonTitleColorPredefined() {
        let source = """
        <Button title="Say Hello, World!" titleColor="gray" />
        """
        let expectedView = UIButton().where {
            $0.setTitle("Say Hello, World!", for: .normal)
            $0.setTitleColor(.gray, for: .normal)
        }

        assertEqual(xml: source, view: expectedView, testAtSizes: standardTestSizes)
    }

    func testButtonTitleColorCustom() {
        let source = """
        <Button title="What a Beautiful Day!" titleColor="#d800ff" />
        """
        let expectedView = UIButton().where {
            $0.setTitle("What a Beautiful Day!", for: .normal)
            $0.setTitleColor(UIColor(rgb: 0xd800ff), for: .normal)
        }

        assertEqual(xml: source, view: expectedView, testAtSizes: standardTestSizes)
    }

    // MARK:- Attributed Titles
    func testButtonAttributedTitleFont1() {
        let source = """
        <Button>
        <attributedTitle>
            <style font="22">Change Font!</style>
        </attributedTitle>
        </Button>
        """
        let expectedView = UIButton().where {
            $0.setAttributedTitle("Change Font!".attributed(.font(UIFont.System.regular.font(size: 22))), for: .normal)
        }

        assertEqual(xml: source, view: expectedView, testAtSizes: standardTestSizes)
    }

    func testButtonAttributedTitleFont2() {
        let source = """
        <Button>
        <attributedTitle>
            <style font=":bold@22">Make a Bold Move!</style>
        </attributedTitle>
        </Button>
        """
        let expectedView = UIButton().where {
            $0.setAttributedTitle("Make a Bold Move!".attributed(.font(UIFont.System.bold.font(size: 22))), for: .normal)
        }

        assertEqual(xml: source, view: expectedView, testAtSizes: standardTestSizes)
    }

    func testButtonAttributedTitleFont3() {
        let source = """
        <Button>
        <attributedTitle>
            Boring!
        </attributedTitle>
        </Button>
        """
        let expectedView = UIButton().where {
            $0.setAttributedTitle("Boring!".attributed(), for: .normal)
        }

        assertEqual(xml: source, view: expectedView, testAtSizes: standardTestSizes)
    }

    func testButtonAttributedTitleFont4() {
        let source = """
        <Button>
        <attributedTitle>
            <style font="22">Combined <style font=":bold@20">Power!</style></style>
        </attributedTitle>
        </Button>
        """
        let expectedView = UIButton().where {
            $0.setAttributedTitle("Combined ".attributed(.font(UIFont.System.regular.font(size: 22))) +
                "Power!".attributed(.font(UIFont.System.bold.font(size: 20))), for: .normal)
        }

        assertEqual(xml: source, view: expectedView, testAtSizes: standardTestSizes)
    }

    func testButtonAttributedTitleFont5() {
        let source = """
        <Button>
        <attributedTitle font=":light@25">
            <style font=":light@27">Style Me Up!</style> <style font=":bold@20">Higher!</style>
        </attributedTitle>
        </Button>
        """
        let expectedView = UIButton().where {
            $0.setAttributedTitle("Style Me Up!".attributed(.font(UIFont.System.light.font(size: 27))) + " ".attributed(.font(UIFont.System.light.font(size: 25))) +
                "Higher!".attributed(.font(UIFont.System.bold.font(size: 20))), for: .normal)
        }

        assertEqual(xml: source, view: expectedView, testAtSizes: standardTestSizes)
    }

    func testButtonAttributedTitleFont6() {
        let source = """
        <Button>
        <attributedTitle>
            <style font=":light@25">Style Me Up! </style> <style font=":bold@20"> Higher!</style>
        </attributedTitle>
        </Button>
        """
        let expectedView = UIButton().where {
            $0.setAttributedTitle("Style Me Up! ".attributed(.font(UIFont.System.light.font(size: 25))) + " ".attributed() +
                " Higher!".attributed(.font(UIFont.System.bold.font(size: 20))), for: .normal)
        }

        assertEqual(xml: source, view: expectedView, testAtSizes: standardTestSizes)
    }

    // MARK:- Local Styles
    func testButtonAttributedTitleLocalStyles1() {
        let source = """
        <Button layout:edges="super">
        <attributedTitle style="style1">
            <b>Boulder!</b>
        </attributedTitle>
        </Button>
        """
        let expectedView = UIButton().where {
            $0.setAttributedTitle("Boulder!".attributed(.font(UIFont.System.bold.font(size: 20))), for: .normal)
        }

        assertEqual(xml: componentTwoStylesTemplate.fill(source), view: expectedView, testAtSizes: standardTestSizes)
    }

    func testButtonAttributedTitleLocalStyles2() {
        let source = """
        <Button layout:edges="super">
        <attributedTitle style="style2">
            <i>¡Fonter!</i>
        </attributedTitle>
        </Button>
        """
        let expectedView = UIButton().where {
            $0.setAttributedTitle("¡Fonter!".attributed(.font(UIFont.System.regular.font(size: 20))), for: .normal)
        }

        assertEqual(xml: componentTwoStylesTemplate.fill(source), view: expectedView, testAtSizes: standardTestSizes)
    }

    func testButtonAttributedTitleLocalStyles3() {
        let source = """
        <Button layout:edges="super">
        <attributedTitle style="style1">
            Boring as Usual.
        </attributedTitle>
        </Button>
        """
        let expectedView = UIButton().where {
            $0.setAttributedTitle("Boring as Usual.".attributed(), for: .normal)
        }

        assertEqual(xml: componentTwoStylesTemplate.fill(source), view: expectedView, testAtSizes: standardTestSizes)
    }

    func testButtonAttributedTitleLocalStyles4() {
        let source = """
        <Button layout:edges="super">
        <attributedTitle style="style1" backgroundColor="yellow">
            Normal. <b backgroundColor="#f5f4f3" font=":bold@22">Bold with light background!</b> Normal again.
        </attributedTitle>
        </Button>
        """
        let expectedView = UIButton().where {
            $0.setAttributedTitle("Normal. ".attributed(.backgroundColor(UIColor.yellow)) + "Bold with light background!".attributed(.font(UIFont.System.bold.font(size: 22)), .backgroundColor(UIColor(rgb: 0xf5f4f3))) + " Normal again.".attributed(.backgroundColor(UIColor.yellow)), for: .normal)
        }

        assertEqual(xml: componentTwoStylesTemplate.fill(source), view: expectedView, testAtSizes: standardTestSizes)
    }
}
