//
//  Data+FileKit.swift
//  FileKit
//
//  The MIT License (MIT)
//
//  Copyright (c) 2016 Nikolai Vazquez
//  Copyright (c) 2016 Marchand Eric
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

extension Data: ReadableWritable {

    /// Returns data read from the given path.
    public static func read(from path: Path) throws -> Data {
        do {
            return try self.init(contentsOf: path.url, options: [])
        }
        catch {
            throw FileKitError.readFromFileFail(path: path)
        }
    }

    /// Returns data read from the given path using Data.ReadingOptions.
    public static func read(from path: Path, options: Data.ReadingOptions) throws -> Data {
        do {
            return try self.init(contentsOf: path.url, options: options)
        }
        catch {
            throw FileKitError.readFromFileFail(path: path)
        }
    }


    /// Writes `self` to a Path.
    public func write(to path: Path) throws {
        try write(to: path, atomically: true)
    }

    /// Writes `self` to a path.
    ///
    /// - Parameter path: The path being written to.
    /// - Parameter useAuxiliaryFile: If `true`, the data is written to an
    ///                               auxiliary file that is then renamed to the
    ///                               file. If `false`, the data is written to
    ///                               the file directly.
    ///
    public func write(to path: Path, atomically useAuxiliaryFile: Bool) throws {
        let options: Data.WritingOptions = useAuxiliaryFile ? [.atomic] : []
        try self.write(to: path, options: options)
    }

    /// Writes `self` to a path.
    ///
    /// - Parameter path: The path being written to.
    /// - Parameter options: writing options.
    ///
    public func write(to path: Path, options: Data.WritingOptions) throws {
        do {
            try self.write(to: path.url, options: options)
        } catch {
            throw FileKitError.writeToFileFail(path: path)
        }
    }

}
