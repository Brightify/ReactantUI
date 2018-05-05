//
//  ConstraintConditionTests.swift
//  LiveUI-iOSTests
//
//  Created by Robin Krenecky on 27/04/2018.
//

import XCTest
@testable import ReactantLiveUI

class ConstraintConditionTests: XCTestCase {

    lazy var interfaceState1: InterfaceState = {
        return InterfaceState(interfaceIdiom: .phone, horizontalSizeClass: .compact, verticalSizeClass: .regular, deviceOrientation: .landscape)
    }()

    lazy var interfaceState2: InterfaceState = {
        return InterfaceState(interfaceIdiom: .pad, horizontalSizeClass: .regular, verticalSizeClass: .compact, deviceOrientation: .portrait)
    }()

    lazy var interfaceState3: InterfaceState = {
        return InterfaceState(interfaceIdiom: .phone, horizontalSizeClass: .compact, verticalSizeClass: .compact, deviceOrientation: .portrait)
    }()

    var allInterfaceStates: [InterfaceState] {
        return [interfaceState1, interfaceState2, interfaceState3]
    }

    private func parseInput(_ input: String) throws -> Condition? {
        return try ConstraintParser(tokens: Lexer.tokenize(input: "\(input) super inset"), layoutAttribute: LayoutAttribute.above).parseSingle().condition
    }
    
    func testSimpleStatements() throws {
        let input1 = "[iphone != true]"
        let input2 = "[ipad == true]"
        let input3 = "[ipad == false]"
        let input4 = "[!ipad]"
        let input5 = "[vertical == compact]"
        let input6 = "[vertical == compact == false]"
        let input7 = "[landscape]"
        let input8 = "[vertical != compact]"
        let input9 = "[vertical != regular == false]"
        let input10 = "[!(vertical != regular) != false]"


        if let result1 = try parseInput(input1),
            let result2 = try parseInput(input2),
            let result3 = try parseInput(input3),
            let result4 = try parseInput(input4),
            let result5 = try parseInput(input5),
            let result6 = try parseInput(input6),
            let result7 = try parseInput(input7),
            let result8 = try parseInput(input8),
            let result9 = try parseInput(input9),
            let result10 = try parseInput(input10) {

            XCTAssertFalse(result1.evaluate(from: interfaceState1))
            XCTAssertTrue(result1.evaluate(from: interfaceState2))
            XCTAssertFalse(result1.evaluate(from: interfaceState3))

            XCTAssertFalse(result2.evaluate(from: interfaceState1))
            XCTAssertTrue(result2.evaluate(from: interfaceState2))
            XCTAssertFalse(result2.evaluate(from: interfaceState3))

            XCTAssertTrue(result3.evaluate(from: interfaceState1))
            XCTAssertFalse(result3.evaluate(from: interfaceState2))
            XCTAssertTrue(result3.evaluate(from: interfaceState3))

            XCTAssertTrue(result4.evaluate(from: interfaceState1))
            XCTAssertFalse(result4.evaluate(from: interfaceState2))
            XCTAssertTrue(result4.evaluate(from: interfaceState3))

            XCTAssertFalse(result5.evaluate(from: interfaceState1))
            XCTAssertTrue(result5.evaluate(from: interfaceState2))
            XCTAssertTrue(result5.evaluate(from: interfaceState3))

            XCTAssertTrue(result6.evaluate(from: interfaceState1))
            XCTAssertFalse(result6.evaluate(from: interfaceState2))
            XCTAssertFalse(result6.evaluate(from: interfaceState3))

            XCTAssertTrue(result7.evaluate(from: interfaceState1))
            XCTAssertFalse(result7.evaluate(from: interfaceState2))
            XCTAssertFalse(result7.evaluate(from: interfaceState3))

            XCTAssertTrue(result8.evaluate(from: interfaceState1))
            XCTAssertFalse(result8.evaluate(from: interfaceState2))
            XCTAssertFalse(result8.evaluate(from: interfaceState3))

            XCTAssertTrue(result9.evaluate(from: interfaceState1))
            XCTAssertFalse(result9.evaluate(from: interfaceState2))
            XCTAssertFalse(result9.evaluate(from: interfaceState3))

            XCTAssertTrue(result10.evaluate(from: interfaceState1))
            XCTAssertFalse(result10.evaluate(from: interfaceState2))
            XCTAssertFalse(result10.evaluate(from: interfaceState3))
        }
    }

