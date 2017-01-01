//
//  Dictionary+File.swift
//  FileKit
//
//  The MIT License (MIT)
//
//  Copyright (c) 2017 Nikolai Vazquez
//  Copyright (c) 2017 Marchand Eric
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

extension Dictionary: ReadableWritable, WritableConvertible {

    /// Returns a dictionary from the given path.
    ///
    /// - Parameter path: The path to be returned the dictionary for.
    /// - Throws: FileKitError.ReadFromFileFail
    ///
    public static func read(from path: Path) throws -> Dictionary {
        guard let contents = NSDictionary(contentsOfFile: path._safeRawValue) else {
            throw FileKitError.readFromFileFail(path: path)
        }
        guard let dict = contents as? Dictionary else {
             throw FileKitError.readFromFileFail(path: path)
        }
        return dict
    }

    // Return an bridged NSDictionary value
    public var writable: NSDictionary {
        return self as NSDictionary
    }

}
