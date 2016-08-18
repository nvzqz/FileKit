//
//  FileType.swift
//  FileKit
//
//  The MIT License (MIT)
//
//  Copyright (c) 2015-2016 Nikolai Vazquez
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

/// The type attribute for a file at a path.
public enum FileType: String {

    /// The file is a directory.
    case directory

    /// The file is a regular file.
    case regular

    /// The file is a symbolic link.
    case symbolicLink

    /// The file is a socket.
    case socket

    /// The file is a characer special file.
    case characterSpecial

    /// The file is a block special file.
    case blockSpecial

    /// The type of the file is unknown.
    case unknown

    /// Creates a FileType from an `FileAttributeType` attribute.
    ///
    /// - Parameter rawValue: The raw value to create from.
    public init?(rawValue: String) {
        switch rawValue {
        case FileAttributeType.typeDirectory.rawValue:
            self = .directory
        case FileAttributeType.typeRegular.rawValue:
            self = .regular
        case FileAttributeType.typeSymbolicLink.rawValue:
            self = .symbolicLink
        case FileAttributeType.typeSocket.rawValue:
            self = .socket
        case FileAttributeType.typeCharacterSpecial.rawValue:
            self = .characterSpecial
        case FileAttributeType.typeBlockSpecial.rawValue:
            self = .blockSpecial
        case FileAttributeType.typeUnknown.rawValue:
            self = .unknown
        default:
            return nil
        }
    }

    /// The `FileAttributeType` attribute for `self`.
    public var rawValue: String {
        switch self {
        case .directory:
            return FileAttributeType.typeDirectory.rawValue
        case .regular:
            return FileAttributeType.typeRegular.rawValue
        case .symbolicLink:
            return FileAttributeType.typeSymbolicLink.rawValue
        case .socket:
            return FileAttributeType.typeSocket.rawValue
        case .characterSpecial:
            return FileAttributeType.typeCharacterSpecial.rawValue
        case .blockSpecial:
            return FileAttributeType.typeBlockSpecial.rawValue
        case .unknown:
            return FileAttributeType.typeUnknown.rawValue
        }
    }

}