    func testSimpleConjunctions() throws {
        let input1 = "[ipad && landscape]"
        let input2 = "[iphone && portrait]"
        let input3 = "[!ipad && vertical == compact]"
        let input4 = "[horizontal == compact && vertical == regular]"
        let input5 = "[horizontal == regular && vertical == compact && ipad && !landscape]"
        let input6 = "[horizontal != regular && vertical == compact && !ipad && !landscape]"

        if let result1 = try parseInput(input1),
            let result2 = try parseInput(input2),
            let result3 = try parseInput(input3),
            let result4 = try parseInput(input4),
            let result5 = try parseInput(input5),
            let result6 = try parseInput(input6) {

            XCTAssertFalse(result1.evaluate(from: interfaceState1))
            XCTAssertFalse(result1.evaluate(from: interfaceState2))
            XCTAssertFalse(result1.evaluate(from: interfaceState3))

            XCTAssertFalse(result2.evaluate(from: interfaceState1))
            XCTAssertFalse(result2.evaluate(from: interfaceState2))
            XCTAssertTrue(result2.evaluate(from: interfaceState3))

            XCTAssertFalse(result3.evaluate(from: interfaceState1))
            XCTAssertFalse(result3.evaluate(from: interfaceState2))
            XCTAssertTrue(result3.evaluate(from: interfaceState3))

            XCTAssertTrue(result4.evaluate(from: interfaceState1))
            XCTAssertFalse(result4.evaluate(from: interfaceState2))
            XCTAssertFalse(result4.evaluate(from: interfaceState3))

            XCTAssertFalse(result5.evaluate(from: interfaceState1))
            XCTAssertTrue(result5.evaluate(from: interfaceState2))
            XCTAssertFalse(result5.evaluate(from: interfaceState3))

            XCTAssertFalse(result6.evaluate(from: interfaceState1))
            XCTAssertFalse(result6.evaluate(from: interfaceState2))
            XCTAssertTrue(result6.evaluate(from: interfaceState3))
        }
    }

    func testSimpleDisjunctions() throws {
        let input1 = "[ipad || landscape]"
        let input2 = "[!ipad || vertical == compact]"
        let input3 = "[horizontal == regular || vertical == regular]"
        let input4 = "[horizontal == regular || vertical == compact || ipad]"
        let input5 = "[horizontal != regular || vertical == compact || !ipad]"

        if let result1 = try parseInput(input1),
            let result2 = try parseInput(input2),
            let result3 = try parseInput(input3),
            let result4 = try parseInput(input4),
            let result5 = try parseInput(input5) {

            XCTAssertTrue(result1.evaluate(from: interfaceState1))
            XCTAssertTrue(result1.evaluate(from: interfaceState2))
            XCTAssertFalse(result1.evaluate(from: interfaceState3))

            XCTAssertTrue(result2.evaluate(from: interfaceState1))
            XCTAssertTrue(result2.evaluate(from: interfaceState2))
            XCTAssertTrue(result2.evaluate(from: interfaceState3))

            XCTAssertTrue(result3.evaluate(from: interfaceState1))
            XCTAssertTrue(result3.evaluate(from: interfaceState2))
            XCTAssertFalse(result3.evaluate(from: interfaceState3))

            XCTAssertFalse(result4.evaluate(from: interfaceState1))
            XCTAssertTrue(result4.evaluate(from: interfaceState2))
            XCTAssertTrue(result4.evaluate(from: interfaceState3))

            XCTAssertTrue(result5.evaluate(from: interfaceState1))
            XCTAssertTrue(result5.evaluate(from: interfaceState2))
            XCTAssertTrue(result5.evaluate(from: interfaceState3))
        }
    }

