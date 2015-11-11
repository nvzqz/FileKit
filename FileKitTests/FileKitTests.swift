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
        let folders = FKPath.UserHome.findPaths(searchDepth: 0) { path in
            path.isDirectory
        }
        XCTAssertFalse(folders.isEmpty, "Home folder is not empty")
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

    func testSequence() {
        var i = 0
        let parent = FKPath.UserTemporary
        for _ in parent {
            i++
        }
        print("\(i) files under \(parent)")
        
        i = 0
        for (_, _) in FKPath.UserTemporary.enumerate() {
            i++
        }
    }

    func testPathParent() {
        let a: FKPath = "/"
        let b: FKPath = a + "Users"
        XCTAssertEqual(a, b.parent)
    }
    
    func testPathChildren() {
        let p: FKPath = "/Users"
        XCTAssertNotEqual(p.children(), [])
    }
    
    func testPathRecursiveChildren() {
        let p: FKPath = FKPath.UserTemporary
        let children = p.children(recursive: true)
        XCTAssertNotEqual(children, [])
    }

    func testPathAttributes() {

        let a = .UserTemporary + "test.txt"
        try! "Hello there, sir" |> FKTextFile(path: a)
        let b = .UserTemporary + "TestDir"
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
        let fileToLink = FKTextFile(path: .UserTemporary + "test.txt")
        let symlinkPath = .UserTemporary + "test2.txt"

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
        
        let oldCurrent: FKPath = .Current
        let newCurrent: FKPath = .UserTemporary

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
        let path: FKPath = .UserTemporary
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
        let path: FKPath = .UserTemporary
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
    
    func testTouch() {
        let path: FKPath = .UserTemporary + "filekit_test.touch"
        do {
            if path.exists {
                try path.deleteFile()
            }
            XCTAssertFalse(path.exists)

            try path.touch()
            XCTAssertTrue(path.exists)
            
            guard let modificationDate = path.modificationDate else {
                XCTFail("Failed to get modification date")
                return
            }
            sleep(1)
            try path.touch()
            guard let newModificationDate = path.modificationDate else {
                XCTFail("Failed to get modification date")
                return
            }
            
            XCTAssertTrue(modificationDate < newModificationDate)
            
        } catch let error as FKError {
            XCTFail(error.message)
        } catch {
            XCTFail()
        }
    }

    func testWellKnownDirectories() {
        XCTAssertTrue(FKPath.UserHome.exists)
        XCTAssertTrue(FKPath.UserTemporary.exists)
        XCTAssertTrue(FKPath.UserCaches.exists)

        XCTAssertFalse(FKPath.ProcessTemporary.exists)
        XCTAssertFalse(FKPath.UniqueTemporary.exists)
        XCTAssertNotEqual(FKPath.UniqueTemporary, FKPath.UniqueTemporary)
    }

    // MARK: - FKTextFile
    
    let tf = FKTextFile(path: .UserTemporary + "filekit_test.txt")
    
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
        } catch let error as FKError {
            XCTFail(error.message)
        } catch {
            XCTFail()
        }
    }
    
    func testWriteToTextFile() {
        do {
            try tf.write("This is some test.")
            try tf.write("This is another test.", atomically: false)
        } catch let error as FKError {
            XCTFail(error.message)
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
            
        } catch let error as FKError {
            XCTFail(error.message)
        } catch {
            XCTFail()
        }
    }
    
    // MARK: - FKDictionaryFile
    
    let dictionaryFile = FKDictionaryFile(path: .UserTemporary + "filekit_test_dictionary.plist")
    
    func testWriteToDictionaryFile() {
        do {
            let dict = NSMutableDictionary()
            dict["FileKit"] = true
            dict["Hello"] = "World"
            
            try dictionaryFile.write(dict)
            let contents = try dictionaryFile.read()
            XCTAssertEqual(contents, dict)
            
        } catch let error as FKError {
            XCTFail(error.message)
        } catch {
            XCTFail()
        }
    }

    // MARK: - FKArrayFile

    let arrayFile = FKArrayFile(path: .UserTemporary + "filekit_test_array.plist")

    func testWriteToArrayFile() {
        do {
            let array: NSArray = ["ABCD", "WXYZ"]

            try arrayFile.write(array)
            let contents = try arrayFile.read()
            XCTAssertEqual(contents, array)
        } catch let error as FKError {
            XCTFail(error.message)
        } catch {
            XCTFail()
        }
    }

    // MARK: - FKDataFile

    let dataFile = FKDataFile(path: .UserTemporary + "filekit_test_data")

    func testWriteToDataFile() {
        do {
            let data = ("FileKit test" as NSString).dataUsingEncoding(NSUTF8StringEncoding)!

            try dataFile.write(data)
            let contents = try dataFile.read()
            XCTAssertEqual(contents, data)
        } catch let error as FKError {
            XCTFail(error.message)
        } catch {
            XCTFail()
        }
    }
    
    // MARK: - String+FileKit
    
    let stringFile = FKFile<String>(path: .UserTemporary + "filekit_stringtest.txt")
    
    func testStringInitializationFromPath() {
        do {
            let message = "Testing string init..."
            try stringFile.write(message)
            let contents = try String(contentsOfPath: stringFile.path)
            XCTAssertEqual(contents, message)
        } catch let error as FKError {
            XCTFail(error.message)
        } catch {
            XCTFail()
        }
    }
    
    func testStringWriting() {
        do {
            let message = "Testing string writing..."
            try message.writeToPath(stringFile.path)
            let contents = try String(contentsOfPath: stringFile.path)
            XCTAssertEqual(contents, message)
        } catch let error as FKError {
            XCTFail(error.message)
        } catch {
            XCTFail()
        }
    }

    // MARK: - FKWritableConvertible

    struct BadWritableConvertible : FKWritableConvertible {
        var writable: NSData? { return nil }
    }

    struct GoodWritableConvertible : FKWritableConvertible {
        var writable: NSArray? {
            return []
        }
    }

    func testWritablePropertyNilError() {
        do {
            let writable = BadWritableConvertible()
            try writable.writeToPath(.UniqueTemporary + "file")
        } catch let error as FKError {
            switch error {
            case let .WritableConvertiblePropertyNil(type):
                XCTAssert(type == BadWritableConvertible.self,
                    "Returned type \(type) is not BadWritableConvertible")
                XCTAssert(error.message.containsString("BadWritableConvertible"),
                    "Error message doesn't mention BadWritableConvertible")
            default:
                XCTFail("Error is not FKError.WritablePropertyNil")
            }
        } catch {
            XCTFail("Error is not FKError")
        }
        do {
            let writable = GoodWritableConvertible()
            try writable.writeToPath(.UniqueTemporary + "file")
        } catch let error as FKError {
            switch error {
            case let .WritableConvertiblePropertyNil(type):
                XCTFail("Error from \(type) instance is FKError.WritablePropertyNil")
            default:
                break
            }
        } catch {
            XCTFail("Error is not FKError")
        }
    }

    // MARK: - FKImageType

    let img = FKImageType(contentsOfURL: NSURL(string: "https://raw.githubusercontent.com/nvzqz/FileKit/assets/logo.png")!) ?? FKImageType()

    func testFKImageTypeWriting() {
        do {
            let path: FKPath = .UserTemporary + "filekit_imagetest.png"
            try img.writeToPath(path)
        } catch let error as FKError {
            XCTFail(error.message)
        } catch  {
            XCTFail()
        }
    }
    
}
