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
import CoreLocation

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
    
    /// The standard separator for path components.
    public static let Separator = "/"
    
    /// The path of the program's current working directory.
    public static var Current: FKPath {
        get {
            return FKPath(NSFileManager.defaultManager().currentDirectoryPath)
        }
        set {
            NSFileManager.defaultManager().changeCurrentDirectoryPath(newValue._path)
        }
    }
    
    /// The stored path property.
    private var _path: String
    
    /// The components of the path.
    public var components: [FKPath] {
        return (_path as NSString).pathComponents.map { FKPath($0) }
    }
    
    /// A new path created by removing extraneous components from the path.
    public var standardized: FKPath {
        return FKPath((self._path as NSString).stringByStandardizingPath)
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
    
    /// Returns true if the path begins with "`/`".
    public var isAbsolute: Bool {
        return _path.hasPrefix(FKPath.Separator)
    }
    
    /// Returns true if the path does not begin with "`/`".
    public var isRelative: Bool {
        return !isAbsolute
    }
    
    public var isDirectory: Bool {
        var isDirectory: ObjCBool = false
        return NSFileManager.defaultManager()
            .fileExistsAtPath(_path, isDirectory: &isDirectory) && isDirectory
    }
    
    /// The path's parent path.
    public var parent: FKPath {
        return FKPath((_path as NSString).stringByDeletingLastPathComponent)
    }
    
    /// The path's children paths.
    public var children: [FKPath] {
        if let paths = try? NSFileManager.defaultManager().contentsOfDirectoryAtPath(_path) {
            return paths.map { self + FKPath($0) }
        }
        return []
    }
    
    /// Initializes a path to "`/`".
    public init() {
        _path = "/"
    }
    
    /// Initializes a path to the string's value.
    public init(_ path: String) {
        self._path = path
    }
    
    /// Standardizes the path.
    public mutating func standardize() {
        self = self.standardized
    }
    
    /// Creates a file at path.
    ///
    /// Throws an error if the file cannot be created.
    ///
    /// - Throws: `FKError.CreateFileFail`
    ///
    public func createFile() throws {
        let manager = NSFileManager.defaultManager()
        if !manager.createFileAtPath(_path, contents: nil, attributes: nil) {
            throw FKError.CreateFileFail
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
            let manager = NSFileManager.defaultManager()
            try manager.createDirectoryAtPath(
                _path, withIntermediateDirectories: true, attributes: nil)
        } catch {
            throw FKError.CreateFileFail
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
            let manager = NSFileManager.defaultManager()
            try manager.removeItemAtPath(_path)
        } catch {
            throw FKError.DeleteFileFail
        }
    }
    
    // MARK: - StringLiteralConvertible
    
    public typealias ExtendedGraphemeClusterLiteralType = StringLiteralType
    
    public typealias UnicodeScalarLiteralType = StringLiteralType
    
    public init(extendedGraphemeClusterLiteral value: ExtendedGraphemeClusterLiteralType) {
        _path = value
    }
    
    public init(stringLiteral value: StringLiteralType) {
        _path = value
    }
    
    public init(unicodeScalarLiteral value: UnicodeScalarLiteralType) {
        _path = value
    }
    
    // MARK: - RawRepresentable
    
    public init(rawValue: String) {
        _path = rawValue
    }
    
    public var rawValue: String {
        return _path
    }
    
    // MARK: - Hashable
    
    public var hashValue: Int {
        return _path.hashValue
    }
    
    // MARK: - Indexable
    
    public var startIndex: Int {
        return components.startIndex
    }
    
    public var endIndex: Int {
        return components.endIndex
    }
    
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
    
    public var description: String {
        return _path
    }
    
    // MARK: - CustomDebugStringConvertible
    
    public var debugDescription: String {
        return "Path: \(_path.debugDescription)"
    }
    
}

// MARK: - Operators

public func == (lhs: FKPath, rhs: FKPath) -> Bool {
    return lhs._path == rhs._path
}

/// Concatenates two `FKPath` instances and returns the result.
///
///     let systemLibrary: FKPath = "/System/Library"
///     print(systemLib + "Fonts")  // "/System/Library/Fonts"
///
public func + (lhs: FKPath, rhs: FKPath) -> FKPath {
    switch (lhs._path.hasSuffix(FKPath.Separator), rhs._path.hasPrefix(FKPath.Separator)) {
    case (true, true):
        return FKPath("\(lhs._path)\(rhs._path.substringFromIndex(rhs._path.startIndex.successor()))")
    case (false, false):
        return FKPath("\(lhs._path)\(FKPath.Separator)\(rhs._path)")
    default:
        return FKPath("\(lhs._path)\(rhs._path)")
    }
}

public func += (inout lhs: FKPath, rhs: FKPath) {
    lhs = lhs + rhs
}

postfix operator • {}

/// Returns the standardized version of the path.
public postfix func • (path: FKPath) -> FKPath {
    return path.standardized
}

postfix operator ^ {}

/// Returns the path's parent path.
public postfix func ^ (path: FKPath) -> FKPath {
    return path.parent
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


