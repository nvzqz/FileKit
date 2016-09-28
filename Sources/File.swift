//
//  File.swift
//  FileKit
//
//  The MIT License (MIT)
//
//  Copyright (c) 2015-2016 Nikolai Vazquez
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
/// - Precondition: The data type must conform to ReadableWritable.
///
/// All method do not follow links.
open class File<DataType: ReadableWritable>: Comparable {

    // MARK: - Properties

    /// The file's filesystem path.
    open var path: Path

    /// The file's name.
    open var name: String {
        return path.fileName
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

    /// True if the item exists and is a regular file.
    ///
    /// this method does not follow links.
    open var exists: Bool {
        return path.isRegular
    }

    /// The size of `self` in bytes.
    open var size: UInt64? {
        return path.fileSize
    }

    // MARK: - Initialization

    /// Initializes a file from a path.
    ///
    /// - Parameter path: The path a file to initialize from.
    public init(path: Path) {
        self.path = path
    }

    // MARK: - Filesystem Operations

    /// Reads the file and returns its data.
    ///
    /// - Throws: `FileKitError.ReadFromFileFail`
    /// - Returns: The data read from file.
    open func read() throws -> DataType {
        return try DataType.read(from: path)
    }

    /// Writes data to the file.
    ///
    /// Writing is done atomically by default.
    ///
    /// - Parameter data: The data to be written to the file.
    ///
    /// - Throws: `FileKitError.WriteToFileFail`
    ///
    open func write(_ data: DataType) throws {
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
    open func write(_ data: DataType, atomically useAuxiliaryFile: Bool) throws {
        try data.write(to: path, atomically: useAuxiliaryFile)
    }

    /// Creates the file.
    ///
    /// Throws an error if the file cannot be created.
    ///
    /// - Throws: `FileKitError.CreateFileFail`
    ///
    open func create() throws {
        try path.createFile()
    }

    /// Deletes the file.
    ///
    /// Throws an error if the file could not be deleted.
    ///
    /// - Throws: `FileKitError.DeleteFileFail`
    ///
    open func delete() throws {
        try path.deleteFile()
    }

    /// Moves the file to a path.
    ///
    /// Changes the path property to the given path.
    ///
    /// Throws an error if the file cannot be moved.
    ///
    /// - Parameter path: The path to move the file to.
    /// - Throws: `FileKitError.MoveFileFail`
    ///
    open func move(to path: Path) throws {
        try self.path.moveFile(to: path)
        self.path = path
    }

    /// Copies the file to a path.
    ///
    /// Throws an error if the file could not be copied or if a file already
    /// exists at the destination path.
    ///
    ///
    /// - Parameter path: The path to copy the file to.
    /// - Throws: `FileKitError.FileDoesNotExist`, `FileKitError.CopyFileFail`
    ///
    open func copy(to path: Path) throws {
        try self.path.copyFile(to: path)
    }

    /// Symlinks the file to a path.
    ///
    /// If the path already exists and _is not_ a directory, an error will be
    /// thrown and a link will not be created.
    ///
    /// If the path already exists and _is_ a directory, the link will be made
    /// to `self` in that directory.
    ///
    ///
    /// - Parameter path: The path to symlink the file to.
    /// - Throws:
    ///     `FileKitError.FileDoesNotExist`,
    ///     `FileKitError.CreateSymlinkFail`
    ///
    open func symlink(to path: Path) throws {
        try self.path.symlinkFile(to: path)
    }

    /// Hardlinks the file to a path.
    ///
    /// If the path already exists and _is not_ a directory, an error will be
    /// thrown and a link will not be created.
    ///
    /// If the path already exists and _is_ a directory, the link will be made
    /// to `self` in that directory.
    ///
    ///
    /// - Parameter path: The path to hardlink the file to.
    /// - Throws:
    ///     `FileKitError.FileDoesNotExist`,
    ///     `FileKitError.CreateHardlinkFail`
    ///
    open func hardlink(to path: Path) throws {
        try self.path.hardlinkFile(to: path)
    }

    // MARK: - FileType

    /// The FileType attribute for `self`.
    open var type: FileType? {
        return path.fileType
    }

    // MARK: - FilePermissions

    /// The file permissions for `self`.
    open var permissions: FilePermissions {
        return FilePermissions(forFile: self)
    }

    // MARK: - FileHandle

    /// Returns a file handle for reading from `self`, or `nil` if `self`
    /// doesn't exist.
    open var handleForReading: FileHandle? {
        return path.fileHandleForReading
    }

    /// Returns a file handle for writing to `self`, or `nil` if `self` doesn't
    /// exist.
    open var handleForWriting: FileHandle? {
        return path.fileHandleForWriting
    }

    /// Returns a file handle for reading from and writing to `self`, or `nil`
    /// if `self` doesn't exist.
    open var handleForUpdating: FileHandle? {
        return path.fileHandleForUpdating
    }

    // MARK: - Stream

    /// Returns an input stream that reads data from `self`, or `nil` if `self`
    /// doesn't exist.
    open func inputStream() -> InputStream? {
        return path.inputStream()
    }

    /// Returns an input stream that writes data to `self`, or `nil` if `self`
    /// doesn't exist.
    ///
    /// - Parameter shouldAppend: `true` if newly written data should be
    ///                           appended to any existing file contents,
    ///                           `false` otherwise. Default value is `false`.
    ///
    open func outputStream(append shouldAppend: Bool = false) -> OutputStream? {
        return path.outputStream(append: shouldAppend)
    }

}

extension File: CustomStringConvertible {

    // MARK: - CustomStringConvertible

    /// A textual representation of `self`.
    public var description: String {
        return String(describing: type(of: self)) + "('" + path.description + "')"
    }

}

extension File: CustomDebugStringConvertible {

    // MARK: - CustomDebugStringConvertible

    /// A textual representation of `self`, suitable for debugging.
    public var debugDescription: String {
        return description
    }

}
