//
//  Operators.swift
//  FileKit
//
//  The MIT License (MIT)
//
//  Copyright (c) 2015-2017 Nikolai Vazquez
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

// swiftlint:disable file_length

import Foundation

fileprivate func < <T: Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

// MARK: - File

/// Returns `true` if both files' paths are the same.

public func ==<DataType: ReadableWritable>(lhs: File<DataType>, rhs: File<DataType>) -> Bool {
    return lhs.path == rhs.path
}

/// Returns `true` if `lhs` is smaller than `rhs` in size.

public func < <DataType: ReadableWritable>(lhs: File<DataType>, rhs: File<DataType>) -> Bool {
    return lhs.size < rhs.size
}

infix operator |>

/// Writes data to a file.
///
/// - Throws: `FileKitError.WriteToFileFail`
///
public func |> <DataType: ReadableWritable>(data: DataType, file: File<DataType>) throws {
    try file.write(data)
}

// MARK: - TextFile

/// Returns `true` if both text files have the same path and encoding.

public func == (lhs: TextFile, rhs: TextFile) -> Bool {
    return lhs.path == rhs.path && lhs.encoding == rhs.encoding
}

infix operator |>>

/// Appends a string to a text file.
///
/// If the text file can't be read from, such in the case that it doesn't exist,
/// then it will try to write the data directly to the file.
///
/// - Throws: `FileKitError.WriteToFileFail`
///
public func |>> (data: String, file: TextFile) throws {
    // TODO use TextFileStreamWritter
    var data = data
    if let contents = try? file.read() {
        data = contents + "\n" + data
    }
    try data |> file
}

/// Return lines of file that match the motif.

public func | (file: TextFile, motif: String) -> [String] {
    return file.grep(motif)
}

infix operator |-
/// Return lines of file that does'nt match the motif.

public func |- (file: TextFile, motif: String) -> [String] {
    return file.grep(motif, include: false)
}

infix operator |~
/// Return lines of file that match the regex motif.

public func |~ (file: TextFile, motif: String) -> [String] {
    return file.grep(motif, options: NSString.CompareOptions.regularExpression)
}

// MARK: - Path

/// Returns `true` if the standardized form of one path equals that of another
/// path.

public func == (lhs: Path, rhs: Path) -> Bool {
    if lhs.isAbsolute || rhs.isAbsolute {
        return lhs.absolute.rawValue == rhs.absolute.rawValue
    }
    return lhs.standardRawValueWithTilde == rhs.standardRawValueWithTilde
}

/// Returns `true` if the standardized form of one path not equals that of another
/// path.

public func != (lhs: Path, rhs: Path) -> Bool {
    return !(lhs == rhs)
}

/// Concatenates two `Path` instances and returns the result.
///
/// ```swift
/// let systemLibrary: Path = "/System/Library"
/// print(systemLib + "Fonts")  // "/System/Library/Fonts"
/// ```
///

public func + (lhs: Path, rhs: Path) -> Path {
    if lhs.rawValue.isEmpty || lhs.rawValue == "." { return rhs }
    if rhs.rawValue.isEmpty || rhs.rawValue == "." { return lhs }
    switch (lhs.rawValue.hasSuffix(Path.separator), rhs.rawValue.hasPrefix(Path.separator)) {
    case (true, true):
        let rhsRawValue = rhs.rawValue.substring(from: rhs.rawValue.characters.index(after: rhs.rawValue.startIndex))
        return Path("\(lhs.rawValue)\(rhsRawValue)")
    case (false, false):
        return Path("\(lhs.rawValue)\(Path.separator)\(rhs.rawValue)")
    default:
        return Path("\(lhs.rawValue)\(rhs.rawValue)")
    }
}

/// Converts a `String` to a `Path` and returns the concatenated result.

public func + (lhs: String, rhs: Path) -> Path {
    return Path(lhs) + rhs
}

