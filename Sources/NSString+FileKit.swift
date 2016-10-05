//
//  NSString+FileKit.swift
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

extension NSString {

    /// Returns an String object initialized by copying the characters from
    /// the raw value of a given path.
    public convenience init(path: Path) {
        self.init(string: path.rawValue)
    }

}

extension NSString: Writable {
    /// Writes the string to a path atomically.
    ///
    /// - Parameter path: The path being written to.
    ///
    public func write(to path: Path) throws {
        try write(to: path, atomically: true)
    }

    /// Writes the string to a path with `NSUTF8StringEncoding` encoding.
    ///
    /// - Parameter path: The path being written to.
    /// - Parameter useAuxiliaryFile: If `true`, the data is written to an
    ///                               auxiliary file that is then renamed to the
    ///                               file. If `false`, the data is written to
    ///                               the file directly.
    ///
    public func write(to path: Path, atomically useAuxiliaryFile: Bool) throws {
        do {
            try self.write(toFile: path._safeRawValue,
                           atomically: useAuxiliaryFile,
                           encoding: String.Encoding.utf8.rawValue)
        } catch {
            throw FileKitError.writeToFileFail(path: path)
        }
    }


}

/*
 extension NSString: Readable {

 /// Creates a string from a path.
 public class func read(from path: Path) throws -> Self {
 let possibleContents = try? NSString(
 contentsOfFile: path._safeRawValue,
 encoding: String.Encoding.utf8.rawValue)
 guard let contents = possibleContents else {
 throw FileKitError.readFromFileFail(path: path)
 }
 return contents
 }
 }
 */

