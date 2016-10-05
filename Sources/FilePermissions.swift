//
//  FilePermissions.swift
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

/// The permissions of a file.
public struct FilePermissions: OptionSet, CustomStringConvertible {

    /// The file can be read from.
    public static let read = FilePermissions(rawValue: 1)

    /// The file can be written to.
    public static let write = FilePermissions(rawValue: 2)

    /// The file can be executed.
    public static let execute = FilePermissions(rawValue: 4)

    /// All FilePermissions
    public static let all: [FilePermissions] =  [.read, .write, .execute]

    /// The raw integer value of `self`.
    public let rawValue: Int

    /// A textual representation of `self`.
    public var description: String {
        var description = ""
        for permission in FilePermissions.all  {
            if self.contains(permission) {
                description += !description.isEmpty ? ", " : ""
                if permission == .read {
                    description += "Read"
                } else if permission == .write {
                    description += "Write"
                } else if permission == .execute {
                    description += "Execute"
                }
            }
        }
        return String(describing: type(of: self)) + "[" + description + "]"
    }

    /// Creates a set of file permissions.
    ///
    /// - Parameter rawValue: The raw value to initialize from.
    ///
    public init(rawValue: Int) {
        self.rawValue = rawValue
    }

    /// Creates a set of permissions for the file at `path`.
    ///
    /// - Parameter path: The path to the file to create a set of persmissions for.
    ///
    public init(forPath path: Path) {
        var permissions = FilePermissions(rawValue: 0)
        if path.isReadable { permissions.formUnion(.read) }
        if path.isWritable { permissions.formUnion(.write) }
        if path.isExecutable { permissions.formUnion(.execute) }
        self = permissions
    }

    /// Creates a set of permissions for `file`.
    ///
    /// - Parameter file: The file to create a set of persmissions for.
    public init<DataType: ReadableWritable>(forFile file: File<DataType>) {
        self.init(forPath: file.path)
    }

}
