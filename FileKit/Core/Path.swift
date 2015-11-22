//
//  Path.swift
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

/// A representation of a filesystem path.
///
/// An Path instance lets you manage files in a much easier way.
///
public struct Path : StringLiteralConvertible, RawRepresentable, Hashable, Indexable {

    // MARK: - Static Methods and Properties

    /// The `NSFileManager` instance used by `Path`
    public static var fileManager = NSFileManager.defaultManager()

    /// The standard separator for path components.
    public static let separator = "/"

    /// The root path.
    public static let Root = Path(separator)

    /// The path of the program's current working directory.
    public static var Current: Path {
        get {
            return Path(Path.fileManager.currentDirectoryPath)
        }
        set {
            Path.fileManager.changeCurrentDirectoryPath(newValue.rawValue)
        }
    }

    /// The paths of the mounted volumes available.
    public static func volumes(options: NSVolumeEnumerationOptions = []) -> [Path] {
        let volumes = Path.fileManager.mountedVolumeURLsIncludingResourceValuesForKeys(nil, options: options) ?? []
        return volumes.flatMap { Path(URL: $0) }
    }

    // MARK: - Properties

    /// The stored path string value.
    public private(set) var rawValue: String

    /// The components of the path.
    public var components: [Path] {
        var result = [Path]()
        for (index, component) in (rawValue as NSString).pathComponents.enumerate()
        {
            if index == 0 || component != "/" {
                result.append(Path(component))
            }
        }
        return result
    }

    /// A new path created by removing extraneous components from the path.
    public var standardized: Path {
        return Path((self.rawValue as NSString).stringByStandardizingPath)
    }

    /// A new path created by resolving all symlinks and standardizing the path.
    public var resolved: Path {
        return Path((self.rawValue as NSString).stringByResolvingSymlinksInPath)
    }

    /// A new path created by making the path absolute.
    ///
    /// - Returns: If `self` begins with "/", then the standardized path is
    ///            returned. Otherwise, the path is assumed to be relative to
    ///            the current working directory and the standardized version of
    ///            the path added to the current working directory is returned.
    ///
    public var absolute: Path {
        return self.isAbsolute
            ? self.standardized
            : (Path.Current + self).standardized
    }

    /// Returns `true` if the path is equal to "/".
    public var isRoot: Bool {
        return resolved.rawValue == Path.separator
    }

    /// Returns `true` if the path begins with "/".
    public var isAbsolute: Bool {
        return rawValue.hasPrefix(Path.separator)
    }

    /// Returns `true` if the path does not begin with "/".
    public var isRelative: Bool {
        return !isAbsolute
    }

    /// Returns `true` if a file exists at the path.
    public var exists: Bool {
        return Path.fileManager.fileExistsAtPath(rawValue)
    }

    /// Returns `true` if the current process has write privileges for the file
    /// at the path.
    public var isWritable: Bool {
        return Path.fileManager.isWritableFileAtPath(rawValue)
    }

    /// Returns `true` if the current process has read privileges for the file
    /// at the path.
    public var isReadable: Bool {
        return Path.fileManager.isReadableFileAtPath(rawValue)
    }

    /// Returns `true` if the current process has execute privileges for the
    /// file at the path.
    public var isExecutable: Bool {
        return  Path.fileManager.isExecutableFileAtPath(rawValue)
    }

    /// Returns `true` if the current process has delete privileges for the file
    /// at the path.
    public var isDeletable: Bool {
        return  Path.fileManager.isDeletableFileAtPath(rawValue)
    }

    /// Returns `true` if the path points to a directory.
    public var isDirectory: Bool {
        var isDirectory: ObjCBool = false
        return Path.fileManager
            .fileExistsAtPath(rawValue, isDirectory: &isDirectory) && isDirectory
    }

    /// Returns `true` if the path is a symbolic link.
    public var isSymbolicLink: Bool {
        return fileType == .SymbolicLink
    }

