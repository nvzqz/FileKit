//
//  RelativePathType.swift
//  FileKit
//
//  Created by ijump on 4/30/16.
//  Copyright © 2016 Nikolai Vazquez. All rights reserved.
//

import Foundation

/// The type attribute for a relative path.
public enum RelativePathType: String {
    
    /// path like "dir/path".
    case Normal
    
    /// path like "." and "".
    case Current
    
    /// path like "../path".
    case Ancestor
    
    /// path like "..".
    case Parent
    
    /// path like "/path".
    case Absolute
    
    
    /// Creates a RelativePathType from an `String` attribute.
    ///
    /// - Parameter rawValue: The raw value to create from.
    public init?(rawValue: String) {
        switch rawValue {
        case "Normal":
            self = Normal
        case "Current":
            self = Current
        case "Ancestor":
            self = Ancestor
        case "Parent":
            self = Parent
        case "Absolute":
            self = Absolute
        default:
            return nil
        }
    }
    
    /// The rawValue attribute for `self`.
    public var rawValue: String {
        switch self {
        case .Normal:
            return "Normal"
        case .Current:
            return "Current"
        case .Ancestor:
            return "Ancestor"
        case .Parent:
            return "Parent"
        case .Absolute:
            return "Absolute"
        }
    }
    
}
