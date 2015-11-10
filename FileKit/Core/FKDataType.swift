//
//  FKDataType.swift
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

/// A type that can be used to read and write `FKFile` instances.
public typealias FKDataType = protocol<FKReadable, FKWritable>

// MARK: - FKReadable

/// A type that can be used to read `FKFile` instances.
public protocol FKReadable {

    /// Creates `Self` from a path.
    static func readFromPath(path: FKPath) throws -> Self
    
}

/// A type that can be initialized from a file.
public protocol FKReadableFromFile: FKReadable {
    init?(contentsOfFile: String)
}

extension FKReadableFromFile {

    public init(contentsOfPath path: FKPath) throws {
        guard let contents = Self(contentsOfFile: path.rawValue) else {
            throw FKError.ReadFromFileFail(path: path)
        }
        self = contents
    }

}

// MARK: - FKWritable

/// A type that can be used to write `FKFile` instances to an `FKPath`.
public protocol FKWritable {
    
    /// Writes `self` to a path.
    func writeToPath(path: FKPath) throws

    /// Writes `self` to a path.
    func writeToPath(path: FKPath, atomically useAuxiliaryFile: Bool) throws

}

extension FKWritable {

    public func writeToPath(path: FKPath) throws {
        try writeToPath(path, atomically: true)
    }

}

/// A type that can be used to write `FKFile` instances to a file.
public protocol FKWritableToFile: FKWritable {
    func writeToFile(path: String, atomically useAuxiliaryFile: Bool) -> Bool
}

extension FKWritableToFile {

    public func writeToPath(path: FKPath, atomically useAuxiliaryFile: Bool) throws {
        guard writeToFile(path.rawValue, atomically: useAuxiliaryFile) else {
            throw FKError.WriteToFileFail(path: path)
        }
    }

}

/// A type that can be converted to a FKWritable.
public protocol FKWritableConvertible: FKWritable {

    typealias WritableType: FKWritable

    var writable: WritableType? { get }

}

extension FKWritableConvertible {

    public func writeToPath(path: FKPath, atomically useAuxiliaryFile: Bool) throws {
        guard let writable = self.writable else {
            throw FKError.WriteToFileFail(path: path)
        }
        try writable.writeToPath(path, atomically: useAuxiliaryFile)
    }

}