    /// The path's extension.
    public var pathExtension: String {
        get {
            return (rawValue as NSString).pathExtension
        }
        set {
            let path = (rawValue as NSString).stringByDeletingPathExtension
            rawValue = path + ".\(newValue)"
        }
    }

    /// The path's parent path.
    public var parent: Path {
        return Path((rawValue as NSString).stringByDeletingLastPathComponent)
    }

    // MARK: - Initialization

    /// Initializes a path to "/".
    public init() {
        rawValue = "/"
    }

    /// Initializes a path to the string's value.
    public init(_ path: String) {
        self.rawValue = path
    }

    // MARK: - Methods

    /// Runs `closure` with `self` as its current working directory.
    ///
    /// - Parameter closure: The block to run while `Path.Current` is changed.
    ///
    public func changeDirectory(@noescape closure: () throws -> ()) rethrows {
        let previous   = Path.Current
        Path.Current = self
        defer { Path.Current = previous }
        try closure()
    }

    /// Returns the path's children paths.
    ///
    /// - Parameter recursive: Whether to obtain the paths recursively.
    ///                        Default value is `false`.
    ///
    public func children(recursive recursive: Bool = false) -> [Path] {
        let obtainFunc = recursive
            ? Path.fileManager.subpathsOfDirectoryAtPath
            : Path.fileManager.contentsOfDirectoryAtPath
        return (try? obtainFunc(rawValue))?.map { self + Path($0) } ?? []
    }

    /// Returns true if `path` is a child of `self`.
    ///
    /// - Parameter recursive: Whether to check the paths recursively.
    ///                        Default value is `true`.
    ///
    public func isChildOfPath(path: Path, recursive: Bool = true) -> Bool {
        if recursive {
            return path.isAncestorOfPath(self)
        }
        else  {
            return path.parent == self
        }
    }

    /// Returns true if `path` is a parent of `self`.
    public func isAncestorOfPath(path: Path) -> Bool {
        if self.parent == path {
            return true
        }
        if self.isRoot || self.rawValue.isEmpty {
            return false
        }
        return self.parent.isAncestorOfPath(path)
    }

    /// Returns the common ancestor between `self` and `path`.
    public func commonAncestor(path: Path) -> Path {
        let selfComponents = self.components
        let pathComponents = path.components

        let total = Swift.min(selfComponents.count, pathComponents.count)

        var index = 0
        for index = 0; index < total; ++index {
            if selfComponents[index].rawValue != pathComponents[index].rawValue {
                break
            }
        }

        let ancestorComponents = selfComponents[0..<index]
        return ancestorComponents.reduce(Path.Root) { $0 + $1 }
    }

    /// Returns paths in `self` that match a condition.
    ///
    /// - Parameter searchDepth: How deep to search before exiting. A negative
    ///                          value will cause the search to exit only when
    ///                          every subdirectory has been searched through.
    ///                          Default value is `-1`.
    /// - Parameter condition: If `true`, the path is added.
    ///
    /// - Returns: An Array containing the paths in `self` that match the
    ///            condition.
    ///
    public func find(searchDepth depth: Int = -1, @noescape condition: (Path) throws -> Bool) rethrows -> [Path] {
        return try self.find(searchDepth: depth) { path in
            try condition(path) ? path : nil
        }
    }

    /// Returns non-nil values for paths found in `self`.
    ///
    /// - Parameter searchDepth: How deep to search before exiting. A negative
    ///                          value will cause the search to exit only when
    ///                          every subdirectory has been searched through.
    ///                          Default value is `-1`.
    /// - Parameter transform: The transform run on each path found.
    ///
    /// - Returns: An Array containing the non-nil values for paths found in
    ///            `self`.
    ///
    public func find<T>(searchDepth depth: Int = -1, @noescape transform: (Path) throws -> T?) rethrows -> [T] {
        return try self.children().reduce([]) { values, child in
            if let value = try transform(child) {
                return values + [value]
            } else if depth != 0 {
                return try values + child.find(searchDepth: depth - 1, transform: transform)
            } else {
                return values
            }
        }
    }

