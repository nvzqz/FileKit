//
//  FileKit.swift
//  FileKit
//
//  Created by Nikolai Vazquez on 9/1/15.
//  Copyright © 2015 Nikolai Vazquez. All rights reserved.
//

import Foundation

public class File: StringLiteralConvertible {
    
    // MARK: - File
    
    public var path: Path
    
    public init(path: Path) {
        self.path = path
    }
    
    // MARK: - StringLiteralConvertible
    
    public typealias ExtendedGraphemeClusterLiteralType = StringLiteralType
    
    public typealias UnicodeScalarLiteralType = StringLiteralType
    
    public required init(extendedGraphemeClusterLiteral value: ExtendedGraphemeClusterLiteralType) {
        path = Path(value)
    }
    
    public required init(stringLiteral value: StringLiteralType) {
        path = Path(value)
    }
    
    public required init(unicodeScalarLiteral value: UnicodeScalarLiteralType) {
        path = Path(value)
    }
    
}
