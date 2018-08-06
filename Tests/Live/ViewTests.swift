//
//  ViewTests.swift
//  LiveUI-iOSTests
//
//  Created by Matyáš Kříž on 06/08/2018.
//  Copyright © 2018 Brightify. All rights reserved.
//

import XCTest
import UIKit
import Reactant
@testable import ReactantLiveUI

class ViewTests: XCTestCase {
    let standardTestSizes = [10, 50, 100, 150, 250, 500, 1000]
        .map { CGSize($0) }

    let componentTwoStylesTemplate = StringTemplate(
        template: """
    <Component type="aType">
        <styles name="ReactantStyles">
            <ViewStyle name="redBGC" backgroundColor="red" />
            <ViewStyle name="customBGC" backgroundColor="#f0f2f4" />
        </styles>

        #{}
    </Component>
    """, wildcard: "#{}")

    func testViewBare() {
        let source = """
        <View />
        """
        let expectedView = UIView()

        assertEqual(xml: source, view: expectedView, testAtSizes: standardTestSizes)
    }

    // MARK:- Background Colors
    func testViewBackgroundColorPredefined() {
        let source = """
        <View backgroundColor="green" />
        """
        let expectedView = UIView().where {
            $0.backgroundColor = .green
        }

        assertEqual(xml: source, view: expectedView, testAtSizes: standardTestSizes)
    }

    func testViewBackgroundColorCustom() {
        let source = """
        <View
            backgroundColor="#e3f6a9" />
        """
        let expectedView = UIView().where {
            $0.backgroundColor = UIColor(rgb: 0xe3f6a9)
        }

        assertEqual(xml: source, view: expectedView, testAtSizes: standardTestSizes)
    }

    func testViewBackgroundColorStyle1() {
        let source = """
        <View
            style="redBGC"
            layout:edges="super" />
        """
        let expectedView = UIView().where {
            $0.backgroundColor = .red
        }

        assertEqual(xml: componentTwoStylesTemplate.fill(source), view: expectedView, testAtSizes: standardTestSizes)
    }

    func testViewBackgroundColorStyle2() {
        let source = """
        <View layout:edges="super" style="customBGC" />
        """
        let expectedView = UIView().where {
            $0.backgroundColor = UIColor(rgb: 0xf0f2f4)
        }

        assertEqual(xml: componentTwoStylesTemplate.fill(source), view: expectedView, testAtSizes: standardTestSizes)
    }

    // MARK:- Alpha
    func testViewAlpha1() {
        let source = """
        <View
            backgroundColor="red"
            alpha="1" />
        """
        let expectedView = UIView().where {
            $0.backgroundColor = .red
            $0.alpha = 1
        }

        assertEqual(xml: source, view: expectedView, testAtSizes: standardTestSizes)
    }

    func testViewAlpha0_75() {
        let source = """
        <View
            backgroundColor="red"
            alpha="0.75" />
        """
        let expectedView = UIView().where {
            $0.backgroundColor = .red
            $0.alpha = 0.75
        }

        assertEqual(xml: source, view: expectedView, testAtSizes: standardTestSizes)
    }

    func testViewAlpha0_01() {
        let source = """
        <View
            backgroundColor="red"
            alpha="0.01" />
        """
        let expectedView = UIView().where {
            $0.backgroundColor = .red
            $0.alpha = 0.01
        }

        assertEqual(xml: source, view: expectedView, testAtSizes: standardTestSizes)
    }

    func testViewAlpha2() {
        let source = """
        <View
            backgroundColor="red"
            alpha="2" />
        """
        let expectedView = UIView().where {
            $0.backgroundColor = .red
            $0.alpha = 2
        }

        assertEqual(xml: source, view: expectedView, testAtSizes: standardTestSizes)
    }

    // MARK: Clips To Bounds
    func testViewClipsToBounds1() {
        let source = """
        <View
            backgroundColor="green"
            clipsToBounds="true" />
        """
        let expectedView = UIView().where {
            $0.backgroundColor = .green
            $0.clipsToBounds = true
        }

        assertEqual(xml: source, view: expectedView, testAtSizes: standardTestSizes)
    }

    func testViewClipsToBounds2() {
        let source = """
        <View
            backgroundColor="white"
            clipsToBounds="false" />
        """
        let expectedView = UIView().where {
            $0.backgroundColor = .white
            $0.clipsToBounds = false
        }

        assertEqual(xml: source, view: expectedView, testAtSizes: standardTestSizes)
    }

    func testViewClipsToBounds3() {
        let source = """
        <View
            backgroundColor="green"
            clipsToBounds="false"
            layer.cornerRadius="12" />
        """
        let expectedView = UIView().where {
            $0.backgroundColor = .green
            $0.clipsToBounds = false
            $0.layer.cornerRadius = 12
        }

        assertEqual(xml: source, view: expectedView, testAtSizes: standardTestSizes)
    }

    func testViewClipsToBounds4() {
        let source = """
        <View
            backgroundColor="blue"
            clipsToBounds="true"
            layer.cornerRadius="10" />
        """
        let expectedView = UIView().where {
            $0.backgroundColor = .blue
            $0.clipsToBounds = true
            $0.layer.cornerRadius = 10
        }

        assertEqual(xml: source, view: expectedView, testAtSizes: standardTestSizes)
    }

    // MARK:- Visibility
    func testViewVisibilityVisible() {
        let source = """
        <View
            backgroundColor="yellow"
            visibility="visible" />
        """
        let expectedView = UIView().where {
            $0.backgroundColor = .yellow
            $0.visibility = .visible
        }

        assertEqual(xml: source, view: expectedView, testAtSizes: standardTestSizes)
    }

    func testViewVisibilityHidden() {
        let source = """
        <View
            backgroundColor="gray"
            visibility="hidden" />
        """
        let expectedView = UIView().where {
            $0.backgroundColor = .gray
            $0.visibility = .hidden
        }

        assertEqual(xml: source, view: expectedView, testAtSizes: standardTestSizes)
    }

    func testViewVisibilityCollapsed() {
        let source = """
        <View
            backgroundColor="black"
            visibility="collapsed"
            layout:edges="super" />
        """
        let expectedView = UIView().where {
            $0.backgroundColor = .black
            $0.visibility = .collapsed
        }

        assertEqual(xml: componentTwoStylesTemplate.fill(source), view: expectedView, testAtSizes: standardTestSizes)
    }
}
