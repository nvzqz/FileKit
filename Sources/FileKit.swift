//
//  FileKit.swift
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

/// Information regarding [FileKit](https://github.com/nvzqz/FileKit).
///
/// - Author: [Nikolai Vazquez](https://github.com/nvzqz)
///
/// - Copyright: [MIT License](https://opensource.org/licenses/MIT)
///
/// - Version: [v5.0.0](https://github.com/nvzqz/FileKit/releases/tag/v4.0.0)
///
/// - Requires: Xcode 9, Swift 4.0
///
public enum FileKitInfo {

    /// The current version.
    ///
    /// FileKit follows [Semantic Versioning v2.0.0](http://semver.org/).
    public static let version = "v5.0.0"

    /// The current release.
    public static let release = 12

    /// FileKit is licensed under the [MIT License](https://opensource.org/licenses/MIT).
    public static let license = "MIT"

    /// A brief description of FileKit.
    public static let description = "A Swift framework that allows for simple and expressive file management."

    /// Where the project can be found.
    public static let projectURL = "https://github.com/nvzqz/FileKit"

}

import Foundation

public struct FileKit {

    /// Shared json decoder instance
    public static var jsonDecoder = JSONDecoder()
    /// Shared json encoder instance
    public static var jsonEncoder = JSONEncoder()
    /// Shared property list decoder instance
    public static var propertyListDecoder = PropertyListDecoder()
    /// Shared property list encoder instance
    public static var propertyListEncoder = PropertyListEncoder()

}

extension FileKit {

    /// Write an `Encodable` object to path
    ///
    /// - Parameter codable: The codable object to write.
    /// - Parameter path: The destination path for write operation.
    /// - Parameter encoder: A specific JSON encoder (default: FileKit.jsonEncoder).
    ///
    public static func write<T: Encodable>(_ codable: T, to path: Path, with encoder: JSONEncoder = FileKit.jsonEncoder) throws {
        do {
            let data = try encoder.encode(codable)
            try DataFile(path: path).write(data)
        } catch let error as FileKitError {
            throw error
        } catch {
            throw FileKitError.writeToFileFail(path: path, error: error)
        }
    }

    /// Read an `Encodable` object from path
    ///
    /// - Parameter path: The destination path for write operation.
    /// - Parameter decoder: A specific JSON decoder (default: FileKit.jsonDecoder).
    ///
    public static func read<T: Decodable>(from path: Path, with decoder: JSONDecoder = FileKit.jsonDecoder) throws -> T {
        let data = try DataFile(path: path).read()
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw FileKitError.readFromFileFail(path: path, error: error)
        }
    }

}
