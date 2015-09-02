//
//  Path.swift
//  FileKit
//
//  Created by Nikolai Vazquez on 9/1/15.
//  Copyright © 2015 Nikolai Vazquez. All rights reserved.
//

import Foundation

public struct Path: StringLiteralConvertible, CustomStringConvertible, Indexable {
    
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
    
    private var _path: String
    
    public var components: [Path] {
        return (_path as NSString).pathComponents.map { Path($0) }
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
