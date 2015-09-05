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
    
    // MARK: - FKPath
    
    func testPathStringLiteralConvertible() {
        let a  = "/Users" as FKPath
        let b: FKPath = "/Users"
        let c = FKPath("/Users")
        XCTAssertTrue(a == b)
        XCTAssertTrue(a == c)
        XCTAssertTrue(b == c)
    }
    
    func testStandardizingPath() {
        let a: FKPath = "~/.."
        let b: FKPath = "/Users"
        XCTAssertEqual(a.standardized, b.standardized)
    }
    
    func testPathIsDirectory() {
        let d = FKPath.SystemApplications
        XCTAssertTrue(d.isDirectory)
    }
    
    func testPathParent() {
        let a: FKPath = "/"
        let b: FKPath = a + "Users"
        XCTAssertEqual(a, b.parent)
    }
    
    func testPathChildren() {
        let p: FKPath = "/Users"
        XCTAssertNotEqual(p.children, [])
    }
    
    func testPathSubscript() {
        let path = "~/Library/Preferences" as FKPath
        XCTAssertEqual(path[1], "Library")
    }
    
    func testAddingPaths() {
        let a: FKPath = "~/Desktop"
        let b: FKPath = "Files"
        XCTAssertEqual(a + b, "~/Desktop/Files")
    }
    
    func testPathPlusEquals() {
        var a: FKPath = "~/Desktop"
        a += "Files"
        XCTAssertEqual(a, "~/Desktop/Files")
    }
    
    func testPathOperators() {
        let p: FKPath = "~"
        let ps = p.standardized
        XCTAssertEqual(ps, p•)
        XCTAssertEqual(ps.parent, ps^)
    }
    
    // MARK: - FKTextFile
    
    let f = FKTextFile(path: FKPath.UserDesktop + "filekit_test.txt")
    
    func testTextFileExists() {
        do {
            try f.create()
            XCTAssertTrue(f.exists)
        } catch {
            XCTFail()
        }
    }
    
    func testFileOperators() {
        do {
            let text = "FileKit Test"
            
            try text |> f
            var contents = try f.read()
            XCTAssertTrue(contents.hasSuffix(text))
            
            try text |>> f
            contents = try f.read()
            XCTAssertTrue(contents.hasSuffix(text + "\n" + text))
            
        } catch {
            XCTFail()
        }
    }
    
}