    /// Standardizes the path.
    public mutating func standardize() {
        self = self.standardized
    }

    /// Resolves the path's symlinks and standardizes it.
    public mutating func resolve() {
        self = self.resolved
    }

    /// Creates a symbolic link at a path that points to `self`.
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
    public func symlinkFileToPath(var path: Path) throws {
        if self.exists {
            if path.exists && !path.isDirectory {
                throw FileKitError.CreateSymlinkFail(from: self, to: path)
            } else if path.isDirectory && !self.isDirectory {
                path += self.components.last!
            }
            do {
                let manager = Path.fileManager
                try manager.createSymbolicLinkAtPath(
                    path.rawValue, withDestinationPath: self.rawValue)
            } catch {
                throw FileKitError.CreateSymlinkFail(from: self, to: path)
            }
        } else {
            throw FileKitError.FileDoesNotExist(path: self)
        }
    }

    /// Creates a file at path.
    ///
    /// Throws an error if the file cannot be created.
    ///
    /// - Throws: `FileKitError.CreateFileFail`
    ///
    public func createFile() throws {
        let manager = Path.fileManager
        if !manager.createFileAtPath(rawValue, contents: nil, attributes: nil) {
            throw FileKitError.CreateFileFail(path: self)
        }
    }

    /// Creates a file at path if not exist
    /// or update the modification date.
    ///
    /// Throws an error if the file cannot be created
    /// or if modification date could not be modified.
    ///
    /// - Throws:
    ///     `FileKitError.CreateFileFail`,
    ///     `FileKitError.AttributesChangeFail`
    ///
    public func touch(updateModificationDate : Bool = true) throws {
        if self.exists {
            if updateModificationDate {
                try setAttribute(NSFileModificationDate, value: NSDate())
            }
        }
        else {
            try createFile()
        }
    }

    /// Creates a directory at the path.
    ///
    /// Throws an error if the directory cannot be created.
    ///
    /// - Parameter createIntermediates: If `true`, any non-existent parent
    ///                                  directories are created along with that
    ///                                  of `self`. Default value is `true`.
    ///
    /// - Throws: `FileKitError.CreateDirectoryFail`
    ///
    public func createDirectory(withIntermediateDirectories createIntermediates: Bool = true) throws {
        do {
            let manager = Path.fileManager
            try manager.createDirectoryAtPath(rawValue,
                withIntermediateDirectories: createIntermediates,
                attributes: nil)
        } catch {
            throw FileKitError.CreateDirectoryFail(path: self)
        }
    }

    /// Deletes the file or directory at the path.
    ///
    /// Throws an error if the file or directory cannot be deleted.
    ///
    /// - Throws: `FileKitError.DeleteFileFail`
    ///
    public func deleteFile() throws {
        do {
            try Path.fileManager.removeItemAtPath(rawValue)
        } catch {
            throw FileKitError.DeleteFileFail(path: self)
        }
    }

    /// Moves the file at `self` to a path.
    ///
    /// Throws an error if the file cannot be moved.
    ///
    /// - Throws: `FileKitError.FileDoesNotExist`, `FileKitError.MoveFileFail`
    ///
    public func moveFileToPath(path: Path) throws {
        if self.exists {
            if !path.exists {
                do {
                    try Path.fileManager.moveItemAtPath(self.rawValue, toPath: path.rawValue)
                } catch {
                    throw FileKitError.MoveFileFail(from: self, to: path)
                }
            } else {
                throw FileKitError.MoveFileFail(from: self, to: path)
            }
        } else {
            throw FileKitError.FileDoesNotExist(path: self)
        }
    }

