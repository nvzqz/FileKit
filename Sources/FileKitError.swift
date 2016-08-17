//
//  FileKitErrorType.swift
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

/// An error that can be thrown by FileKit.
public enum FileKitError: Error {

    // MARK: FileKitError

    /// The reason for why the error occured.
    public var message: String {
        switch self {
        case let .fileDoesNotExist(path):
            return "File does not exist at \"\(path)\""
        case let .changeDirectoryFail(fromPath, toPath):
            return "Could not change the directory from \"\(fromPath)\" to \"\(toPath)\""
        case let .createSymlinkFail(fromPath, toPath):
            return "Could not create symlink from \"\(fromPath)\" to \"\(toPath)\""
        case let .createHardlinkFail(fromPath, toPath):
            return "Could not create a hard link from \"\(fromPath)\" to \"\(toPath)\""
        case let .createFileFail(path):
            return "Could not create file at \"\(path)\""
        case let .createDirectoryFail(path):
            return "Could not create a directory at \"\(path)\""
        case let .deleteFileFail(path):
            return "Could not delete file at \"\(path)\""
        case let .readFromFileFail(path):
            return "Could not read from file at \"\(path)\""
        case let .writeToFileFail(path):
            return "Could not write to file at \"\(path)\""
        case let .moveFileFail(fromPath, toPath):
            return "Could not move file at \"\(fromPath)\" to \"\(toPath)\""
        case let .copyFileFail(fromPath, toPath):
            return "Could not copy file from \"\(fromPath)\" to \"\(toPath)\""
        case let .attributesChangeFail(path):
            return "Could not change file attrubutes at \"\(path)\""
        }
    }

    /// A file does not exist.
    case fileDoesNotExist(path: Path)

    /// Could not change the current directory.
    case changeDirectoryFail(from: Path, to: Path)

    /// A symbolic link could not be created.
    case createSymlinkFail(from: Path, to: Path)

    /// A hard link could not be created.
    case createHardlinkFail(from: Path, to: Path)

    /// A file could not be created.
    case createFileFail(path: Path)

    /// A directory could not be created.
    case createDirectoryFail(path: Path)

    /// A file could not be deleted.
    case deleteFileFail(path: Path)

    /// A file could not be read from.
    case readFromFileFail(path: Path)

    /// A file could not be written to.
    case writeToFileFail(path: Path)

    /// A file could not be moved.
    case moveFileFail(from: Path, to: Path)

    /// A file could not be copied.
    case copyFileFail(from: Path, to: Path)

    /// One or many attributes could not be changed.
    case attributesChangeFail(path: Path)
}

extension FileKitError: CustomStringConvertible {
    // MARK: - CustomStringConvertible
    /// A textual representation of `self`.
    public var description: String {
        return String(describing: type(of: self)) + "(" + message + ")"
    }

}
