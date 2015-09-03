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

public struct Path: StringLiteralConvertible,
                    RawRepresentable,
                    Hashable,
                    Indexable,
                    CustomStringConvertible,
                    CustomDebugStringConvertible {
    
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
    
    public var parent: Path {
        return Path((_path as NSString).stringByDeletingLastPathComponent)
    }
    
    public var children: [Path] {
        if let paths = try? NSFileManager.defaultManager().contentsOfDirectoryAtPath(_path) {
            return paths.map { self + Path($0) }
        }
        return []
    }
    
    public init() {
        _path = "/"
    }
    
    public init(_ path: String) {
        self._path = path
    }
    
    mutating func standardize() {
        self = self.standardized
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
    
    public subscript(index: Int) -> Path {
        return components[index]
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

public func == (lhs: Path, rhs: Path) -> Bool {
    return lhs._path == rhs._path
}

public func + (lhs: Path, rhs: Path) -> Path {
    switch (lhs._path.hasSuffix(Path.Separator), rhs._path.hasPrefix(Path.Separator)) {
    case (true, true):
        return Path("\(lhs._path)\(rhs._path.substringFromIndex(rhs._path.startIndex.successor()))")
    case (false, false):
        return Path("\(lhs._path)\(Path.Separator)\(rhs._path)")
    default:
        return Path("\(lhs._path)\(rhs._path)")
    }
}

public func += (inout lhs: Path, rhs: Path) {
    lhs = lhs + rhs
}

postfix operator % {}

public postfix func % (path: Path) -> Path {
    return path.standardized
}

postfix operator .. {}

public postfix func .. (path: Path) -> Path {
    return path.parent
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