    /// Copies the file at `self` to a path.
    ///
    /// Throws an error if the file at `self` could not be copied or if a file
    /// already exists at the destination path.
    ///
    /// - Throws: `FileKitError.FileDoesNotExist`, `FileKitError.CopyFileFail`
    ///
    public func copyFileToPath(path: Path) throws {
        if self.exists {
            if !path.exists {
                do {
                    try Path.fileManager.copyItemAtPath(self.rawValue, toPath: path.rawValue)
                } catch {
                    throw FileKitError.CopyFileFail(from: self, to: path)
                }
            } else {
                throw FileKitError.CopyFileFail(from: self, to: path)
            }
        } else {
            throw FileKitError.FileDoesNotExist(path: self)
        }
    }

    // MARK: - Attributes

    /// Returns the path's attributes.
    public var attributes: [String : AnyObject] {
        return (try? Path.fileManager.attributesOfItemAtPath(rawValue)) ?? [:]
    }

    /// Modify attributes
    private func setAttributes(attributes: [String : AnyObject]) throws {
        do {
            try Path.fileManager.setAttributes(attributes, ofItemAtPath: self.rawValue)
        }
        catch {
            throw FileKitError.AttributesChangeFail(path: self)
        }
    }

    /// Modify one attribute
    private func setAttribute(key: String, value: AnyObject) throws {
        try setAttributes([key : value])
    }

    /// The creation date of the file at the path.
    public var creationDate: NSDate? {
        return attributes[NSFileCreationDate] as? NSDate
    }

    /// The modification date of the file at the path.
    public var modificationDate: NSDate? {
        return attributes[NSFileModificationDate] as? NSDate
    }

    /// The name of the owner of the file at the path.
    public var ownerName: String? {
        return attributes[NSFileOwnerAccountName] as? String
    }

    /// The ID of the owner of the file at the path.
    public var ownerID: UInt? {
        if let value = attributes[NSFileOwnerAccountID] as? NSNumber {
            return value.unsignedLongValue
        }
        return nil
    }

    /// The group name of the owner of the file at the path.
    public var groupName: String? {
        return attributes[NSFileGroupOwnerAccountName] as? String
    }

    /// The group ID of the owner of the file at the path.
    public var groupID: UInt? {
        if let value = attributes[NSFileGroupOwnerAccountID] as? NSNumber {
            return value.unsignedLongValue
        }
        return nil
    }

    /// Indicates whether the extension of the file at the path is hidden.
    public var extensionIsHidden: Bool? {
        if let value = attributes[NSFileExtensionHidden] as? NSNumber {
            return value.boolValue
        }
        return nil
    }

    /// The POSIX permissions of the file at the path.
    public var posixPermissions: Int16? {
        if let value = attributes[NSFilePosixPermissions] as? NSNumber {
            return value.shortValue
        }
        return nil
    }

    /// The number of hard links to a file.
    public var fileReferenceCount: UInt? {
        if let value = attributes[NSFileReferenceCount] as? NSNumber {
            return value.unsignedLongValue
        }
        return nil
    }

    /// The size of the file at the path in bytes.
    public var fileSize: UInt64? {
        if let value = attributes[NSFileSize] as? NSNumber {
            return value.unsignedLongLongValue
        }
        return nil
    }

    /// The filesystem number of the file at the path.
    public var filesystemFileNumber: UInt? {
        if let value = attributes[NSFileSystemFileNumber] as? NSNumber {
            return value.unsignedLongValue
        }
        return nil
    }

    // MARK: - FileType

    /// The FileType attribute for the file at the path.
    public var fileType: FileType? {
        guard let value = attributes[NSFileType] as? String else {
            return nil
        }
        return FileType(rawValue: value)
    }

    // MARK: - StringLiteralConvertible

    public typealias ExtendedGraphemeClusterLiteralType = StringLiteralType

    public typealias UnicodeScalarLiteralType = StringLiteralType

    /// Initializes a path to the literal.
    public init(extendedGraphemeClusterLiteral value: ExtendedGraphemeClusterLiteralType) {
        self.rawValue = value
    }

