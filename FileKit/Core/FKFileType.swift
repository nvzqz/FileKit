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
public protocol FKFileType: CustomStringConvertible, CustomDebugStringConvertible, Comparable {
    
    /// The type for which the file reads and writes data.
    typealias DataType
    
    /// The file's filesystem path.
    var path: FKPath { get set }
    
    /// Initializes a file from a path.
    init(path: FKPath)
    
    /// Reads the file and returns its data.
    func read() throws -> DataType
    
    /// Writes data to the file.
    func write(data: DataType) throws
    
}

public extension FKFileType {
    
    /// The file's name.
    public var name: String {
        if let name = path.components.last?.rawValue {
            return name
        } else {
            return ""
        }
    }
    
    /// The file's filesystem path extension.
    public final var pathExtension: String {
        return path.pathExtension
    }
    
    /// True if the file exists.
    public var exists: Bool {
        return path.exists
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
        try path.moveFileToPath(path)
        self.path = path
    }
    
    /// Copies the file to a path.
    ///
    /// Throws an error if the file could not be copied or if a file already
    /// exists at the destination path.
    ///
    /// - Throws: `FKError.FileDoesNotExist`, `FKError.CopyFileFail`
    ///
    public func copyToPath(path: FKPath) throws {
        try path.copyFileToPath(path)
    }
    
    /// Symlinks the file to a path.
    ///
    /// If the path already exists and _is not_ a directory, an error will be
    /// thrown and a link will not be created.
    ///
    /// If the path already exists and _is_ a directory, the link will be made
    /// to `self` in that directory.
    ///
    /// - Throws: `FKError.FileDoesNotExist`, `FKError.CreateSymlinkFail`
    ///
    public func symlinkToPath(path: FKPath) throws {
        try self.path.symlinkFileToPath(path)
    }
    
    // Mark: - CustomStringConvertible
    
    public var description: String {
        return String(self.dynamicType) + ": (" + path.description + ")"
    }
    
    // MARK: - CustomDebugStringConvertible
    
    public var debugDescription: String {
        return String(self.dynamicType) + ": (" + path.debugDescription + ")"
    }
    
}

extension FKFileType where DataType : FKReadable {

    /// Reads the file and returns its data.
    public func read() throws -> DataType {
        return try DataType.readFromPath(path)
    }

}

extension FKFileType where DataType : FKWritable {

    /// Writes data to the file.
    ///
    /// Writing is done atomically by default.
    ///
    /// - Parameter data: The data to be written to the file.
    ///
    /// - Throws: `FKError.WriteToFileFail`
    ///
    public func write(data: DataType) throws {
        try self.write(data, atomically: true)
    }

    /// Writes data to the file.
    ///
    /// - Parameter data: The data to be written to the file.
    ///
    /// - Parameter atomically: If `true`, the data is written to an auxiliary
    ///                         file that is then renamed to the file.
    ///                         If `false`, the data is written to the file
    ///                         directly.
    ///
    /// - Throws: `FKError.WriteToFileFail`
    ///
    public func write(data: DataType, atomically useAuxiliaryFile: Bool) throws {
        try data.writeToPath(path, atomically: useAuxiliaryFile)
    }

}
