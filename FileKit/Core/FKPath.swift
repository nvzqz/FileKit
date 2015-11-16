//
//  FKPath.swift
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
/// An FKPath instance lets you manage files in a much easier way.
///
public struct FKPath: StringLiteralConvertible,
                      RawRepresentable,
                      Hashable,
                      Indexable,
                      CustomStringConvertible,
                      CustomDebugStringConvertible {
    
    // MARK: - FKPath
    
    /// The `NSFileManager` used by `FKPath`
    public static var FileManager = NSFileManager.defaultManager()
    
    /// The standard separator for path components.
    public static let Separator = "/"
    
    /// The path of the program's current working directory.
    public static var Current: FKPath {
        get {
            return FKPath(FKPath.FileManager.currentDirectoryPath)
        }
        set {
            FKPath.FileManager.changeCurrentDirectoryPath(newValue.rawValue)
        }
    }
    
    // The path of the mounted volumes available.
    public static func Volumes(options: NSVolumeEnumerationOptions = []) -> [FKPath] {
        let volumes = FKPath.FileManager.mountedVolumeURLsIncludingResourceValuesForKeys(nil, options: options) ?? []
        return volumes.map { FKPath(url: $0) }.flatMap { $0 }
    }

    /// The stored path string value.
    public private(set) var rawValue: String
    
    /// The components of the path.
    public var components: [FKPath] {
        var result = [FKPath]()
        for (index, component) in (rawValue as NSString).pathComponents.enumerate()
        {
            if index == 0 || component != "/" {
                result.append(FKPath(component))
            }
        }
        return result
    }
    
    /// A new path created by removing extraneous components from the path.
    public var standardized: FKPath {
        return FKPath((self.rawValue as NSString).stringByStandardizingPath)
    }
    
    /// A new path created by resolving all symlinks and standardizing the path.
    public var resolved: FKPath {
        return FKPath((self.rawValue as NSString).stringByResolvingSymlinksInPath)
    }
    
    /// A new path created by making the path absolute.
    ///
    /// If the path begins with "`/`", then the standardized path is returned.
    /// Otherwise, the path is assumed to be relative to the current working
    /// directory and the standardized version of the path added to the current
    /// working directory is returned.
    ///
    public var absolute: FKPath {
        return self.isAbsolute
            ? self.standardized
            : (FKPath.Current + self).standardized
    }
    
    /// Returns `true` if the path is equal to "`/`".
    public var isRoot: Bool {
        return rawValue == FKPath.Separator
    }

    /// Returns `true` if the path begins with "`/`".
    public var isAbsolute: Bool {
        return rawValue.hasPrefix(FKPath.Separator)
    }
    
    /// Returns `true` if the path does not begin with "`/`".
    public var isRelative: Bool {
        return !isAbsolute
    }
    
    /// Returns `true` if a file exists at the path.
    public var exists: Bool {
        return FKPath.FileManager.fileExistsAtPath(rawValue)
    }
    
    /// Returns `true` if the current process has write privileges for the file at the path.
    public var isWritable: Bool {
        return FKPath.FileManager.isWritableFileAtPath(rawValue)
    }
    
    /// Returns `true` if the current process has read privileges for the file at the path.
    public var isReadable: Bool {
        return FKPath.FileManager.isReadableFileAtPath(rawValue)
    }
    
    /// Returns `true` if the current process has execute privileges for the file at the path.
    public var isExecutable: Bool {
        return  FKPath.FileManager.isExecutableFileAtPath(rawValue)
    }

    /// Returns `true` if the current process has delete privileges for the file at the path.
    public var isDeletable: Bool {
        return  FKPath.FileManager.isDeletableFileAtPath(rawValue)
    }

    /// Returns `true` if the path points to a directory.
    public var isDirectory: Bool {
        var isDirectory: ObjCBool = false
        return FKPath.FileManager
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
    public var parent: FKPath {
        return FKPath((rawValue as NSString).stringByDeletingLastPathComponent)
    }

    /// Initializes a path to "`/`".
    public init() {
        rawValue = "/"
    }
    
    /// Initializes a path to the string's value.
    public init(_ path: String) {
        self.rawValue = path
    }

    /// Returns the path's children paths.
    ///
    /// - Parameter recursive: Whether to obtain the paths recursively.
    ///                        Default value is `false`.
    public func children(recursive recursive: Bool = false) -> [FKPath] {
        let obtainFunc = recursive
            ? FKPath.FileManager.subpathsOfDirectoryAtPath
            : FKPath.FileManager.contentsOfDirectoryAtPath
        return (try? obtainFunc(rawValue))?.map { self + FKPath($0) } ?? []
    }

    /// Returns true if `path` is a child of `self`.
    ///
    /// - Parameter recursive: Whether to check the paths recursively.
    ///                        Default value is `true`.
    public func isChildOfPath(path: FKPath, recursive: Bool = true) -> Bool {
        if recursive {
            return path.isAncestorOfPath(self)
        }
        else  {
            return path.parent == self
        }
    }

    /// Returns true if `path` is a parent of `self`.
    public func isAncestorOfPath(path: FKPath) -> Bool {
        if self.parent == path {
            return true
        }
        if self.isRoot || self.rawValue.isEmpty {
            return false
        }
        return self.parent.isAncestorOfPath(path)
    }

    /// Find paths in `self` that match a condition.
    ///
    /// - Parameters:
    ///     - searchDepth: How deep to search before exiting.
    ///     - condition: If `true`, the path is added.
    ///
    public func findPaths(searchDepth depth: Int, condition: (FKPath) -> Bool) -> [FKPath] {
        var paths = [FKPath]()
        for child in self.children() {
            if condition(child) {
                paths.append(child)
            } else if depth != 0 {
                paths += child.findPaths(searchDepth: depth - 1, condition: condition)
            }
        }
        return paths
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
    /// - Throws: `FKError.FileDoesNotExist`, `FKError.CreateSymlinkFail`
    ///
    public func symlinkFileToPath(var path: FKPath) throws {
        if self.exists {
            if path.exists && !path.isDirectory {
                throw FKError.CreateSymlinkFail(from: self, to: path)
            } else if path.isDirectory && !self.isDirectory {
                path += self.components.last!
            }
            do {
                let manager = FKPath.FileManager
                try manager.createSymbolicLinkAtPath(
                    path.rawValue, withDestinationPath: self.rawValue)
            } catch {
                throw FKError.CreateSymlinkFail(from: self, to: path)
            }
        } else {
            throw FKError.FileDoesNotExist(path: self)
        }
    }
    
    /// Creates a file at path.
    ///
    /// Throws an error if the file cannot be created.
    ///
    /// - Throws: `FKError.CreateFileFail`
    ///
    public func createFile() throws {
        let manager = FKPath.FileManager
        if !manager.createFileAtPath(rawValue, contents: nil, attributes: nil) {
            throw FKError.CreateFileFail(path: self)
        }
    }

    /// Creates a file at path if not exist 
    /// or update the modification date.
    ///
    /// Throws an error if the file cannot be created
    /// or if modification date could not be modified.
    ///
    /// - Throws: `FKError.CreateFileFail` or `FKError.AttributesChangeFail`
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
    /// - Throws: `FKError.CreateFileFail`
    ///
    public func createDirectory() throws {
        do {
            let manager = FKPath.FileManager
            try manager.createDirectoryAtPath(
                rawValue, withIntermediateDirectories: true, attributes: nil)
        } catch {
            throw FKError.CreateFileFail(path: self)
        }
    }
    
    /// Deletes the file or directory at the path.
    ///
    /// Throws an error if the file or directory cannot be deleted.
    ///
    /// - Throws: `FKError.DeleteFileFail`
    ///
    public func deleteFile() throws {
        do {
            try FKPath.FileManager.removeItemAtPath(rawValue)
        } catch {
            throw FKError.DeleteFileFail(path: self)
        }
    }
    
    /// Moves the file at `self` to a path.
    ///
    /// Throws an error if the file cannot be moved.
    ///
    /// - Throws: `FKError.FileDoesNotExist`, `FKError.MoveFileFail`
    ///
    public func moveFileToPath(path: FKPath) throws {
        if self.exists {
            if !path.exists {
                do {
                    try FKPath.FileManager.moveItemAtPath(self.rawValue, toPath: path.rawValue)
                } catch {
                    throw FKError.MoveFileFail(from: self, to: path)
                }
            } else {
                throw FKError.MoveFileFail(from: self, to: path)
            }
        } else {
            throw FKError.FileDoesNotExist(path: self)
        }
    }
    
    /// Copies the file at `self` to a path.
    ///
    /// Throws an error if the file at `self` could not be copied or if a file
    /// already exists at the destination path.
    ///
    /// - Throws: `FKError.FileDoesNotExist`, `FKError.CopyFileFail`
    ///
    public func copyFileToPath(path: FKPath) throws {
        if self.exists {
            if !path.exists {
                do {
                    try FKPath.FileManager.copyItemAtPath(self.rawValue, toPath: path.rawValue)
                } catch {
                    throw FKError.CopyFileFail(from: self, to: path)
                }
            } else {
                throw FKError.CopyFileFail(from: self, to: path)
            }
        } else {
            throw FKError.FileDoesNotExist(path: self)
        }
    }

    // MARK: - Attributes

    /// Returns the path's attributes.
    public var attributes: [String : AnyObject] {
        return (try? FKPath.FileManager.attributesOfItemAtPath(rawValue)) ?? [:]
    }
    
    /// Modify attributes
    private func setAttributes(attributes: [String : AnyObject]) throws {
        do {
            try FKPath.FileManager.setAttributes(attributes, ofItemAtPath: self.rawValue)
        }
        catch {
            throw FKError.AttributesChangeFail(path: self)
        }
    }
    
    // Modify one attribute
    private func setAttribute(key: String, value : AnyObject) throws {
        try setAttributes([key:value])
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

    /// The type of the file at the path.
    public var fileType: FileType? {
        if let value = attributes[NSFileType] as? String {
            return FileType(rawValue: value)
        }
        return nil
    }

    // MARK: - FKPath.FileType

    public enum FileType: String {

        case Directory
        case Regular
        case SymbolicLink
        case Socket
        case CharacterSpecial
        case BlockSpecial
        case Unknown

        public init?(rawValue: String) {
            switch rawValue {
            case NSFileTypeDirectory:        self = .Directory
            case NSFileTypeRegular:          self = .Regular
            case NSFileTypeSymbolicLink:     self = .SymbolicLink
            case NSFileTypeSocket:           self = .Socket
            case NSFileTypeCharacterSpecial: self = .CharacterSpecial
            case NSFileTypeBlockSpecial:     self = .BlockSpecial
            case NSFileTypeUnknown:          self = .Unknown
            default:                         return nil
            }
        }

        public var rawValue: String {
            switch self {
            case .Directory:
                return NSFileTypeDirectory
            case .Regular:
                return NSFileTypeRegular
            case .SymbolicLink:
                return NSFileTypeSymbolicLink
            case .Socket:
                return NSFileTypeSocket
            case .CharacterSpecial:
                return NSFileTypeCharacterSpecial
            case .BlockSpecial:
                return NSFileTypeBlockSpecial
            case .Unknown:
                return NSFileTypeUnknown
            }
        }

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
    public subscript(index: Int) -> FKPath {
        if index < 0 || index >= components.count {
            fatalError("FKPath index out of range")
        } else {
            var result = components.first!
            for i in 1 ..< index + 1 {
                result += components[i]
            }
            return result
        }
    }
    
    // MARK: - CustomStringConvertible
    
    /// A textual representation of `self`.
    public var description: String {
        return rawValue
    }
    
    // MARK: - CustomDebugStringConvertible
    
    /// A textual representation of `self`, suitable for debugging.
    public var debugDescription: String {
        return String(self.dynamicType) + ": " + rawValue.debugDescription
    }
    
    // MARK: - NSURL
    public init?(url: NSURL) {
        if let path = url.path where url.fileURL {
            rawValue = path
        }
        else {
            return nil
        }
    }
    
    public var url: NSURL? {
        return NSURL(fileURLWithPath: rawValue, isDirectory: self.isDirectory)
    }

    // MARK: - BookmarkData
    public init?(bookmarkData bookData : NSData) {
        var isStale : ObjCBool = false
        if let fullURL = try? NSURL(byResolvingBookmarkData: bookData, options: [], relativeToURL: nil, bookmarkDataIsStale: &isStale ) {
            self.init(url:fullURL)
        } else {
            return nil
        }
    }
    
    public var bookmarkData : NSData? {
        if let url = self.url {
            do {
                return try url.bookmarkDataWithOptions(NSURLBookmarkCreationOptions.SuitableForBookmarkFile,
                    includingResourceValuesForKeys:nil, relativeToURL:nil)
            } catch {
                return nil
            }
        }
        return nil
    }
    
}

// MARK: - Equatable

extension FKPath : Equatable {}

// MARK: - SequenceType

extension FKPath : SequenceType {
    public struct FKDirectoryEnumerator : GeneratorType {
        public typealias Element = FKPath

        let path: FKPath
        let directoryEnumerator: NSDirectoryEnumerator

        init(path: FKPath) {
            self.path = path
            self.directoryEnumerator = FKPath.FileManager.enumeratorAtPath(path.rawValue)!
        }

        public func next() -> FKPath? {
            if let next = directoryEnumerator.nextObject() as? String {
                return path + FKPath(next)
            }
            return nil
        }

        public func skipDescendants() {
            directoryEnumerator.skipDescendants()
        }
    }

    public func generate() -> FKDirectoryEnumerator {
        return FKDirectoryEnumerator(path: self)
    }
}

// MARK: - FKPaths

extension FKPath {
    
    /// Returns the path to the user's or application's home directory,
    /// depending on the platform.
    public static var UserHome: FKPath {
        return FKPath(NSHomeDirectory())
    }
    
    /// Returns the path to the user's temporary directory.
    public static var UserTemporary: FKPath {
        return FKPath(NSTemporaryDirectory())
    }
    
    public static var ProcessTemporary: FKPath {
        return FKPath.UserTemporary + NSProcessInfo.processInfo().globallyUniqueString
    }
    
    public static var UniqueTemporary: FKPath {
        return FKPath.ProcessTemporary + NSUUID().UUIDString
    }
    
    /// Returns the path to the user's caches directory.
    public static var UserCaches: FKPath {
        return pathInUserDomain(.CachesDirectory)
    }
    
    #if os(OSX)
    
    /// Returns the path to the user's applications directory.
    public static var UserApplications: FKPath {
        return pathInUserDomain(.ApplicationDirectory)
    }
    
    /// Returns the path to the user's application support directory.
    public static var UserApplicationSupport: FKPath {
        return pathInUserDomain(.ApplicationSupportDirectory)
    }
    
    /// Returns the path to the user's desktop directory.
    public static var UserDesktop: FKPath {
        return pathInUserDomain(.DesktopDirectory)
    }
    
    /// Returns the path to the user's documents directory.
    public static var UserDocuments: FKPath {
        return pathInUserDomain(.DocumentDirectory)
    }
    
    /// Returns the path to the user's downloads directory.
    public static var UserDownloads: FKPath {
        return pathInUserDomain(.DownloadsDirectory)
    }
    
    /// Returns the path to the user's library directory.
    public static var UserLibrary: FKPath {
        return pathInUserDomain(.LibraryDirectory)
    }
    
    /// Returns the path to the user's movies directory.
    public static var UserMovies: FKPath {
        return pathInUserDomain(.MoviesDirectory)
    }
    
    /// Returns the path to the user's music directory.
    public static var UserMusic: FKPath {
        return pathInUserDomain(.MusicDirectory)
    }
    
    /// Returns the path to the user's pictures directory.
    public static var UserPictures: FKPath {
        return pathInUserDomain(.PicturesDirectory)
    }
    
    /// Returns the path to the system's applications directory.
    public static var SystemApplications: FKPath {
        return pathInSystemDomain(.ApplicationDirectory)
    }
    
    /// Returns the path to the system's application support directory.
    public static var SystemApplicationSupport: FKPath {
        return pathInSystemDomain(.ApplicationSupportDirectory)
    }
    
    /// Returns the path to the system's library directory.
    public static var SystemLibrary: FKPath {
        return pathInSystemDomain(.LibraryDirectory)
    }
    
    /// Returns the path to the system's core services directory.
    public static var SystemCoreServices: FKPath {
        return pathInSystemDomain(.CoreServiceDirectory)
    }
    
    #endif
    
    private static func pathInUserDomain(directory: NSSearchPathDirectory) -> FKPath {
        return pathsInDomains(directory, .UserDomainMask)[0]
    }
    
    private static func pathInSystemDomain(directory: NSSearchPathDirectory) -> FKPath {
        return pathsInDomains(directory, .SystemDomainMask)[0]
    }
    
    private static func pathsInDomains(directory: NSSearchPathDirectory,
        _ domainMask: NSSearchPathDomainMask) -> [FKPath] {
            let paths = NSSearchPathForDirectoriesInDomains(directory, domainMask, true)
            return paths.map { FKPath($0) }
    }
    
}