    /// Initializes a path to the literal.
    public init(stringLiteral value: StringLiteralType) {
        self.rawValue = value
    }

    /// Initializes a path to the literal.
    public init(unicodeScalarLiteral value: UnicodeScalarLiteralType) {
        self.rawValue = value
    }

    // MARK: - RawRepresentable

    /// Initializes a path to the string value.
    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    // MARK: - Hashable

    /// The hash value of the path.
    public var hashValue: Int {
        return rawValue.hashValue
    }

    // MARK: - Indexable

    /// The path's start index.
    public var startIndex: Int {
        return components.startIndex
    }

    /// The path's end index; the successor of the last valid subscript argument.
    public var endIndex: Int {
        return components.endIndex
    }

    /// The path's subscript. (read-only)
    ///
    /// - Returns: All of the path's elements up to and including the index.
    ///
    public subscript(index: Int) -> Path {
        if index < 0 || index >= components.count {
            fatalError("Path index out of range")
        } else {
            var result = components.first!
            for i in 1 ..< index + 1 {
                result += components[i]
            }
            return result
        }
    }

    // MARK: - NSURL

    public init?(URL: NSURL) {
        guard let path = URL.path where URL.fileURL
            else { return nil }
        rawValue = path
    }

    public var URL: NSURL {
        return NSURL(fileURLWithPath: rawValue, isDirectory: self.isDirectory)
    }

    // MARK: - BookmarkData

    public init?(bookmarkData bookData : NSData) {
        var isStale : ObjCBool = false
        guard let fullURL = try? NSURL(byResolvingBookmarkData: bookData, options: [], relativeToURL: nil, bookmarkDataIsStale: &isStale)
            else { return nil }
        self.init(URL: fullURL)
    }

    public var bookmarkData : NSData? {
        return try? self.URL.bookmarkDataWithOptions(.SuitableForBookmarkFile, includingResourceValuesForKeys: nil, relativeToURL: nil)
    }

    // MARK: - NSFileHandle

    /// Returns a file handle for reading the file at `self`, or `nil` if no
    /// file exists at `self`.
    public var fileHandleForReading: NSFileHandle? {
        return NSFileHandle(forReadingAtPath: rawValue)
    }

    /// Returns a file handle for writing to the file at `self`, or `nil` if no
    /// file exists at `self`.
    public var fileHandleForWriting: NSFileHandle? {
        return NSFileHandle(forWritingAtPath: rawValue)
    }

    /// Returns a file handle for reading and writing to the file at `self`, or
    /// `nil` if no file exists at `self`.
    public var fileHandleForUpdating: NSFileHandle? {
        return NSFileHandle(forUpdatingAtPath: rawValue)
    }

    // MARK: - NSStream

    /// Returns an input stream that reads data from the file at `self`, or
    /// `nil` if no file exists at `self`.
    public func inputStream() -> NSInputStream? {
        return NSInputStream(fileAtPath: rawValue)
    }

    /// Returns an output stream for writing to the file at `self`, or `nil` if
    /// no file exists at `self`.
    ///
    /// - Parameter shouldAppend: `true` if newly written data should be
    ///                           appended to any existing file contents,
    ///                           `false` otherwise. Default value is `false`.
    ///
    public func outputStream(append shouldAppend: Bool = false) -> NSOutputStream? {
        return NSOutputStream(toFileAtPath: rawValue, append: shouldAppend)
    }

}

// MARK: - StringInterpolationConvertible

extension Path : StringInterpolationConvertible {

    /// Initializes a path from the string interpolation paths.
    public init(stringInterpolation paths: Path...) {
        self.init(paths.reduce("", combine: { $0 + $1.rawValue }))
    }

    /// Initializes a path from the string interpolation segment.
    public init<T>(stringInterpolationSegment expr: T) {
        if let path = expr as? Path {
            self = path
        } else {
            self = Path(String(expr))
        }
    }

}

