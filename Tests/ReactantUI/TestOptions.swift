//
//  TestOptions.swift
//  LiveUI-iOSTests
//
//  Created by Matyáš Kříž on 14/06/2018.
//

import Foundation

/**
 * To set the environment variables used by the `TestOptions`, select `LiveUI-iOS` scheme, edit it
 * select the `Test` tab on the left and then select `Arguments` up top to see the testing environment variables
 */
struct TestOptions {
    static let testRunIdentifier = UUID()
    static let testRunDate = Date()
    static let configuration = TestLiveUIConfiguration()

    static let testRunDateFormatted: String = dateFormatter.string(from: testRunDate)
    private static let dateFormatter = DateFormatter().where {
        $0.dateFormat = "yyyy-MM-dd_HH:mm:ss"
    }

    static var snapshotPath: String? {
        return ProcessInfo.processInfo.environment["snapshotPath"]
    }

    static var shouldUseDrawViewHierarchyInRect: Bool {
        return ProcessInfo.processInfo.environment["shouldUseDrawViewHierarchyInRect"] == "true"
    }

    static var shouldSaveSnapshots: Bool {
        return snapshotPath != nil
    }
}
