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
public class TextFile: File<String> {

    /// The text file's string encoding.
    public var encoding: NSStringEncoding

    /// Initializes a text file from a path.
    ///
    /// - Parameter path: The path to be created a text file from.
    public override init(path: Path) {
        self.encoding = NSUTF8StringEncoding
        super.init(path: path)
    }

    /// Initializes a text file from a path with an encoding.
    ///
    /// - Parameter path: The path to be created a text file from.
    /// - Parameter encoding: The encoding to be used for the text file.
    public init(path: Path, encoding: NSStringEncoding) {
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
    public override func write(data: String, atomically useAuxiliaryFile: Bool) throws {
        do {
            try data.writeToFile(path.rawValue, atomically: useAuxiliaryFile, encoding: encoding)
        } catch {
            throw FileKitError.WriteToFileFail(path: path)
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
    @warn_unused_result
    public func streamReader(delimiter: String = "\n",
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
    public func grep(motif: String, include: Bool = true,
        options: NSStringCompareOptions = []) -> [String] {
            guard let reader = streamReader() else {
                return []
            }
            defer {
                reader.close()
            }
            return reader.filter {($0.rangeOfString(motif, options: options) != nil) == include }
    }

}

/// A class to read `TextFile` line by line.
public class TextFileStreamReader {

    /// The text encoding.
    public let encoding: NSStringEncoding
    
    /// The chunk size when reading.
    public let chunkSize: Int

    /// Tells if the position is at the end of file.
    public var atEOF: Bool = false

    let fileHandle: NSFileHandle!
    let buffer: NSMutableData!
    let delimData: NSData!

    // MARK: - Initialization

    /// - Parameter path:      the file path
    /// - Parameter delimiter: the line delimiter (default: \n)
    /// - Parameter encoding: file encoding (default: NSUTF8StringEncoding)
    /// - Parameter chunkSize: size of buffer (default: 4096)
    public init?(
        path: Path,
        delimiter: String = "\n",
        encoding: NSStringEncoding = NSUTF8StringEncoding,
        chunkSize: Int = 4096
    ) {
        self.chunkSize = chunkSize
        self.encoding = encoding

        guard let fileHandle = path.fileHandleForReading,
            delimData = delimiter.dataUsingEncoding(encoding),
            buffer = NSMutableData(capacity: chunkSize) else {
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
    public func nextLine() -> String? {
        if atEOF {
            return nil
        }

        // Read data chunks from file until a line delimiter is found.
        var range = buffer.rangeOfData(delimData, options: [], range: NSRange(location: 0, length: buffer.length))
        while range.location == NSNotFound {
            let tmpData = fileHandle.readDataOfLength(chunkSize)
            if tmpData.length == 0 {
                // EOF or read error.
                atEOF = true
                if buffer.length > 0 {
                    // Buffer contains last line in file (not terminated by delimiter).
                    let line = NSString(data: buffer, encoding: encoding)

                    buffer.length = 0
                    return line as String?
                }
                // No more lines.
                return nil
            }
            buffer.appendData(tmpData)
            range = buffer.rangeOfData(delimData, options: [], range: NSRange(location: 0, length: buffer.length))
        }

        // Convert complete line (excluding the delimiter) to a string.
        let line = NSString(data: buffer.subdataWithRange(NSRange(location: 0, length: range.location)),
            encoding: encoding)
        // Remove line (and the delimiter) from the buffer.
        let cleaningRange = NSRange(location: 0, length: range.location + range.length)
        buffer.replaceBytesInRange(cleaningRange, withBytes: nil, length: 0)

        return line as? String
    }

    /// Start reading from the beginning of file.
    public func rewind() -> Void {
        fileHandle?.seekToFileOffset(0)
        buffer.length = 0
        atEOF = false
    }

    /// Close the underlying file. No reading must be done after calling this method.
    public func close() -> Void {
        fileHandle?.closeFile()
    }

}

// Implement `SequenceType` for `TextFileStreamReader`
extension TextFileStreamReader : SequenceType {
    /// - Returns: A generator to be used for iterating over a `TextFileStreamReader` object.
    public func generate() -> AnyGenerator<String> {
        return AnyGenerator {
            return self.nextLine()
        }
    }
}
