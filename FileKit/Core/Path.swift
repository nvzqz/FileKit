//
//  Path.swift
//  FileKit
//
//  Created by Nikolai Vazquez on 9/1/15.
//  Copyright © 2015 Nikolai Vazquez. All rights reserved.
//

import Foundation

public struct Path: StringLiteralConvertible,
                    CustomStringConvertible,
                    RawRepresentable,
                    Hashable,
                    Indexable {
    
    // MARK: - Path
    
    public static let Separator = "/"
    
    public static var Current: Path {
        get {
            return Path(NSFileManager.defaultManager().currentDirectoryPath)
        }
        set {
            NSFileManager.defaultManager().changeCurrentDirectoryPath(newValue._path)
        }
    }
    
    private var _path: String
    
    public var components: [Path] {
        return (_path as NSString).pathComponents.map { Path($0) }
    }
    
    public var standardized: Path {
        return Path((self._path as NSString).stringByStandardizingPath)
    }
    
    public var absolute: Path {
        return self.isAbsolute ?
            self.standardized  :
            (Path.Current + self).standardized
    }
    
    public var isAbsolute: Bool {
        return _path.hasPrefix(Path.Separator)
    }
    
    public var isRelative: Bool {
        return !isAbsolute
    }
    
    public init() {
        _path = "/"
    }
    
    public init(_ path: String) {
        self._path = path
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
    
    // MARK: - CustomStringConvertible
    
    public var description: String {
        return _path
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
    
    public subscript(index: Int) -> Path {
        return components[index]
    }
    
}

// MARK: - Operators

public func == (lhs: Path, rhs: Path) -> Bool {
    return lhs._path == rhs._path
}

func + (lhs: Path, rhs: Path) -> Path {
    switch (lhs._path.hasSuffix(Path.Separator), rhs._path.hasPrefix(Path.Separator)) {
    case (true, true):
        return Path("\(lhs._path)\(rhs._path.substringFromIndex(rhs._path.startIndex.successor()))")
    case (false, false):
        return Path("\(lhs._path)\(Path.Separator)\(rhs._path)")
    default:
        return Path("\(lhs._path)\(rhs._path)")
    }
}

// MARK: - Paths

extension Path {
    
    public static var UserHome: Path {
        return Path(NSHomeDirectory())
    }
    
    public static var UserTemporary: Path {
        return Path(NSTemporaryDirectory())
    }
    
    public static var UserCaches: Path {
        return pathInUserDomain(.CachesDirectory)
    }
    
    #if os(OSX)
    
    public static var UserApplications: Path {
        return pathInUserDomain(.ApplicationDirectory)
    }
    
    public static var UserApplicationSupport: Path {
        return pathInUserDomain(.ApplicationSupportDirectory)
    }
    
    public static var UserDesktop: Path {
        return pathInUserDomain(.DesktopDirectory)
    }
    
    public static var UserDocuments: Path {
        return pathInUserDomain(.DocumentDirectory)
    }
    
    public static var UserDownloads: Path {
        return pathInUserDomain(.DownloadsDirectory)
    }
    
    public static var UserLibrary: Path {
        return pathInUserDomain(.LibraryDirectory)
    }
    
    public static var UserMovies: Path {
        return pathInUserDomain(.MoviesDirectory)
    }
    
    public static var UserMusic: Path {
        return pathInUserDomain(.MusicDirectory)
    }
    
    public static var UserPictures: Path {
        return pathInSystemDomain(.PicturesDirectory)
    }
    
    public static var SystemApplications: Path {
        return pathInSystemDomain(.ApplicationDirectory)
    }
    
    public static var SystemApplicationSupport: Path {
        return pathInSystemDomain(.ApplicationSupportDirectory)
    }
    
    public static var SystemLibrary: Path {
        return pathInSystemDomain(.LibraryDirectory)
    }
    
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
    
    private static func pathsInDomains(directory: NSSearchPathDirectory,
        _ domainMask: NSSearchPathDomainMask) -> [Path] {
            let paths = NSSearchPathForDirectoriesInDomains(directory, domainMask, true)
            return paths.map { Path($0) }
    }
    
}


