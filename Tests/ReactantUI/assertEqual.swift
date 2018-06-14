//
//  ReactantUITester.swift
//  LiveUI-iOSTests
//
//  Created by Matyáš Kříž on 12/06/2018.
//

import XCTest
import ReactantUI
import ReactantLiveUI
import UIKit

enum TestError: Error {
    case noFieldFound
    case noStyleFound
    case noMappingFound
}

func assertEqual(xml: String, view expectedView: UIView, testAtSizes testSizes: CGSize..., tolerance: Double = 0, file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
    assertEqual(xml: xml, view: expectedView, testAtSizes: testSizes, tolerance: tolerance, file: file, function: function, line: line)
}

func assertEqual(xml: String, view expectedView: UIView, testAtSizes testSizes: [CGSize], tolerance: Double = 0, file: StaticString = #file, function: StaticString = #function, line: UInt = #line) {
    let globalContext = GlobalContext(styleSheets: [])

    for testSize in testSizes {
        do {
            let parsedXML = SWXMLHash.parse(xml)
            guard let element = parsedXML.children[0].element else { return XCTFail("Couldn't parse the XML as an XML element.") }

            let deserializedView: UIView
            if element.name == "Component" {
                let definition = try ComponentDefinition.deserialize(element)
                deserializedView = AnonymousTestComponent()
                let applier = ReactantLiveUIApplier(
                    context: ComponentContext(globalContext: globalContext, component: definition),
                    commonStyles: [],
                    instance: deserializedView,
                    setConstraint: { _, _ in true },
                    onApplied: nil)
                try applier.apply()
            } else {
                let view = try ElementMapping.mapFrom(element: element)
                let applier = ReactantLiveUIViewApplier(
                    parentContext: globalContext,
                    findViewByFieldName: { _, _ in throw TestError.noFieldFound },
                    resolveStyle: { _ in return view.properties },
                    setConstraint: { _, _ in true })
                guard let (_, _, result) = try applier.apply(element: view, superview: nil, containedIn: nil).first(where: { $0.1 === view }) else { return }
                deserializedView = result
            }

            expectedView.bounds = CGRect(size: testSize)
            let expected = try Snapshotter.takeSnapshot(of: expectedView)

            deserializedView.bounds = CGRect(size: testSize)
            let actual = try Snapshotter.takeSnapshot(of: deserializedView)

            try saveSnapshotIfEnabled(expected: expected, actual: actual, function: function, line: line)

            let message = "View deserialized from XML is not equal (or within tolerance) to expected view. The size tested was \(testSize)."
            if tolerance == 0 {
                XCTAssertTrue(try Comparer.fastCompare(lhs: expected, rhs: actual), message, file: file, line: line)
            } else {
                XCTAssertGreaterThanOrEqual(try Comparer.compare(lhs: expected, rhs: actual), tolerance, message, file: file, line: line)
            }
        } catch let error as SnapshotError {
            XCTFail(error.description, file: file, line: line)
        } catch {
            XCTFail(error.localizedDescription, file: file, line: line)
        }
    }
}

private func saveSnapshotIfEnabled(expected: UIImage, actual: UIImage, function: StaticString = #function, line: UInt = #line) throws {
    guard let snapshotPath = TestOptions.snapshotPath, TestOptions.shouldSaveSnapshots else { return }

    let expectedData = UIImagePNGRepresentation(expected)
    let actualData = UIImagePNGRepresentation(actual)

    // we're using `expected` as the baseline for consistency instead of using both expected and actual images respectively
    func fileName(modifier: String) -> String {
        return "\(Int(expected.size.width))x\(Int(expected.size.height))-\(modifier)@\(Int(expected.scale))x.png"
    }

    let snapshotUrl = URL(fileURLWithPath: snapshotPath, isDirectory: true)
        .appendingPathComponent("TestRun_\(TestOptions.testRunDateFormatted)", isDirectory: true)
        .appendingPathComponent("\(function)@\(line)", isDirectory: true)

    let fileManager = FileManager.default
    try fileManager.createDirectory(at: snapshotUrl, withIntermediateDirectories: true, attributes: nil)

    let expectedPath = snapshotUrl.appendingPathComponent(fileName(modifier: "expected")).path
    let actualPath = snapshotUrl.appendingPathComponent(fileName(modifier: "actual")).path

    fileManager.createFile(atPath: expectedPath, contents: expectedData, attributes: nil)
    fileManager.createFile(atPath: actualPath, contents: actualData, attributes: nil)
}
