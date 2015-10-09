//
//  FKDataFile.swift
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

/// A representation of a filesystem data file.
///
/// The data type is `NSData`.
///
public class FKDataFile: FKFileType {

    /// The data file's filesystem path.
    public var path: FKPath

    /// Initializes a data file from a path.
    required public init(path: FKPath) {
        self.path = path
    }

    /// Returns data from a data file.
    ///
    /// - Throws: `FKError.ReadFromFileFail`
    ///
    public func read() throws -> NSData {
        guard let data = NSData(contentsOfFile: path.rawValue) else {
            throw FKError.ReadFromFileFail
        }
        return data
    }

    /// Writes data to an array file.
    ///
    /// Writing is done atomically by default.
    ///
    /// - Parameter data: The data to be written to the data file.
    ///
    /// - Throws: `FKError.WriteToFileFail`
    ///
    public func write(data: NSData) throws {
        try write(data, atomically: true)
    }

    /// Writes data to a file.
    ///
    /// - Parameter data: The array to be written to the array file.
    ///
    /// - Parameter atomically: If `true`, the array is written to an
    ///                         auxiliary file that is then renamed to the file.
    ///                         If `false`, the array is written to the
    ///                         file directly.
    ///
    /// - Throws: `FKError.WriteToFileFail`
    ///
    public func write(data: NSData, atomically useAuxiliaryFile: Bool) throws {
        guard data.writeToFile(path.rawValue, atomically: useAuxiliaryFile) else {
            throw FKError.WriteToFileFail
        }
    }
    
}


