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
public protocol FileType : CustomStringConvertible, CustomDebugStringConvertible, Comparable {
    
    /// The type for which the file reads and writes data.
    typealias Data
    
    /// The file's filesystem path.
    var path: Path { get set }
    
    /// Initializes a file from a path.
    init(path: Path)
    
    /// Reads the file and returns its data.
    func read() throws -> Data
    
    /// Writes data to the file.
    func write(data: Data) throws
    
}

public extension FileType {
    
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

    /// The size of `self` in bytes.
    public var size: UInt64? {
        return path.fileSize
    }
    
    /// Creates the file.
    ///
    /// Throws an error if the file cannot be created.
    ///
    /// - Throws: `FileKitError.CreateFileFail`
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
    /// - Throws: `FileKitError.MoveFileFail`
    ///
    public mutating func moveToPath(path: Path) throws {
        try path.moveFileToPath(path)
        self.path = path
    }
    
    /// Copies the file to a path.
    ///
    /// Throws an error if the file could not be copied or if a file already
    /// exists at the destination path.
    ///
    /// - Throws: `FileKitError.FileDoesNotExist`, `FileKitError.CopyFileFail`
    ///
    public func copyToPath(path: Path) throws {
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
    /// - Throws: `FileKitError.FileDoesNotExist`, `FileKitError.CreateSymlinkFail`
    ///
    public func symlinkToPath(path: Path) throws {
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

extension FileType where Data : Readable {

    /// Reads the file and returns its data.
    public func read() throws -> Data {
        return try Data.readFromPath(path)
    }

}

extension FileType where Data : Writable {

    /// Writes data to the file.
    ///
    /// Writing is done atomically by default.
    ///
    /// - Parameter data: The data to be written to the file.
    ///
    /// - Throws: `FileKitError.WriteToFileFail`
    ///
    public func write(data: Data) throws {
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
    /// - Throws: `FileKitError.WriteToFileFail`
    ///
    public func write(data: Data, atomically useAuxiliaryFile: Bool) throws {
        try data.writeToPath(path, atomically: useAuxiliaryFile)
    }

}
