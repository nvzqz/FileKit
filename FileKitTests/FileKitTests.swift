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
    
    func testFindingPaths() {
        let textFiles = FKPath.UserDesktop.findPaths(searchDepth: 2) { path in
            path.pathExtension == "txt"
        }
        textFiles.forEach { print($0) }
    }
    
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

    func testPathAttributes() {

        let a = FKPath.UserDesktop + "test.txt"
        try! "Hello there, sir" |> FKTextFile(path: a)
        let b = FKPath.UserDesktop + "TestDir"
        try! b.createDirectory()

        for p in [a, b] {
            print(p.creationDate)
            print(p.modificationDate)
            print(p.ownerName)
            print(p.ownerID)
            print(p.groupName)
            print(p.groupID)
            print(p.extensionIsHidden)
            print(p.posixPermissions)
            print(p.fileReferenceCount)
            print(p.fileSize)
            print(p.filesystemFileNumber)
            print(p.fileType)
            print("")
        }
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
        let fileToLink = FKTextFile(path: FKPath.UserDesktop + "test.txt")
        let symlinkPath = FKPath.UserDesktop + "test2.txt"

        let testData = "test data"
        try! testData |> fileToLink

        try! fileToLink =>! symlinkPath

        let contents = try! FKTextFile(path: symlinkPath).read()
        XCTAssertEqual(contents, testData)
    }
    
    func testPathOperators() {
        let p: FKPath = "~"
        let ps = p.standardized
        XCTAssertEqual(ps, p•)
        XCTAssertEqual(ps.parent, ps^)
    }
    
    func testCurrent() {
        XCTAssertNotNil(FKPath.Current)
        
        let oldCurrent = FKPath.Current
        let newCurrent: FKPath = FKPath.UserTemporary

        XCTAssertNotEqual(oldCurrent, newCurrent) // else there is no test
        
        FKPath.Current = newCurrent
        XCTAssertEqual(FKPath.Current, newCurrent)
        
        FKPath.Current = oldCurrent
        XCTAssertEqual(FKPath.Current, oldCurrent)
    }
    
    func testVolumes() {
        var volumes = FKPath.Volumes()
        XCTAssertFalse(volumes.isEmpty, "No volume")

        for volume in volumes {
            XCTAssertNotNil("\(volume)")
        }

        volumes = FKPath.Volumes(.SkipHiddenVolumes)
        XCTAssertFalse(volumes.isEmpty, "No visible volume")

        for volume in volumes {
            XCTAssertNotNil("\(volume)")
        }
    }
    
    func testURL() {
        let path: FKPath = FKPath.UserTemporary
        XCTAssertNotNil(path.url)
        
        if let url = path.url {
            if let pathFromUrl = FKPath(url: url) {
                XCTAssertEqual(pathFromUrl, path)

                let subPath = pathFromUrl + "test"
                XCTAssertEqual(FKPath(url: url.URLByAppendingPathComponent("test")), subPath)
            }
            else {
                XCTFail("Not able to create FKPath from URL")
            }
        }
    }

    func testBookmarkData() {
        let path: FKPath = FKPath.UserTemporary
        XCTAssertNotNil(path.bookmarkData)

        if let bookmarkData = path.bookmarkData {
            if let pathFromBookmarkData = FKPath(bookmarkData: bookmarkData) {
                XCTAssertEqual(pathFromBookmarkData, path)
            }
            else {
                XCTFail("Not able to create FKPath from Bookmark Data")
            }
        }
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
