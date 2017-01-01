//
//  Image.swift
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

#if os(OSX)
import Cocoa
#elseif os(iOS) || os(tvOS)
import UIKit
#elseif os(watchOS)
import WatchKit
#endif

#if os(OSX)
/// The image type for the current platform.
public typealias Image = NSImage
#elseif os(iOS) || os(tvOS) || os(watchOS)
/// The image type for the current platform.
public typealias Image = UIImage
#endif

#if os(OSX) || os(iOS) || os(tvOS) || os(watchOS)

extension Image: ReadableWritable, WritableConvertible {

    /// Returns an image from the given path.
    ///
    /// - Parameter path: The path to be returned the image for.
    /// - Throws: FileKitError.ReadFromFileFail
    ///
    public class func read(from path: Path) throws -> Self {
        guard let contents = self.init(contentsOfFile: path._safeRawValue) else {
            throw FileKitError.readFromFileFail(path: path)
        }
        return contents
    }

    /// Returns `TIFFRepresentation` on OS X and `UIImagePNGRepresentation` on
    /// iOS, watchOS, and tvOS.
    public var writable: Data {
        #if os(OSX)
        return self.tiffRepresentation ?? Data()
        #else
        return UIImagePNGRepresentation(self) ?? Data()
        #endif
    }

    /// Retrieves an image from a URL.
    public convenience init?(url: URL) {
        #if os(OSX)
            self.init(contentsOf: url)
        #else
            guard let data = try? Data(contentsOf: url) else {
                return nil
            }
            self.init(data: data)
        #endif
    }

    /// Retrieves an image from a URL string.
    public convenience init?(urlString string: String) {
        guard let url = URL(string: string) else {
            return nil
        }
        self.init(url: url)
    }

}

#endif
