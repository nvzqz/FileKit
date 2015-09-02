//
//  FileKitTests.swift
//  FileKitTests
//
//  Created by Nikolai Vazquez on 9/1/15.
//  Copyright © 2015 Nikolai Vazquez. All rights reserved.
//

import XCTest
import FileKit

class FileKitTests: XCTestCase {
    
    func testStandardizingPath() {
        let a: Path = "~/.."
        let b: Path = "/Users"
        XCTAssertEqual(a.standardized, b.standardized)
    }
    
    func testPathToStringCasting() {
        let a: Path   = "/"
        let b: String = "/"
        XCTAssertEqual(String(a), b)
    }
    
    func testFileStringLiteralConvertible() {
        let a: File = "~/Desktop"
        let b: Path = "~/Desktop"
        XCTAssertEqual(a.path, b)
    }
    
}
