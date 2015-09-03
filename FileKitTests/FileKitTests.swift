//
//  FileKitTests.swift
//  FileKitTests
//
//  The MIT License (MIT)
//
//  Copyright (c) 2015 Nikolai Vazquez
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

import XCTest
import FileKit

class FileKitTests: XCTestCase {
    
    // MARK: - Path
    
    func testPathStringLiteralConvertible() {
        let a  = "/Users" as Path
        let b: Path = "/Users"
        let c = Path("/Users")
        XCTAssertTrue(a == b)
        XCTAssertTrue(a == c)
        XCTAssertTrue(b == c)
    }
    
    func testStandardizingPath() {
        let a: Path = "~/.."
        let b: Path = "/Users"
        XCTAssertEqual(a.standardized, b.standardized)
    }
    
    func testPathParent() {
        let a: Path = "/"
        let b: Path = a + "Users"
        XCTAssertEqual(a, b.parent)
    }
    
    func testPathChildren() {
        let p: Path = "/Users"
        XCTAssertNotEqual(p.children, [])
    }
    
    func testPathSubscript() {
        let path = "~/Library/Preferences" as Path
        XCTAssertEqual(path[1], "Library")
    }
    
    func testAddingPaths() {
        let a: Path = "~/Desktop"
        let b: Path = "Files"
        XCTAssertEqual(a + b, "~/Desktop/Files")
    }
    
    func testPathPlusEquals() {
        var a: Path = "~/Desktop"
        a += "Files"
        XCTAssertEqual(a, "~/Desktop/Files")
    }
    
    func testPathOperators() {
        let p: Path = "~"
        XCTAssertEqual(p.standardized, p%)
    }
    
    // MARK: - File
    
    func testFileStringLiteralConvertible() {
        let a: File = "~/Desktop"
        let b: Path = "~/Desktop"
        XCTAssertEqual(a.path, b)
    }
    
    func testFileCreation() {
        let f = File(path: "/Users/nvzqz/Desktop/test.txt")
        XCTAssertTrue(f.createFile())
    }
    
    func testFileWriting() {
        let file = File(path: "/Users/nvzqz/Desktop/string.txt")
        XCTAssertTrue(file.write("test string"))
    }
    
}
