//
//  FileType.swift
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

/// The type attribute for a file at a path.
public enum FileType: String {

    /// The file is a directory.
    case Directory

    /// The file is a regular file.
    case Regular

    /// The file is a symbolic link.
    case SymbolicLink

    /// The file is a socket.
    case Socket

    /// The file is a characer special file.
    case CharacterSpecial

    /// The file is a block special file.
    case BlockSpecial

    /// The type of the file is unknown.
    case Unknown

    /// Creates a FileType from an `NSFileType` attribute.
    public init?(rawValue: String) {
        switch rawValue {
        case NSFileTypeDirectory:
            self = Directory
        case NSFileTypeRegular:
            self = Regular
        case NSFileTypeSymbolicLink:
            self = SymbolicLink
        case NSFileTypeSocket:
            self = Socket
        case NSFileTypeCharacterSpecial:
            self = CharacterSpecial
        case NSFileTypeBlockSpecial:
            self = BlockSpecial
        case NSFileTypeUnknown:
            self = Unknown
        default:
            return nil
        }
    }

    /// The `NSFileType` attribute for `self`.
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
