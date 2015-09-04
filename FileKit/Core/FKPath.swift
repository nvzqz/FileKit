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

public struct FKPath: StringLiteralConvertible,
                      RawRepresentable,
                      Hashable,
                      Indexable,
                      CustomStringConvertible,
                      CustomDebugStringConvertible {
    
    // MARK: - FKPath
    
    public static let Separator = "/"
    
    public static var Current: FKPath {
        get {
        return FKPath(NSFileManager.defaultManager().currentDirectoryPath)
        }
        set {
            NSFileManager.defaultManager().changeCurrentDirectoryPath(newValue._path)
        }
    }
    
    private var _path: String
    
    public var components: [FKPath] {
        return (_path as NSString).pathComponents.map { FKPath($0) }
    }
    
    public var standardized: FKPath {
        return FKPath((self._path as NSString).stringByStandardizingPath)
    }
    
    public var absolute: FKPath {
        return self.isAbsolute ?
            self.standardized  :
            (FKPath.Current + self).standardized
    }
    
    public var isAbsolute: Bool {
        return _path.hasPrefix(FKPath.Separator)
    }
    
    public var isRelative: Bool {
        return !isAbsolute
    }
    
    public var parent: FKPath {
        return FKPath((_path as NSString).stringByDeletingLastPathComponent)
    }
    
    public var children: [FKPath] {
        if let paths = try? NSFileManager.defaultManager().contentsOfDirectoryAtPath(_path) {
            return paths.map { self + FKPath($0) }
        }
        return []
    }
    
    public init() {
        _path = "/"
    }
    
    public init(_ path: String) {
        self._path = path
    }
    
    public mutating func standardize() {
        self = self.standardized
    }
    
    public func createFile() throws {
        
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

public func == (lhs: FKPath, rhs: FKPath) -> Bool {
    return lhs._path == rhs._path
}

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

postfix operator % {}

public postfix func % (path: FKPath) -> FKPath {
    return path.standardized
}

postfix operator .. {}

public postfix func .. (path: FKPath) -> FKPath {
    return path.parent
}

// MARK: - FKPaths

extension FKPath {
    
    public static var UserHome: FKPath {
        return FKPath(NSHomeDirectory())
    }
    
    public static var UserTemporary: FKPath {
        return FKPath(NSTemporaryDirectory())
    }
    
    public static var UserCaches: FKPath {
        return pathInUserDomain(.CachesDirectory)
    }
    
    #if os(OSX)
    
    public static var UserApplications: FKPath {
        return pathInUserDomain(.ApplicationDirectory)
    }
    
    public static var UserApplicationSupport: FKPath {
        return pathInUserDomain(.ApplicationSupportDirectory)
    }
    
    public static var UserDesktop: FKPath {
        return pathInUserDomain(.DesktopDirectory)
    }
    
    public static var UserDocuments: FKPath {
        return pathInUserDomain(.DocumentDirectory)
    }
    
    public static var UserDownloads: FKPath {
        return pathInUserDomain(.DownloadsDirectory)
    }
    
    public static var UserLibrary: FKPath {
        return pathInUserDomain(.LibraryDirectory)
    }
    
    public static var UserMovies: FKPath {
        return pathInUserDomain(.MoviesDirectory)
    }
    
    public static var UserMusic: FKPath {
        return pathInUserDomain(.MusicDirectory)
    }
    
    public static var UserPictures: FKPath {
        return pathInSystemDomain(.PicturesDirectory)
    }
    
    public static var SystemApplications: FKPath {
        return pathInSystemDomain(.ApplicationDirectory)
    }
    
    public static var SystemApplicationSupport: FKPath {
        return pathInSystemDomain(.ApplicationSupportDirectory)
    }
    
    public static var SystemLibrary: FKPath {
        return pathInSystemDomain(.LibraryDirectory)
    }
    
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


