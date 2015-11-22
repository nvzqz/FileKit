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

/// A representation of a filesystem file of a given data type.
///
/// - Precondition: The data type must conform to DataType.
///
public class File<Data : DataType> : Comparable {

    /// The file's filesystem path.
    public var path: Path

    /// The file's name.
    public var name: String {
        return path.components.last?.rawValue ?? ""
    }

    /// The file's filesystem path extension.
    public final var pathExtension: String {
        get {
            return path.pathExtension
        }
        set {
            path.pathExtension = newValue
        }
    }

    /// True if the file exists.
    public var exists: Bool {
        return path.exists
    }

    /// The size of `self` in bytes.
    public var size: UInt64? {
        return path.fileSize
    }

    /// Initializes a file from a path.
    required public init(path: Path) {
        self.path = path
    }

    /// Reads the file and returns its data.
    ///
    /// - Throws: `FileKitError.ReadFromFileFail`
    public func read() throws -> Data {
        return try Data.readFromPath(path)
    }

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
    /// - Parameter useAuxiliaryFile: If `true`, the data is written to an
    ///                               auxiliary file that is then renamed to the
    ///                               file. If `false`, the data is written to
    ///                               the file directly.
    ///
    /// - Throws: `FileKitError.WriteToFileFail`
    ///
    public func write(data: Data, atomically useAuxiliaryFile: Bool) throws {
        try data.writeToPath(path, atomically: useAuxiliaryFile)
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
    public func moveToPath(path: Path) throws {
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
    /// - Throws:
    ///     `FileKitError.FileDoesNotExist`,
    ///     `FileKitError.CreateSymlinkFail`
    ///
    public func symlinkToPath(path: Path) throws {
        try self.path.symlinkFileToPath(path)
    }

}

extension File : CustomStringConvertible {

    // MARK: - CustomStringConvertible

    /// A textual representation of `self`.
    public var description: String {
        return String(self.dynamicType) + "('" + path.description + "')"
    }

}

extension File : CustomDebugStringConvertible {

    // MARK: - CustomDebugStringConvertible

    /// A textual representation of `self`, suitable for debugging.
    public var debugDescription: String {
        return description
    }

}
