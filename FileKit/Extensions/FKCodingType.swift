//
//  FKCodingType.swift
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

// A protocol to transform any NSCoding object to FKWritable
// using the NSKeyedArchiver root
public protocol FKCodingType : NSCoding, FKDataType {
    
}

extension FKCodingType {

    // Writable
    public func writeToPath(path: FKPath) throws {
        try writeToPath(path, atomically: true)
    }
    
    public func writeToPath(path: FKPath, atomically useAuxiliaryFile: Bool) throws {
        NSKeyedArchiver.archiveRootObject(self, toFile: path.rawValue)
    }

    // Readable
    public init(contentsOfPath path: FKPath) throws {
        guard let contents = NSKeyedUnarchiver.unarchiveObjectWithFile( path.rawValue) as? Self
            else { throw FKError.ReadFromFileFail(path: path) }
        self = contents
    }
}