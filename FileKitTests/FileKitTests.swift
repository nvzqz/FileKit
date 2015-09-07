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
        XCTAssertEqual(a, b)
        XCTAssertEqual(a, c)
        XCTAssertEqual(b, c)
    }
    
    func testPathEquality() {
        let a: FKPath = "~"
        let b: FKPath = "~/"
        let c: FKPath = "~//"
        let d: FKPath = "~/./"
        XCTAssertEqual(a, b)
        XCTAssertEqual(a, c)
        XCTAssertEqual(a, d)
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
        
        let a = path[0]
        XCTAssertEqual(a, "~")
        
        let b = path[2]
        XCTAssertEqual(b, path)
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
    
    func testPathSymlinking() {
        do {
            let fileToLink = FKTextFile(path: FKPath.UserDesktop + "test.txt")
            let symlinkPath = FKPath.UserDesktop + "test2.txt"
            
            let testData = "test data"
            try testData |> fileToLink
            
            try symlinkPath.deleteFile()
            try fileToLink.path.createSymlinkToPath(symlinkPath)
            
            let contents = try FKTextFile(path: symlinkPath).read()
            XCTAssertEqual(contents, testData)
        } catch {
            XCTFail()
        }
    }
    
    func testPathOperators() {
        let p: FKPath = "~"
        let ps = p.standardized
        XCTAssertEqual(ps, p•)
        XCTAssertEqual(ps.parent, ps^)
    }
    
    // MARK: - FKTextFile
    
    let tf = FKTextFile(path: FKPath.UserDesktop + "filekit_test.txt")
    
    func testFileName() {
        XCTAssertEqual(FKTextFile(path: "/Users/").name, "Users")
    }
    
    func testTextFileExtension() {
        XCTAssertEqual(tf.pathExtension, "txt")
    }
    
    func testTextFileExists() {
        do {
            try tf.create()
            XCTAssertTrue(tf.exists)
        } catch {
            XCTFail()
        }
    }
    
    func testWriteToTextFile() {
        do {
            try tf.write("This is some test.")
            try tf.write("This is another test.", atomically: false)
        } catch {
            XCTFail()
        }
    }
    
    func testTextFileOperators() {
        do {
            let text = "FileKit Test"
            
            try text |> tf
            var contents = try tf.read()
            XCTAssertTrue(contents.hasSuffix(text))
            
            try text |>> tf
            contents = try tf.read()
            XCTAssertTrue(contents.hasSuffix(text + "\n" + text))
            
        } catch {
            XCTFail()
        }
    }
    
    // MARK: - FKDictionaryFile
    
    let df = FKDictionaryFile(path: FKPath.UserDesktop + "filekit_test.plist")
    
    func testWriteToDictionaryFile() {
        do {
            let dict = NSMutableDictionary()
            dict["FileKit"] = true
            dict["Hello"] = "World"
            
            try df.write(dict)
            let contents = try df.read()
            XCTAssertEqual(contents, dict)
            
        } catch {
            XCTFail()
        }
    }
    
    // MARK: - String+FileKit
    
    let sf = FKFile<String>(path: FKPath.UserDesktop + "filekit_stringtest.txt")
    
    func testStringInitializationFromPath() {
        do {
            let message = "Testing string init..."
            try sf.write(message)
            let contents = try String(contentsOfPath: sf.path)
            XCTAssertEqual(contents, message)
        } catch {
            XCTFail()
        }
    }
    
    func testStringWriting() {
        do {
            let message = "Testing string writing..."
            try message.writeToPath(sf.path)
            let contents = try String(contentsOfPath: sf.path)
            XCTAssertEqual(contents, message)
        } catch {
            XCTFail()
        }
    }
    
}
