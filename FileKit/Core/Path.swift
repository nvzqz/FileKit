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
    
    public static var CurrentWorkingDirectory: Path {
        get {
            return Path(NSFileManager.defaultManager().currentDirectoryPath)
        }
        set {
            NSFileManager.defaultManager().changeCurrentDirectoryPath(newValue._path)
        }
    }
    
    internal var _path: String
    
    public var components: [Path] {
        return (_path as NSString).pathComponents.map { Path($0) }
    }
    
    public var standardized: Path {
        return Path((self._path as NSString).stringByStandardizingPath)
    }
    
    public var absolute: Path {
        return self.isAbsolute ?
            self.standardized  :
            (Path.CurrentWorkingDirectory + self).standardized
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


