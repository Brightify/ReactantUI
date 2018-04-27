//
//  ConstraintConditionTests.swift
//  LiveUI-iOSTests
//
//  Created by Robin Krenecky on 27/04/2018.
//

import XCTest
@testable import LiveUI

class ConstraintConditionTests: XCTestCase {

    lazy var interfaceState: InterfaceState = {
        return InterfaceState(interfaceIdiom: .phone, horizontalSizeClass: .compact, verticalSizeClass: .regular, deviceOrientation: .landscape)
    }()

    private func parseInput(_ input: String) throws -> ConstraintCondition? {
        return try ConstraintParser(tokens: Lexer.tokenize(input: "\(input) super inset"), layoutAttribute: LayoutAttribute.above).parseSingle().condition
    }
    
    func testSimpleStatements() throws {
        let input1 = "[ipad]"
        let input2 = "[ipad == true]"
        let input3 = "[ipad == false]"
        let input4 = "[!ipad]"
        let input5 = "[vertical == compact]"
        let input6 = "[vertical == compact == false]"


        if let result1 = try parseInput(input1),
            let result2 = try parseInput(input2),
            let result3 = try parseInput(input3),
            let result4 = try parseInput(input4),
            let result5 = try parseInput(input5),
            let result6 = try parseInput(input6) {

            XCTAssertFalse(result1.evaluate(from: interfaceState))
            XCTAssertFalse(result2.evaluate(from: interfaceState))
            XCTAssertTrue(result3.evaluate(from: interfaceState))
            XCTAssertTrue(result4.evaluate(from: interfaceState))
            XCTAssertFalse(result5.evaluate(from: interfaceState))
            XCTAssertTrue(result6.evaluate(from: interfaceState))
        }
    }

    func testSimpleConjunctions() throws {
        let input1 = "[ipad && landscape]"
        let input2 = "[!ipad && vertical == compact]"
        let input3 = "[horizontal == compact && vertical == regular]"
        let input4 = "[horizontal == regular && vertical == compact && ipad]"

        if let result1 = try parseInput(input1),
            let result2 = try parseInput(input2),
            let result3 = try parseInput(input3),
            let result4 = try parseInput(input4) {

            XCTAssertFalse(result1.evaluate(from: interfaceState))
            XCTAssertFalse(result2.evaluate(from: interfaceState))
            XCTAssertTrue(result3.evaluate(from: interfaceState))
            XCTAssertFalse(result4.evaluate(from: interfaceState))
        }
    }

    func testSimpleDisjunctions() throws {
        let input1 = "[ipad || landscape]"
        let input2 = "[!ipad || vertical == compact]"
        let input3 = "[horizontal == regular || vertical == regular]"
        let input4 = "[horizontal == regular || vertical == compact || ipad]"

        if let result1 = try parseInput(input1),
            let result2 = try parseInput(input2),
            let result3 = try parseInput(input3),
            let result4 = try parseInput(input4) {

            XCTAssertTrue(result1.evaluate(from: interfaceState))
            XCTAssertTrue(result2.evaluate(from: interfaceState))
            XCTAssertTrue(result3.evaluate(from: interfaceState))
            XCTAssertFalse(result4.evaluate(from: interfaceState))
        }
    }

    func testComplexConditions() throws {
        let input1 = "[ipad && landscape || vertical == regular]"
        let input2 = "[(iphone || landscape) && vertical == regular]"

        if let result1 = try parseInput(input1),
            let result2 = try parseInput(input2) {

            XCTAssertTrue(result1.evaluate(from: interfaceState))
            XCTAssertTrue(result2.evaluate(from: interfaceState))
        }
    }
}
