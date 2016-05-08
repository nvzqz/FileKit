//
//  Image.swift
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

#if os(OSX)
import Cocoa
#elseif os(iOS) || os(tvOS)
import UIKit
#else
import WatchKit
#endif

#if os(OSX)
/// The image type for the current platform.
public typealias Image = NSImage
#else
/// The image type for the current platform.
public typealias Image = UIImage
#endif

extension Image: DataType, WritableConvertible {

    /// Returns an image from the given path.
    ///
    /// - Parameter path: The path to be returned the image for.
    /// - Throws: FileKitError.ReadFromFileFail
    ///
    public class func readFromPath(path: Path) throws -> Self {
        guard let contents = self.init(contentsOfFile: path._safeRawValue) else {
            throw FileKitError.ReadFromFileFail(path: path)
        }
        return contents
    }

    /// Returns `TIFFRepresentation` on OS X and `UIImagePNGRepresentation` on
    /// iOS, watchOS, and tvOS.
    public var writable: NSData {
        #if os(OSX)
        return self.TIFFRepresentation ?? NSData()
        #else
        return UIImagePNGRepresentation(self) ?? NSData()
        #endif
    }

    /// Retrieves an image from a URL string.
    public class func imageFromURLString(url: String) -> Image? {
        #if os(iOS)
            if let nsurl = NSURL(string: url) {
                if let data = NSData(contentsOfURL: nsurl) {
                    return UIImage(data: data)
                }
            }
        #elseif os(OSX)
            if let nsurl = NSURL(string: url) {
                return NSImage(contentsOfURL: nsurl)
            }
        #endif
        return nil
    }

}
