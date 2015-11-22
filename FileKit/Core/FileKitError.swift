//
//  FileKitErrorType.swift
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

// MARK: FileKitError

/// An error that can be thrown by FileKit.
public enum FileKitError: ErrorType {

    /// The reason for why the error occured.
    public var message: String {
        switch self {
        case let FileDoesNotExist(path):
            return "File does not exist at \(path)"
        case let ChangeDirectoryFail(fromPath, toPath):
            return "Could not change the directory from \(fromPath) to \(toPath)"
        case let CreateSymlinkFail(fromPath, toPath):
            return "Could not create symlink from \(fromPath) to \(toPath)"
        case let CreateFileFail(path):
            return "Could not create file at \(path)"
        case let DeleteFileFail(path):
            return "Could not delete file at \(path)"
        case let ReadFromFileFail(path):
            return "Could not read from file at \(path)"
        case let WriteToFileFail(path):
            return "Could not write to file at \(path)"
        case let MoveFileFail(fromPath, toPath):
            return "Could not move file at \(fromPath) to \(toPath)"
        case let CopyFileFail(fromPath, toPath):
            return "Could not copy file from \(fromPath) to \(toPath)"
        case let AttributesChangeFail(path):
            return "Could not change file attrubutes at \(path)"
        }
    }

    /// A file does not exist.
    case FileDoesNotExist(path: Path)

    /// Could not change the current directory.
    case ChangeDirectoryFail(from: Path, to: Path)

    /// A symbolic link could not be created.
    case CreateSymlinkFail(from: Path, to: Path)

    /// A file could not be created.
    case CreateFileFail(path: Path)

    /// A file could not be deleted.
    case DeleteFileFail(path: Path)

    /// A file could not be read from.
    case ReadFromFileFail(path: Path)

    /// A file could not be written to.
    case WriteToFileFail(path: Path)

    /// A file could not be moved.
    case MoveFileFail(from: Path, to: Path)

    /// A file could not be copied.
    case CopyFileFail(from: Path, to: Path)

    /// One or many attributes could not be changed.
    case AttributesChangeFail(path: Path)
}

// MARK: - CustomStringConvertible

extension FileKitError : CustomStringConvertible {

    public var description: String {
        var result = "\(self.dynamicType)"
        if let label = Mirror(reflecting: self).children.first?.label {
            result += ".\(label)"
        }
        return "\(result)(\"\(message)\")"
    }

}
