//
//  ConstraintConditionTests.swift
//  LiveUI-iOSTests
//
//  Created by Robin Krenecky on 27/04/2018.
//

import XCTest
@testable import LiveUI

class ConstraintConditionTests: XCTestCase {

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

        let result1 = ConstraintCondition.statement(.interfaceIdiom(.pad, conditionValue: true))
        let result2 = result1
        let result3 = ConstraintCondition.statement(.interfaceIdiom(.pad, conditionValue: false))
        let result4 = result3
        let result5 = ConstraintCondition.statement(.sizeClass(.vertical, type: .compact, conditionValue: true))
        let result6 = ConstraintCondition.statement(.sizeClass(.vertical, type: .compact, conditionValue: false))

        XCTAssertEqual(result1, try parseInput(input1))
        XCTAssertEqual(result2, try parseInput(input2))
        XCTAssertEqual(result3, try parseInput(input3))
        XCTAssertEqual(result4, try parseInput(input4))
        XCTAssertEqual(result5, try parseInput(input5))
        XCTAssertEqual(result6, try parseInput(input6))
    }

    func testSimpleConjunctions() throws {
        let input1 = "[ipad && landscape]"
        let input2 = "[!ipad && vertical == compact]"
        let input3 = "[horizontal == regular && vertical == compact]"
        let input4 = "[horizontal == regular && vertical == compact && ipad]"

        let result1 = ConstraintCondition.conjunction(
            .statement(.interfaceIdiom(.pad, conditionValue: true)),
            .statement(.orientation(.landscape, conditionValue: true))
        )

        let result2 = ConstraintCondition.conjunction(
            .statement(.interfaceIdiom(.pad, conditionValue: false)),
            .statement(.sizeClass(.vertical, type: .compact, conditionValue: true))
        )

        let result3 = ConstraintCondition.conjunction(
            .statement(.sizeClass(.horizontal, type: .regular, conditionValue: true)),
            .statement(.sizeClass(.vertical, type: .compact, conditionValue: true))
        )

        let result4 = ConstraintCondition.conjunction(
            .statement(.sizeClass(.horizontal, type: .regular, conditionValue: true)),
            .conjunction(
                .statement(.sizeClass(.vertical, type: .compact, conditionValue: true)),
                .statement(.interfaceIdiom(.pad, conditionValue: true))
            )
        )

        XCTAssertEqual(result1, try parseInput(input1))
        XCTAssertEqual(result2, try parseInput(input2))
        XCTAssertEqual(result3, try parseInput(input3))
        XCTAssertEqual(result4, try parseInput(input4))
    }

    func testSimpleDisjunctions() throws {
        let input1 = "[ipad || landscape]"
        let input2 = "[!ipad || vertical == compact]"
        let input3 = "[horizontal == regular || vertical == compact]"
        let input4 = "[horizontal == regular || vertical == compact || ipad]"

        let result1 = ConstraintCondition.disjunction(
            .statement(.interfaceIdiom(.pad, conditionValue: true)),
            .statement(.orientation(.landscape, conditionValue: true))
        )

        let result2 = ConstraintCondition.disjunction(
            .statement(.interfaceIdiom(.pad, conditionValue: false)),
            .statement(.sizeClass(.vertical, type: .compact, conditionValue: true))
        )

        let result3 = ConstraintCondition.disjunction(
            .statement(.sizeClass(.horizontal, type: .regular, conditionValue: true)),
            .statement(.sizeClass(.vertical, type: .compact, conditionValue: true))
        )

        let result4 = ConstraintCondition.disjunction(
            .statement(.sizeClass(.horizontal, type: .regular, conditionValue: true)),
            .disjunction(
                .statement(.sizeClass(.vertical, type: .compact, conditionValue: true)),
                .statement(.interfaceIdiom(.pad, conditionValue: true))
            )
        )

        XCTAssertEqual(result1, try parseInput(input1))
        XCTAssertEqual(result2, try parseInput(input2))
        XCTAssertEqual(result3, try parseInput(input3))
        XCTAssertEqual(result4, try parseInput(input4))
    }

    func testComplexConditions() throws {
        let input1 = "[ipad && landscape || vertical == compact]"
        let input2 = "[(ipad || landscape) && vertical == compact]"

        let result1 = ConstraintCondition.disjunction(
            .statement(.interfaceIdiom(.pad, conditionValue: true)),
            .conjunction(
                .statement(.orientation(.landscape, conditionValue: true)),
                .statement(.sizeClass(.vertical, type: .compact, conditionValue: true))
            )
        )

        let result2 = ConstraintCondition.conjunction(
            .disjunction(
                .statement(.interfaceIdiom(.pad, conditionValue: true)),
                .statement(.orientation(.landscape, conditionValue: true))
            ),
            .statement(.sizeClass(.vertical, type: .compact, conditionValue: true))
        )

        XCTAssertEqual(result1, try parseInput(input1))
        XCTAssertEqual(result2, try parseInput(input2)) // FAIL
    }
}
