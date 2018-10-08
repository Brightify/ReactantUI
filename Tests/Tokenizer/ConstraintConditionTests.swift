//
//  ConstraintConditionTests.swift
//  LiveUI-iOSTests
//
//  Created by Robin Krenecky on 27/04/2018.
//

import XCTest
@testable import ReactantLiveUI

public class TestTraitHelper: TraitHelper {
    public var horizontalSize: UIUserInterfaceSizeClass
    public var verticalSize: UIUserInterfaceSizeClass
    public var deviceType: UIUserInterfaceIdiom
    public var dimensions: CGSize

    init(horizontalSize: UIUserInterfaceSizeClass,
         verticalSize: UIUserInterfaceSizeClass,
         deviceType: UIUserInterfaceIdiom,
         dimensions: CGSize) {
        self.horizontalSize = horizontalSize
        self.verticalSize = verticalSize
        self.deviceType = deviceType
        self.dimensions = dimensions
    }

    public var isHorizontal: Bool {
        return dimensions.width > dimensions.height
    }

    public var isVertical: Bool {
        return !isHorizontal
    }

    private var rootViewOrientation: ViewOrientation {
        return ViewOrientation(size: dimensions)
    }

    public func size(horizontal sizeClass: UIUserInterfaceSizeClass) -> Bool {
        return horizontalSize == sizeClass
    }

    public func size(vertical sizeClass: UIUserInterfaceSizeClass) -> Bool {
        return verticalSize == sizeClass
    }

    public func device(_ deviceType: UIUserInterfaceIdiom) -> Bool {
        return self.deviceType == deviceType
    }

    public func orientation(_ orientation: ViewOrientation) -> Bool {
        return rootViewOrientation == orientation
    }

    public func viewRootSize(_ dimensionType: TraitDimensionType) -> Float {
        switch dimensionType {
        case .width:
            return Float(dimensions.width)
        case .height:
            return Float(dimensions.height)
        }
    }
}

class ConstraintConditionTests: XCTestCase {
    let traitHelper0 = TestTraitHelper(horizontalSize: .compact, verticalSize: .regular, deviceType: .phone, dimensions: CGSize(width: 736, height: 414))
    let traitHelper1 = TestTraitHelper(horizontalSize: .compact, verticalSize: .compact, deviceType: .phone, dimensions: CGSize(width: 414, height: 736))
    let traitHelper2 = TestTraitHelper(horizontalSize: .regular, verticalSize: .compact, deviceType: .pad,   dimensions: CGSize(width: 1366, height: 1024))
    let traitHelper3 = TestTraitHelper(horizontalSize: .regular, verticalSize: .regular, deviceType: .tv,   dimensions: CGSize(width: 3840, height: 2160))

    var allTraitHelpers: [TestTraitHelper] {
        return [traitHelper0, traitHelper1, traitHelper2, traitHelper3]
    }

    private func testSuite(conditions: [String], verifiers: [[Bool]], traitHelperIndices: [Int] = [0, 1, 2, 3], file: StaticString = #file, function: StaticString = #function, line: UInt = #line) throws {
        guard verifiers.count == conditions.count else {
            XCTFail("Number of conditions is not equal to the number of verifiers.", file: file, line: line)
            return
        }
        guard !verifiers.contains(where: { $0.count != traitHelperIndices.count }) else {
            XCTFail("Some verifiers don't match the given trait helper indices count.", file: file, line: line)
            return
        }
        guard !traitHelperIndices.contains(where: { $0 < 0 || $0 >= allTraitHelpers.count }) else {
            XCTFail("Trait helper index is out of bounds [0, \(allTraitHelpers.count - 1)].", file: file, line: line)
            return
        }

        let selectedHelpers = traitHelperIndices.map { allTraitHelpers[$0] }

        let results = try conditions.compactMap { try parseInput($0) }.map { parsedCondition in
            try selectedHelpers.map { try parsedCondition.evaluate(from: $0) }
        }

        for (outerIndex, (result, verifier)) in zip(results, verifiers).enumerated() {
            for innerIndex in 0..<result.count {
                XCTAssertEqual(result[innerIndex], verifier[innerIndex], "element at indices [\(outerIndex)][\(innerIndex)]", file: file, line: line)
            }
        }
    }

