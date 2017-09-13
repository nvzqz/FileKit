//
//  String+FileKit.swift
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

var ReadableWritableStringEncoding = String.Encoding.utf8

/// Allows String to be used as a ReadableWritable.
extension String: ReadableWritable {

    /**
     Returns a string read from the given path.

     - Parameter path: The path of a string to be read from.
    */
    public static func read(from path: Path) throws -> String {
        guard let contents = try? String(contentsOfFile: path._safeRawValue,
                                         encoding: ReadableWritableStringEncoding)
        else {
            throw FileKitError.readFromFileFail(path: path)
        }
        return contents
    }

    /**
     Writes the string to a path atomically.

     - Parameter path: The path being written to.
    */
    public func write(to path: Path) throws {
        try write(to: path, atomically: true)
    }

    /**
     Writes the string to a path with `ReadableWritableStringEncoding` encoding.

     - Parameters:
         - path: The path being written to.
         - useAuxiliaryFile: If `true`, the data is written to an
                             auxiliary file that is then renamed to the
                             file. If `false`, the data is written to
                             the file directly.
    */
    public func write(to path: Path, atomically useAuxiliaryFile: Bool) throws {
        guard let _ = try? self.write(toFile: path._safeRawValue,
                atomically: useAuxiliaryFile,
                encoding: ReadableWritableStringEncoding)
        else {
            throw FileKitError.writeToFileFail(path: path)
        }
    }

}
