//
//  FileType.swift
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

/// A type that repressents a filesystem file.
public protocol FKFileType {
    
    /// The type for which the file reads and writes data.
    typealias DataType
    
    /// The file's filesystem path.
    var path: FKPath { get set }
    
    init(path: FKPath)
    
    /// Reads the file and returns its data.
    func read() throws -> DataType
    
    /// Writes data to the file.
    func write(data: DataType) throws
    
}

public extension FKFileType {
    
    /// True if the file exists.
    public var exists: Bool {
        return NSFileManager.defaultManager().fileExistsAtPath(path.rawValue)
    }
    
    /// Creates the file.
    ///
    /// Throws an error if the file cannot be created.
    ///
    /// - Throws: `FKError.CreateFileFail`
    ///
    public func create() throws {
        try path.createFile()
    }
    
    /// Deletes the file.
    public func delete() throws {
        try path.deleteFile()
    }
    
    /// Moves the file to a path.
    ///
    /// Changes the path property to the given path.
    ///
    /// Throws an error if the file cannot be moved.
    ///
    /// - Throws: `FKError.MoveFileFail`
    ///
    public mutating func moveToPath(path: FKPath) throws {
        do {
            let manager = NSFileManager.defaultManager()
            try manager.moveItemAtPath(self.path.rawValue, toPath: path.rawValue)
            self.path = path
        } catch {
            throw FKError.MoveFileFail
        }
    }
    
}
