//
//  DataFile.swift
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


/// A representation of a filesystem data file.
///
/// The data type is Data.
open class DataFile: File<Data> {

    /// Reads the file and returns its data.
    /// - Parameter options: A mask that specifies write options
    ///                      described in `Data.ReadingOptions`.
    ///
    /// - Throws: `FileKitError.ReadFromFileFail`
    /// - Returns: The data read from file.
    public func read(_ options: Data.ReadingOptions) throws -> Data {
        return try Data.read(from: path, options: options)
    }

    /// Writes data to the file.
    ///
    /// - Parameter data: The data to be written to the file.
    /// - Parameter options: A mask that specifies write options
    ///                      described in `Data.WritingOptions`.
    ///
    /// - Throws: `FileKitError.WriteToFileFail`
    ///
    public func write(_ data: Data, options: Data.WritingOptions) throws {
        try data.write(to: self.path, options: options)
    }

}

/// A representation of a filesystem data file,
/// with options to read or write.
///
/// The data type is Data.
open class DataFileWithOptions: DataFile {

    open var readingOptions: Data.ReadingOptions = []
    open var writingOptions: Data.WritingOptions? = nil

    /// Initializes a file from a path with options.
    ///
    /// - Parameter path: The path to be created a text file from.
    /// - Parameter readingOptions: The options to be used to read file.
    /// - Parameter writingOptions: The options to be used to write file.
    ///                             If nil take into account `useAuxiliaryFile`
    public init(path: Path, readingOptions: Data.ReadingOptions = [], writingOptions: Data.WritingOptions? = nil) {
        self.readingOptions = readingOptions
        self.writingOptions = writingOptions
        super.init(path: path)
    }

    open override func read() throws -> Data {
        return try read(readingOptions)
    }

    open override func write(_ data: Data, atomically useAuxiliaryFile: Bool) throws {
        // If no option take into account useAuxiliaryFile
        let options: Data.WritingOptions = (writingOptions == nil) ?
            (useAuxiliaryFile ? Data.WritingOptions.atomic : [])
            : writingOptions!
        try self.write(data, options: options)
    }
}