    func testComplexConditions() throws {
        let input1 = "[ipad && landscape || vertical == regular]"
        let input2 = "[iphone && portrait || ipad && landscape || vertical == regular]"
        let input3 = "[ipad || landscape && vertical == regular || !ipad && portrait != false]"
        let input4 = "[vertical != regular || portrait && !iphone && horizontal == regular]"
        let input5 = "[(iphone || landscape) && vertical == regular]"
        let input6 = "[(vertical == regular && horizontal == compact) || (ipad && portrait)]"
        let input7 = "[!(ipad && portrait) && !(horizontal == regular)]"
        let input8 = "[(!(vertical == regular) || !(horizontal == compact && landscape)) && iphone]"
        let input9 = "[(!(iphone == false && landscape) && horizontal == compact) && vertical != compact]"

        if let result1 = try parseInput(input1),
            let result2 = try parseInput(input2),
            let result3 = try parseInput(input3),
            let result4 = try parseInput(input4),
            let result5 = try parseInput(input5),
            let result6 = try parseInput(input6),
            let result7 = try parseInput(input7),
            let result8 = try parseInput(input8),
            let result9 = try parseInput(input9) {

            XCTAssertTrue(result1.evaluate(from: interfaceState1))
            XCTAssertFalse(result1.evaluate(from: interfaceState2))
            XCTAssertFalse(result1.evaluate(from: interfaceState3))

            XCTAssertTrue(result2.evaluate(from: interfaceState1))
            XCTAssertFalse(result2.evaluate(from: interfaceState2))
            XCTAssertTrue(result2.evaluate(from: interfaceState3))

            XCTAssertTrue(result3.evaluate(from: interfaceState1))
            XCTAssertTrue(result3.evaluate(from: interfaceState2))
            XCTAssertTrue(result3.evaluate(from: interfaceState3))

            XCTAssertFalse(result4.evaluate(from: interfaceState1))
            XCTAssertTrue(result4.evaluate(from: interfaceState2))
            XCTAssertTrue(result4.evaluate(from: interfaceState3))

            XCTAssertTrue(result5.evaluate(from: interfaceState1))
            XCTAssertFalse(result5.evaluate(from: interfaceState2))
            XCTAssertFalse(result5.evaluate(from: interfaceState3))

            XCTAssertTrue(result6.evaluate(from: interfaceState1))
            XCTAssertTrue(result6.evaluate(from: interfaceState2))
            XCTAssertFalse(result6.evaluate(from: interfaceState3))

            XCTAssertTrue(result7.evaluate(from: interfaceState1))
            XCTAssertFalse(result7.evaluate(from: interfaceState2))
            XCTAssertTrue(result7.evaluate(from: interfaceState3))

            XCTAssertFalse(result8.evaluate(from: interfaceState1))
            XCTAssertFalse(result8.evaluate(from: interfaceState2))
            XCTAssertTrue(result8.evaluate(from: interfaceState3))

            XCTAssertTrue(result9.evaluate(from: interfaceState1))
            XCTAssertFalse(result9.evaluate(from: interfaceState2))
            XCTAssertFalse(result9.evaluate(from: interfaceState3))
        }
    }

    func testMoreConditions() throws {
        let input = [
            "[vertical == regular || (horizontal == compact || vertical == compact && pad)]",
            "[vertical == regular || (horizontal == compact && vertical == compact && pad)]",
            "[vertical == regular && (horizontal == compact && vertical == compact || phone)]",
        ]

        let verifiers = [
            [true, true, true],
            [true, false, false],
            [false, false, true],
        ]

        let results = try input.flatMap { try parseInput($0) }.map { parsedInput in
            allInterfaceStates.map { parsedInput.evaluate(from: $0) }
        }

        for (outerIndex, (result, verifier)) in zip(results, verifiers).enumerated() {
            for innerIndex in 0..<result.count {
                XCTAssertEqual(result[innerIndex], verifier[innerIndex], "element at indices [\(outerIndex)][\(innerIndex)]")
            }
        }
    }
}
