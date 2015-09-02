//
//  FileKit_OSX_Tests.swift
//  FileKit-OSX-Tests
//
//  Created by Nikolai Vazquez on 9/2/15.
//  Copyright © 2015 Nikolai Vazquez. All rights reserved.
//

import XCTest
import FileKit

class FileKit_OSX_Tests: XCTestCase {
    
    func testPathStringLiteralConvertible() {
        let a  = "/Users" as Path
        let b: Path = "/Users"
        let c = Path("/Users")
        XCTAssertTrue(a == b)
        XCTAssertTrue(a == c)
        XCTAssertTrue(b == c)
    }
    
    func testFileStringLiteralConvertible() {
        let a: File = "~/Desktop"
        let b: Path = "~/Desktop"
        XCTAssertEqual(a.path, b)
    }
    
    func testStandardizingPath() {
        let a: Path = "~/.."
        let b: Path = "/Users"
        XCTAssertEqual(a.standardized, b.standardized)
    }
    
}
