//
//  FKFile.swift
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

/// A representation of a filesystem file of a given data type.
///
/// - Precondition: The data type must conform to `FKDataType`.
///
public class FKFile<DataType: FKDataType>: FKFileType {
    
    /// The file's filesystem path.
    public var path: FKPath
    
    /// Initializes a file from a path.
    required public init(path: FKPath) {
        self.path = path
    }
    
    /// Reads the file and returns its data.
    public func read() throws -> DataType {
        return try DataType.readFromPath(path)
    }

    /// Writes data to the file.
    ///
    /// Writing is done atomically by default.
    ///
    /// - Parameter data: The data to be written to the file.
    ///
    /// - Throws: `FKError.WriteToFileFail`
    ///
    public func write(data: DataType) throws {
        try self.write(data, atomically: true)
    }

    /// Writes data to the file.
    ///
    /// - Parameter data: The data to be written to the file.
    ///
    /// - Parameter atomically: If `true`, the data is written to an auxiliary
    ///                         file that is then renamed to the file.
    ///                         If `false`, the data is written to the file
    ///                         directly.
    ///
    /// - Throws: `FKError.WriteToFileFail`
    ///
    public func write(data: DataType, atomically useAuxiliaryFile: Bool) throws {
        try data.writeToPath(path, atomically: useAuxiliaryFile)
    }
    
}
