//
//  FKArrayFile.swift
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

/// A representation of a filesystem array file.
///
/// The data type is `NSArray`.
///
public class FKArrayFile: FKFileType {

    /// The array file's filesystem path.
    public var path: FKPath

    /// Initializes an array file from a path.
    required public init(path: FKPath) {
        self.path = path
    }

    /// Returns an array from a file.
    ///
    /// - Throws: `FKError.ReadFromFileFail`
    ///
    public func read() throws -> NSArray {
        guard let array = NSArray(contentsOfFile: path.rawValue) else {
            throw FKError.ReadFromFileFail
        }
        return array
    }

    /// Writes an array to a file.
    ///
    /// Writing is done atomically by default.
    ///
    /// - Parameter data: The array to be written to the file.
    ///
    /// - Throws: `FKError.WriteToFileFail`
    ///
    public func write(data: NSArray) throws {
        try write(data, atomically: true)
    }

    /// Writes an array to a file.
    ///
    /// - Parameter data: The array to be written to the file.
    ///
    /// - Parameter atomically: If `true`, the array is written to an auxiliary
    ///                         file that is then renamed to the file.
    ///                         If `false`, the array is written to the file
    ///                         directly.
    ///
    /// - Throws: `FKError.WriteToFileFail`
    ///
    public func write(array: NSArray, atomically useAuxiliaryFile: Bool) throws {
        guard array.writeToFile(path.rawValue, atomically: useAuxiliaryFile) else {
            throw FKError.WriteToFileFail
        }
    }
    
}

