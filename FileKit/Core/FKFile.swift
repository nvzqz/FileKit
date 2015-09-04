//
//  File.swift
//  FileKit
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

import Foundation

public class FKFile: StringLiteralConvertible {
    
    // MARK: - File
    
    public var path: FKPath
    
    public init(path: FKPath) {
        self.path = path
    }
    
    public func read() -> NSData? {
        return NSFileManager.defaultManager().contentsAtPath(path.rawValue)
    }
    
    public func read() -> String? {
        if let data: NSData = read() {
            return NSString(data: data, encoding: NSUTF8StringEncoding) as? String
        }
        return nil
    }
    
    public func write(data: NSData) -> Bool {
        return data.writeToFile(path.rawValue, atomically: true)
    }
    
    public func write(string: String) -> Bool {
        return (try? string.writeToFile(
            path.rawValue, atomically: true, encoding: NSUTF8StringEncoding)) != nil
    }
    
    public func createFile() -> Bool {
        return NSFileManager.defaultManager().createFileAtPath(
            path.rawValue, contents: nil, attributes: nil)
    }
    
    public func createDirectory() -> Bool {
        return (try? NSFileManager.defaultManager().createDirectoryAtPath(
            path.rawValue, withIntermediateDirectories: true, attributes: nil)) != nil
    }
    
    public func delete() throws {
        try NSFileManager.defaultManager().removeItemAtPath(path.rawValue)
    }
    
    public func moveToPath(path: FKPath) throws {
        try NSFileManager.defaultManager().moveItemAtPath(path.rawValue, toPath: path.rawValue)
        self.path = path
    }
    
    // MARK: - StringLiteralConvertible
    
    public typealias ExtendedGraphemeClusterLiteralType = StringLiteralType
    
    public typealias UnicodeScalarLiteralType = StringLiteralType
    
    public required init(extendedGraphemeClusterLiteral value: ExtendedGraphemeClusterLiteralType) {
        path = FKPath(value)
    }
    
    public required init(stringLiteral value: StringLiteralType) {
        path = FKPath(value)
    }
    
    public required init(unicodeScalarLiteral value: UnicodeScalarLiteralType) {
        path = FKPath(value)
    }
    
}
