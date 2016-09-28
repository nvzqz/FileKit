//
//  TextFile.swift
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

/// A representation of a filesystem text file.
///
/// The data type is String.
open class TextFile: File<String> {

    /// The text file's string encoding.
    open var encoding: String.Encoding

    /// Initializes a text file from a path.
    ///
    /// - Parameter path: The path to be created a text file from.
    public override init(path: Path) {
        self.encoding = String.Encoding.utf8
        super.init(path: path)
    }

    /// Initializes a text file from a path with an encoding.
    ///
    /// - Parameter path: The path to be created a text file from.
    /// - Parameter encoding: The encoding to be used for the text file.
    public init(path: Path, encoding: String.Encoding) {
        self.encoding = encoding
        super.init(path: path)
    }

    /// Writes a string to a text file using the file's encoding.
    ///
    /// - Parameter data: The string to be written to the text file.
    /// - Parameter useAuxiliaryFile: If `true`, the data is written to an
    ///                               auxiliary file that is then renamed to the
    ///                               file. If `false`, the data is written to
    ///                               the file directly.
    ///
    /// - Throws: `FileKitError.WriteToFileFail`
    ///
    open override func write(_ data: String, atomically useAuxiliaryFile: Bool) throws {
        do {
            try data.write(toFile: path._safeRawValue, atomically: useAuxiliaryFile, encoding: encoding)
        } catch {
            throw FileKitError.writeToFileFail(path: path)
        }
    }

}

// MARK: Line Reader

extension TextFile {

    /// Provide a reader to read line by line.
    ///
    /// - Parameter delimiter: the line delimiter (default: \n)
    /// - Parameter chunkSize: size of buffer (default: 4096)
    ///
    /// - Returns: the `TextFileStreamReader`

    public func streamReader(_ delimiter: String = "\n",
        chunkSize: Int = 4096) -> TextFileStreamReader? {
            return TextFileStreamReader(
                path: self.path,
                delimiter: delimiter,
                encoding: encoding,
                chunkSize: chunkSize
            )
    }

    /// Read file and return filtered lines.
    ///
    /// - Parameter motif: the motif to compare
    /// - Parameter include: check if line include motif if true, exclude if not (default: true)
    /// - Parameter options: optional options  for string comparaison
    ///
    /// - Returns: the lines
    public func grep(_ motif: String, include: Bool = true,
        options: NSString.CompareOptions = []) -> [String] {
            guard let reader = streamReader() else {
                return []
            }
            defer {
                reader.close()
            }
            return reader.filter {($0.range(of: motif, options: options) != nil) == include }
    }

}

/// A class to read `TextFile` line by line.
open class TextFileStreamReader {

    /// The text encoding.
    open let encoding: String.Encoding

    /// The chunk size when reading.
    open let chunkSize: Int

    /// Tells if the position is at the end of file.
    open var atEOF: Bool = false

    let fileHandle: FileHandle!
    let buffer: NSMutableData!
    let delimData: Data!

    // MARK: - Initialization

    /// - Parameter path:      the file path
    /// - Parameter delimiter: the line delimiter (default: \n)
    /// - Parameter encoding: file encoding (default: NSUTF8StringEncoding)
    /// - Parameter chunkSize: size of buffer (default: 4096)
    public init?(
        path: Path,
        delimiter: String = "\n",
        encoding: String.Encoding = String.Encoding.utf8,
        chunkSize: Int = 4096
    ) {
        self.chunkSize = chunkSize
        self.encoding = encoding

        guard let fileHandle = path.fileHandleForReading,
            let delimData = delimiter.data(using: encoding),
            let buffer = NSMutableData(capacity: chunkSize) else {
                self.fileHandle = nil
                self.delimData = nil
                self.buffer = nil
                return nil
        }
        self.fileHandle = fileHandle
        self.delimData = delimData
        self.buffer = buffer
    }

    // MARK: - Deinitialization

    deinit {
        self.close()
    }

    // MARK: - public methods

    /// - Returns: The next line, or nil on EOF.
    open func nextLine() -> String? {
        if atEOF {
            return nil
        }

        // Read data chunks from file until a line delimiter is found.
        var range = buffer.range(of: delimData, options: [], in: NSRange(location: 0, length: buffer.length))
        while range.location == NSNotFound {
            let tmpData = fileHandle.readData(ofLength: chunkSize)
            if tmpData.isEmpty {
                // EOF or read error.
                atEOF = true
                if buffer.length > 0 {
                    // Buffer contains last line in file (not terminated by delimiter).
                    let line = NSString(data: buffer as Data, encoding: encoding.rawValue)

                    buffer.length = 0
                    return line as String?
                }
                // No more lines.
                return nil
            }
            buffer.append(tmpData)
            range = buffer.range(of: delimData, options: [], in: NSRange(location: 0, length: buffer.length))
        }

        // Convert complete line (excluding the delimiter) to a string.
        let line = NSString(data: buffer.subdata(with: NSRange(location: 0, length: range.location)),
            encoding: encoding.rawValue)
        // Remove line (and the delimiter) from the buffer.
        let cleaningRange = NSRange(location: 0, length: range.location + range.length)
        buffer.replaceBytes(in: cleaningRange, withBytes: nil, length: 0)

        return line as? String
    }

    /// Start reading from the beginning of file.
    open func rewind() -> Void {
        fileHandle?.seek(toFileOffset: 0)
        buffer.length = 0
        atEOF = false
    }

    /// Close the underlying file. No reading must be done after calling this method.
    open func close() -> Void {
        fileHandle?.closeFile()
    }

}

// Implement `SequenceType` for `TextFileStreamReader`
extension TextFileStreamReader : Sequence {
    /// - Returns: An iterator to be used for iterating over a `TextFileStreamReader` object.
    public func makeIterator() -> AnyIterator<String> {
        return AnyIterator {
            return self.nextLine()
        }
    }
}