    private func parseInput(_ input: String) throws -> Condition? {
        return try ConstraintParser(tokens: Lexer.tokenize(input: "\(input) super inset"), layoutAttribute: LayoutAttribute.above).parseSingle().condition
    }

    func testSimpleStatements() throws {
        let input = [
            "iphone != true",
            "ipad == true",
            "ipad == false",
            "!ipad",
            "tv",
            "vertical == compact",
            "vertical == compact == false",
            "landscape",
            "vertical != compact",
            "vertical != regular == false",
            "!(vertical != regular) != false",
        ].map { "[\($0)]" }

        let verifiers = [
            [false, false, true, true],
            [false, false, true, false],
            [true, true, false, true],
            [true, true, false, true],
            [false, false, false, true],
            [false, true, true, false],
            [true, false, false, true],
            [true, false, true, true],
            [true, false, false, true],
            [true, false, false, true],
            [true, false, false, true],
        ]

        try testSuite(conditions: input, verifiers: verifiers)
    }

    func testSimpleConjunctions() throws {
        let input = [
            "ipad and landscape",
            "iphone and portrait",
            "!ipad and vertical == compact",
            "horizontal == compact and vertical == regular",
            "horizontal == regular and vertical == compact and ipad and !landscape",
            "horizontal != regular and vertical == compact and !ipad and !landscape",
        ].map { "[\($0)]" }

        let verifiers = [
            [false, false, true, false],
            [false, true, false, false],
            [false, true, false, false],
            [true, false, false, false],
            [false, false, false, false],
            [false, true, false, false],
        ]

        try testSuite(conditions: input, verifiers: verifiers)
    }

    func testSimpleDisjunctions() throws {
        let input = [
            "ipad or landscape",
            "!ipad or vertical == compact",
            "horizontal == regular or vertical == regular",
            "horizontal == regular or vertical == compact or ipad",
            "horizontal != regular or vertical == compact or !ipad",
        ].map { "[\($0)]" }

        let verifiers = [
            [true, false, true, true],
            [true, true, true, true],
            [true, false, true, true],
            [false, true, true, true],
            [true, true, true, true],
        ]

        try testSuite(conditions: input, verifiers: verifiers)
    }

    func testComplexConditions() throws {
        let input = [
            "ipad and landscape or vertical == regular",
            "iphone and portrait or ipad and landscape or vertical == regular",
            "ipad or landscape and vertical == regular or !ipad and portrait != false",
            "vertical != regular or portrait and !iphone and horizontal == regular",
            "(iphone or landscape) and vertical == regular",
            "(vertical == regular and horizontal == compact) or (ipad and portrait)",
            "!(ipad and portrait) and !(horizontal == regular)",
            "(!(vertical == regular) or !(horizontal == compact and landscape)) and iphone",
            "!(!(!(iphone == false and landscape) and horizontal == compact) and vertical != compact)",
            "vertical == regular or (horizontal == compact or vertical == compact and pad)",
            "vertical == regular or (horizontal == compact and vertical == compact and pad)",
            "vertical == regular and (horizontal == compact and vertical == compact or phone)",
        ].map { "[\($0)]" }

        let verifiers = [
            [true, false, true, true],
            [true, true, true, true],
            [true, true, true, true],
            [false, true, true, false],
            [true, false, false, true],
            [true, false, false, false],
            [true, true, false, false],
            [false, true, false, false],
            [true, true, true, false],
            [true, true, true, true],
            [true, false, false, true],
            [true, false, false, false],
        ]

        try testSuite(conditions: input, verifiers: verifiers)
    }
}
