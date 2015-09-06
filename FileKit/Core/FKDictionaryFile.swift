//
//  FKDictionaryFile.swift
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

/// A representation of a filesystem dictionary file.
///
/// Dictionaries are written and read as Apple's .plist format.
///
public class FKDictionaryFile: FKFileType {
    
    /// The dictionary file's filesystem path.
    public var path: FKPath
    
    public required init(path: FKPath) {
        self.path = path
    }
    
    /// Returns a dictionary from a dictionary file.
    ///
    /// - Throws: `FKError.ReadFromFileFail`
    ///
    public func read() throws -> NSDictionary {
        if let dictionary = NSDictionary(contentsOfFile: path.rawValue) {
            return dictionary
        }
        throw FKError.ReadFromFileFail
    }
    
    /// Writes a dictionary to a dictionary file.
    ///
    /// Writing is done atomically by default.
    ///
    /// - Parameter data: The dictionary to be written to the dictionary file.
    ///
    /// - Throws: `FKError.WriteToFileFail`
    ///
    public func write(data: NSDictionary) throws {
        try write(data, atomically: true)
    }
    
    /// Writes a dictionary to a file.
    ///
    /// - Parameter data: The dictionary to be written to the dictionary file.
    ///
    /// - Parameter atomically: If `true`, the dictionary is written to an
    ///                         auxiliary file that is then renamed to the file.
    ///                         If `false`, the dictionary is written to the
    ///                         dictionary file directly.
    ///
    /// - Throws: `FKError.WriteToFileFail`
    ///
    public func write(data: NSDictionary, atomically useAuxiliaryFile: Bool) throws {
        if !data.writeToFile(path.rawValue, atomically: useAuxiliaryFile) {
            throw FKError.WriteToFileFail
        }
    }
    
}
