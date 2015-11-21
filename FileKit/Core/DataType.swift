//
//  DataType.swift
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

/// A type that can be used to read and write `File` instances.
public typealias DataType = protocol<Readable, Writable>

// MARK: - Readable

/// A type that can be used to read `File` instances.
public protocol Readable {

    /// Creates `Self` from a path.
    static func readFromPath(path: Path) throws -> Self
    
}

extension Readable {

    /// Initializes `self` from a path.
    public init(contentsOfPath path: Path) throws {
        self = try Self.readFromPath(path)
    }

}

// MARK: - Writable

/// A type that can be used to write `File` instances to an `Path`.
public protocol Writable {
    
    /// Writes `self` to a path.
    func writeToPath(path: Path) throws

    /// Writes `self` to a path.
    func writeToPath(path: Path, atomically useAuxiliaryFile: Bool) throws

}

extension Writable {

    public func writeToPath(path: Path) throws {
        try writeToPath(path, atomically: true)
    }

}

/// A type that can be used to write `File` instances to a file.
public protocol WritableToFile: Writable {
    func writeToFile(path: String, atomically useAuxiliaryFile: Bool) -> Bool
}

extension WritableToFile {

    public func writeToPath(path: Path, atomically useAuxiliaryFile: Bool) throws {
        guard writeToFile(path.rawValue, atomically: useAuxiliaryFile) else {
            throw FileKitError.WriteToFileFail(path: path)
        }
    }

}

/// A type that can be converted to a Writable.
public protocol WritableConvertible: Writable {

    /// The type that allows `Self` to be `Writable`.
    typealias WritableType: Writable

    /// Allows `self` to be written to a path.
    var writable: WritableType? { get }

}

extension WritableConvertible {

    public func writeToPath(path: Path, atomically useAuxiliaryFile: Bool) throws {
        guard let writable = self.writable else {
            throw FileKitError.WritableConvertiblePropertyNil(type: self.dynamicType)
        }
        try writable.writeToPath(path, atomically: useAuxiliaryFile)
    }

}