/// Converts a `String` to a `Path` and returns the concatenated result.

public func + (lhs: Path, rhs: String) -> Path {
    return lhs + Path(rhs)
}

/// Appends the right path to the left path.
public func += (lhs: inout Path, rhs: Path) {
    lhs = lhs + rhs
}

/// Appends the path value of the String to the left path.
public func += (lhs: inout Path, rhs: String) {
    lhs = lhs + rhs
}

/// Concatenates two `Path` instances and returns the result.

public func / (lhs: Path, rhs: Path) -> Path {
    return lhs + rhs
}

/// Converts a `String` to a `Path` and returns the concatenated result.

public func / (lhs: Path, rhs: String) -> Path {
    return lhs + rhs
}

/// Converts a `String` to a `Path` and returns the concatenated result.

public func / (lhs: String, rhs: Path) -> Path {
    return lhs + rhs
}

/// Appends the right path to the left path.
public func /= (lhs: inout Path, rhs: Path) {
    lhs += rhs
}

/// Appends the path value of the String to the left path.
public func /= (lhs: inout Path, rhs: String) {
    lhs += rhs
}

precedencegroup FileCommonAncestorPrecedence {
    associativity: left
}

infix operator <^> : FileCommonAncestorPrecedence

/// Returns the common ancestor between the two paths.

public func <^> (lhs: Path, rhs: Path) -> Path {
    return lhs.commonAncestor(rhs)
}

infix operator </>

/// Runs `closure` with the path as its current working directory.
public func </> (path: Path, closure: () throws -> Void) rethrows {
    try path.changeDirectory(closure)
}

infix operator ->>

/// Moves the file at the left path to a path.
///
/// Throws an error if the file at the left path could not be moved or if a file
/// already exists at the right path.
///
/// - Throws: `FileKitError.FileDoesNotExist`, `FileKitError.MoveFileFail`
///
public func ->> (lhs: Path, rhs: Path) throws {
    try lhs.moveFile(to: rhs)
}

/// Moves a file to a path.
///
/// Throws an error if the file could not be moved or if a file already
/// exists at the destination path.
///
/// - Throws: `FileKitError.FileDoesNotExist`, `FileKitError.MoveFileFail`
///
public func ->> <DataType: ReadableWritable>(lhs: File<DataType>, rhs: Path) throws {
    try lhs.move(to: rhs)
}

infix operator ->!

/// Forcibly moves the file at the left path to the right path.
///
/// - Warning: If a file at the right path already exists, it will be deleted.
///
/// - Throws:
///     `FileKitError.DeleteFileFail`,
///     `FileKitError.FileDoesNotExist`,
///     `FileKitError.CreateSymlinkFail`
///
public func ->! (lhs: Path, rhs: Path) throws {
    if rhs.isAny {
        try rhs.deleteFile()
    }
    try lhs ->> rhs
}

/// Forcibly moves a file to a path.
///
/// - Warning: If a file at the right path already exists, it will be deleted.
///
/// - Throws:
///     `FileKitError.DeleteFileFail`,
///     `FileKitError.FileDoesNotExist`,
///     `FileKitError.CreateSymlinkFail`
///
public func ->! <DataType: ReadableWritable>(lhs: File<DataType>, rhs: Path) throws {
    if rhs.isAny {
        try rhs.deleteFile()
    }
    try lhs ->> rhs
}

infix operator +>>

/// Copies the file at the left path to the right path.
///
/// Throws an error if the file at the left path could not be copied or if a file
/// already exists at the right path.
///
/// - Throws: `FileKitError.FileDoesNotExist`, `FileKitError.CopyFileFail`
///
public func +>> (lhs: Path, rhs: Path) throws {
    try lhs.copyFile(to: rhs)
}

