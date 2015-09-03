//
//  File.swift
//  FileKit
//
//  Created by Nikolai Vazquez on 9/1/15.
//  Copyright © 2015 Nikolai Vazquez. All rights reserved.
//

import Foundation

public class File: StringLiteralConvertible {
    
    // MARK: - File
    
    public var path: Path
    
    public init(path: Path) {
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
    
    public func moveToPath(path: Path) throws {
        try NSFileManager.defaultManager().moveItemAtPath(path.rawValue, toPath: path.rawValue)
        self.path = path
    }
    
    // MARK: - StringLiteralConvertible
    
    public typealias ExtendedGraphemeClusterLiteralType = StringLiteralType
    
    public typealias UnicodeScalarLiteralType = StringLiteralType
    
    public required init(extendedGraphemeClusterLiteral value: ExtendedGraphemeClusterLiteralType) {
        path = Path(value)
    }
    
    public required init(stringLiteral value: StringLiteralType) {
        path = Path(value)
    }
    
    public required init(unicodeScalarLiteral value: UnicodeScalarLiteralType) {
        path = Path(value)
    }
    
}