// MARK: - CustomStringConvertible

extension Path : CustomStringConvertible {
    /// A textual representation of `self`.
    public var description: String {
        return rawValue
    }
}

// MARK: - CustomDebugStringConvertible

extension Path : CustomDebugStringConvertible {
    /// A textual representation of `self`, suitable for debugging.
    public var debugDescription: String {
        return "Path(\(rawValue.debugDescription))"
    }
}

extension Path : SequenceType {

    // MARK: - SequenceType

    public func generate() -> DirectoryEnumerator {
        return DirectoryEnumerator(path: self)
    }
}


extension Path {

    // MARK: - Paths

    /// Returns the path to the user's or application's home directory,
    /// depending on the platform.
    public static var UserHome: Path {
        return Path(NSHomeDirectory())
    }

    /// Returns the path to the user's temporary directory.
    public static var UserTemporary: Path {
        return Path(NSTemporaryDirectory())
    }

    public static var ProcessTemporary: Path {
        return Path.UserTemporary + NSProcessInfo.processInfo().globallyUniqueString
    }

    public static var UniqueTemporary: Path {
        return Path.ProcessTemporary + NSUUID().UUIDString
    }

    /// Returns the path to the user's caches directory.
    public static var UserCaches: Path {
        return pathInUserDomain(.CachesDirectory)
    }

    #if os(OSX)

    /// Returns the path to the user's applications directory.
    public static var UserApplications: Path {
        return pathInUserDomain(.ApplicationDirectory)
    }

    /// Returns the path to the user's application support directory.
    public static var UserApplicationSupport: Path {
        return pathInUserDomain(.ApplicationSupportDirectory)
    }

    /// Returns the path to the user's desktop directory.
    public static var UserDesktop: Path {
        return pathInUserDomain(.DesktopDirectory)
    }

    /// Returns the path to the user's documents directory.
    public static var UserDocuments: Path {
        return pathInUserDomain(.DocumentDirectory)
    }

    /// Returns the path to the user's downloads directory.
    public static var UserDownloads: Path {
        return pathInUserDomain(.DownloadsDirectory)
    }

    /// Returns the path to the user's library directory.
    public static var UserLibrary: Path {
        return pathInUserDomain(.LibraryDirectory)
    }

    /// Returns the path to the user's movies directory.
    public static var UserMovies: Path {
        return pathInUserDomain(.MoviesDirectory)
    }

    /// Returns the path to the user's music directory.
    public static var UserMusic: Path {
        return pathInUserDomain(.MusicDirectory)
    }

    /// Returns the path to the user's pictures directory.
    public static var UserPictures: Path {
        return pathInUserDomain(.PicturesDirectory)
    }

    /// Returns the path to the system's applications directory.
    public static var SystemApplications: Path {
        return pathInSystemDomain(.ApplicationDirectory)
    }

    /// Returns the path to the system's application support directory.
    public static var SystemApplicationSupport: Path {
        return pathInSystemDomain(.ApplicationSupportDirectory)
    }

    /// Returns the path to the system's library directory.
    public static var SystemLibrary: Path {
        return pathInSystemDomain(.LibraryDirectory)
    }

    /// Returns the path to the system's core services directory.
    public static var SystemCoreServices: Path {
        return pathInSystemDomain(.CoreServiceDirectory)
    }

    #endif

    private static func pathInUserDomain(directory: NSSearchPathDirectory) -> Path {
        return pathsInDomains(directory, .UserDomainMask)[0]
    }

    private static func pathInSystemDomain(directory: NSSearchPathDirectory) -> Path {
        return pathsInDomains(directory, .SystemDomainMask)[0]
    }

    private static func pathsInDomains(directory: NSSearchPathDirectory, _ domainMask: NSSearchPathDomainMask) -> [Path] {
        return NSSearchPathForDirectoriesInDomains(directory, domainMask, true).map {
            Path($0)
        }
    }

}
