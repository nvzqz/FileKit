//
//  DirectoryEnumerator.swift
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

/// An enumerator for the contents of a directory that returns the paths of all
/// files and directories contained within that directory.
public struct DirectoryEnumerator: IteratorProtocol {

    fileprivate let _path: Path, _enumerator: FileManager.DirectoryEnumerator?

    /// Creates a directory enumerator for the given path.
    ///
    /// - Parameter path: The path a directory enumerator to be created for.
    public init(path: Path) {
        _path = path
        _enumerator = FileManager().enumerator(atPath: path._safeRawValue)
    }

    /// Returns the next path in the enumeration.
    public func next() -> Path? {
        guard let next = _enumerator?.nextObject() as? String else {
            return nil
        }
        return _path + next
    }

    /// Skip recursion into the most recently obtained subdirectory.
    public func skipDescendants() {
        _enumerator?.skipDescendants()
    }
}