/// Copies a file to a path.
///
/// Throws an error if the file could not be copied or if a file already
/// exists at the destination path.
///
/// - Throws: `FileKitError.FileDoesNotExist`, `FileKitError.CopyFileFail`
///
public func +>> <DataType: ReadableWritable>(lhs: File<DataType>, rhs: Path) throws {
    try lhs.copy(to: rhs)
}

infix operator +>!

/// Forcibly copies the file at the left path to the right path.
///
/// - Warning: If a file at the right path already exists, it will be deleted.
///
/// - Throws:
///     `FileKitError.DeleteFileFail`,
///     `FileKitError.FileDoesNotExist`,
///     `FileKitError.CreateSymlinkFail`
///
public func +>! (lhs: Path, rhs: Path) throws {
    if rhs.isAny {
        try rhs.deleteFile()
    }
    try lhs +>> rhs
}

/// Forcibly copies a file to a path.
///
/// - Warning: If a file at the right path already exists, it will be deleted.
///
/// - Throws:
///     `FileKitError.DeleteFileFail`,
///     `FileKitError.FileDoesNotExist`,
///     `FileKitError.CreateSymlinkFail`
///
public func +>! <DataType: ReadableWritable>(lhs: File<DataType>, rhs: Path) throws {
    if rhs.isAny {
        try rhs.deleteFile()
    }
    try lhs +>> rhs
}

infix operator =>>

/// Creates a symlink of the left path at the right path.
///
/// If the symbolic link path already exists and _is not_ a directory, an
/// error will be thrown and a link will not be created.
///
/// If the symbolic link path already exists and _is_ a directory, the link
/// will be made to a file in that directory.
///
/// - Throws:
///     `FileKitError.FileDoesNotExist`,
///     `FileKitError.CreateSymlinkFail`
///
public func =>> (lhs: Path, rhs: Path) throws {
    try lhs.symlinkFile(to: rhs)
}

/// Symlinks a file to a path.
///
/// If the path already exists and _is not_ a directory, an error will be
/// thrown and a link will not be created.
///
/// If the path already exists and _is_ a directory, the link will be made
/// to the file in that directory.
///
/// - Throws: `FileKitError.FileDoesNotExist`, `FileKitError.CreateSymlinkFail`
///
public func =>> <DataType: ReadableWritable>(lhs: File<DataType>, rhs: Path) throws {
    try lhs.symlink(to: rhs)
}

infix operator =>!

/// Forcibly creates a symlink of the left path at the right path by deleting
/// anything at the right path before creating the symlink.
///
/// - Warning: If the symbolic link path already exists, it will be deleted.
///
/// - Throws:
///     `FileKitError.DeleteFileFail`,
///     `FileKitError.FileDoesNotExist`,
///     `FileKitError.CreateSymlinkFail`
///
public func =>! (lhs: Path, rhs: Path) throws {
    //    guard lhs.exists else {
    //        throw FileKitError.FileDoesNotExist(path: lhs)
    //    }

    let linkPath = rhs.isDirectory ? rhs + lhs.fileName : rhs
    if linkPath.isAny { try linkPath.deleteFile() }

    try lhs =>> rhs
}

/// Forcibly creates a symlink of a file at a path by deleting anything at the
/// path before creating the symlink.
///
/// - Warning: If the path already exists, it will be deleted.
///
/// - Throws:
///     `FileKitError.DeleteFileFail`,
///     `FileKitError.FileDoesNotExist`,
///     `FileKitError.CreateSymlinkFail`
///
public func =>! <DataType: ReadableWritable>(lhs: File<DataType>, rhs: Path) throws {
    try lhs.path =>! rhs
}

postfix operator %

/// Returns the standardized version of the path.

public postfix func % (path: Path) -> Path {
    return path.standardized
}

postfix operator *

/// Returns the resolved version of the path.

public postfix func * (path: Path) -> Path {
    return path.resolved
}

postfix operator ^

/// Returns the path's parent path.

public postfix func ^ (path: Path) -> Path {
    return path.parent
}
