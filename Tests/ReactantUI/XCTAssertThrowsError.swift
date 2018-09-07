//
//  XCTAssertThrowsError.swift
//  LiveUI-iOSTests
//
//  Created by Matyáš Kříž on 07/09/2018.
//

import XCTest

func XCTAssertThrowsError(message: String = "", file: StaticString = #file, line: UInt = #line, _ block: () throws -> ()) {
    do {
        try block()

        let msg = (message == "") ? "Tested block did not throw error as expected." : message
        XCTFail(msg, file: file, line: line)
    } catch {}
}
