//
//  ReadableWritable.swift
//  FileKit
//
//  The MIT License (MIT)
//
//  Copyright (c) 2015-2017 Nikolai Vazquez
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

/// A type that can be used to read from and write to File instances.
public typealias ReadableWritable = Readable & Writable

/// A type that can be used to read from File instances.
public protocol Readable {

    /// Creates `Self` from the contents of a Path.
    ///
    /// - Parameter path: The path being read from.
    ///
    static func read(from path: Path) throws -> Self

}

extension Readable {

    /// Initializes `self` from the contents of a Path.
    ///
    /// - Parameter path: The path being read from.
    ///
    public init(contentsOfPath path: Path) throws {
        self = try Self.read(from: path)
    }

}

/// A type that can be used to write to File instances.
public protocol Writable {

    /// Writes `self` to a Path.
    func write(to path: Path) throws

    /// Writes `self` to a Path.
    ///
    /// - Parameter path: The path being written to.
    /// - Parameter useAuxiliaryFile: If `true`, the data is written to an
    ///                               auxiliary file that is then renamed to the
    ///                               file. If `false`, the data is written to
    ///                               the file directly.
    ///
    func write(to path: Path, atomically useAuxiliaryFile: Bool) throws

}

extension Writable {

    /// Writes `self` to a Path atomically.
    ///
    /// - Parameter path: The path being written to.
    ///
    public func write(to path: Path) throws {
        try write(to: path, atomically: true)
    }

}

/// A type that can be used to write to a String file path.
public protocol WritableToFile: Writable {

    /// Writes `self` to a String path.
    ///
    /// - Parameter path: The path being written to.
    /// - Parameter useAuxiliaryFile: If `true`, the data is written to an
    ///                               auxiliary file that is then renamed to the
    ///                               file. If `false`, the data is written to
    ///                               the file directly.
    ///
    /// - Returns: `true` if the writing completed successfully, or `false` if
    ///            the writing failed.
    ///
    func write(toFile path: String, atomically useAuxiliaryFile: Bool) -> Bool

}

extension WritableToFile {

    /// Writes `self` to a Path.
    ///
    /// - Parameter path: The path being written to.
    /// - Parameter useAuxiliaryFile: If `true`, the data is written to an
    ///                               auxiliary file that is then renamed to the
    ///                               file. If `false`, the data is written to
    ///                               the file directly.
    ///
    /// - Throws: `FileKitError.WriteToFileFail`
    ///
    public func write(to path: Path, atomically useAuxiliaryFile: Bool) throws {
        guard write(toFile: path._safeRawValue, atomically: useAuxiliaryFile) else {
            throw FileKitError.writeToFileFail(path: path, error: FileKitError.ReasonError.conversion(type(of: self)))
        }
    }

}

/// A type that can be converted to a Writable.
public protocol WritableConvertible: Writable {

    /// The type that allows `Self` to be `Writable`.
    associatedtype WritableType: Writable

    /// Allows `self` to be written to a path.
    var writable: WritableType { get }

}

extension WritableConvertible {

    /// Writes `self` to a Path.
    ///
    /// - Parameter path: The path being written to.
    /// - Parameter useAuxiliaryFile: If `true`, the data is written to an
    ///                               auxiliary file that is then renamed to the
    ///                               file. If `false`, the data is written to
    ///                               the file directly.
    ///
    /// - Throws:
    ///     `FileKitError.WriteToFileFail`,
    ///     `FileKitError.WritableConvertiblePropertyNil`
    ///
    public func write(to path: Path, atomically useAuxiliaryFile: Bool) throws {
        try writable.write(to: path, atomically: useAuxiliaryFile)
    }

}
