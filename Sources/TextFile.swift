//
//  TextFile.swift
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
            throw FileKitError.writeToFileFail(path: path, error: error)
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
    ///
    /// - Throws:
    ///     `FileKitError.readFromFileFail`
    public func streamReader(_ delimiter: String = "\n",
                             chunkSize: Int = 4096) throws -> TextFileStreamReader {
            return try TextFileStreamReader(
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
                     options: String.CompareOptions = []) -> [String] {
            guard let reader = try? streamReader() else {
                return []
            }
            defer {
                reader.close()
            }
            return reader.filter {($0.range(of: motif, options: options) != nil) == include }
    }

}

/// A class to read or write `TextFile`.
open class TextFileStream {

    /// The text encoding.
    public let encoding: String.Encoding

    let delimData: Data
    var fileHandle: FileHandle?

    // MARK: - Initialization
    public init(
        fileHandle: FileHandle,
        delimiter: Data,
        encoding: String.Encoding = .utf8
        ) throws {
        self.encoding = encoding
        self.fileHandle = fileHandle
        self.delimData = delimiter
    }

    // MARK: - Deinitialization

    deinit {
        self.close()
    }

    // MARK: - public methods

    open var offset: UInt64 {
        return fileHandle?.offsetInFile ?? 0
    }

    open func seek(toFileOffset offset: UInt64) {
        fileHandle?.seek(toFileOffset: offset)
    }

    /// Close the underlying file. No reading must be done after calling this method.
    open func close() {
        fileHandle?.closeFile()
        fileHandle = nil
    }

    /// Return true if file handle closed.
    open var isClosed: Bool {
        return fileHandle == nil
    }
}

/// A class to read `TextFile` line by line.
open class TextFileStreamReader: TextFileStream {

    /// The chunk size when reading.
    public let chunkSize: Int

    /// Tells if the position is at the end of file.
    open var atEOF: Bool = false

    var buffer: Data!

    // MARK: - Initialization

    /// - Parameter path:      the file path
    /// - Parameter delimiter: the line delimiter (default: \n)
    /// - Parameter encoding: file encoding (default: .utf8)
    /// - Parameter chunkSize: size of buffer (default: 4096)
    public init(
        path: Path,
        delimiter: String = "\n",
        encoding: String.Encoding = .utf8,
        chunkSize: Int = 4096
        ) throws {
        self.chunkSize = chunkSize
        let fileHandle = try path.fileHandle(for: .read)
        self.buffer = Data(capacity: chunkSize)

        guard let delimData = delimiter.data(using: encoding) else {
            throw FileKitError.ReasonError.encoding(encoding, data: delimiter)
        }
        try super.init(fileHandle: fileHandle, delimiter: delimData, encoding: encoding)
    }

    // MARK: - public methods

    /// - Returns: The next line, or nil on EOF.
    open func nextLine() -> String? {
        if atEOF {
            return nil
        }

        // Read data chunks from file until a line delimiter is found.
        var range = buffer.range(of: delimData, options: [], in: 0..<buffer.count)
        while range == nil {
            guard let tmpData = fileHandle?.readData(ofLength: chunkSize), !tmpData.isEmpty else {
                // EOF or read error.
                atEOF = true
                if !buffer.isEmpty {
                    // Buffer contains last line in file (not terminated by delimiter).
                    let line = String(data: buffer, encoding: encoding)

                    buffer.count = 0
                    return line
                }
                // No more lines.
                return nil
            }
            buffer.append(tmpData)
            range = buffer.range(of: delimData, options: [], in: 0..<buffer.count)
        }

        // Convert complete line (excluding the delimiter) to a string.
        let line = String(data: buffer.subdata(in: 0..<range!.lowerBound), encoding: encoding)

        // Remove line (and the delimiter) from the buffer.
        let cleaningRange: Range<Data.Index> = 0..<range!.upperBound
        buffer.replaceSubrange(cleaningRange, with: Data())

        return line
    }

    /// Start reading from the beginning of file.
    open func rewind() {
        fileHandle?.seek(toFileOffset: 0)
        buffer.count = 0
        atEOF = false
    }

}

// Implement `SequenceType` for `TextFileStreamReader`
extension TextFileStreamReader: Sequence {
    /// - Returns: An iterator to be used for iterating over a `TextFileStreamReader` object.
    public func makeIterator() -> AnyIterator<String> {
        return AnyIterator {
            return self.nextLine()
        }
    }
}

// MARK: Line Writer
/// A class to write a `TextFile` line by line.
open class TextFileStreamWriter: TextFileStream {

    public let append: Bool

    // MARK: - Initialization

    /// - Parameter path:      the file path
    /// - Parameter delimiter: the line delimiter (default: \n)
    /// - Parameter encoding: file encoding (default: .utf8)
    /// - Parameter append: if true append at file end (default: false)
    /// - Parameter createIfNotExist: if true create file if not exixt (default: true)
    public init(
        path: Path,
        delimiter: String = "\n",
        encoding: String.Encoding = .utf8,
        append: Bool = false,
        createIfNotExist: Bool = true
        ) throws {

        if createIfNotExist && !path.exists {
            try path.createFile()
        }
        self.append = append
        let fileHandle = try path.fileHandle(for: .write)
        if append {
            fileHandle.seekToEndOfFile()
        }
        guard let delimData = delimiter.data(using: encoding) else {
            throw FileKitError.ReasonError.encoding(encoding, data: delimiter)
        }
        try super.init(fileHandle: fileHandle, delimiter: delimData, encoding: encoding)
    }

    /// Write a new line in file
    /// - Parameter line:      the line
    /// - Parameter delim:     append the delimiter (default: true)
    ///
    /// - Returns: true if successfully.
    @discardableResult
    open func write(line: String, delim: Bool = true) -> Bool {
        if let handle = fileHandle, let data = line.data(using: self.encoding) {
            handle.write(data)
            if delim {
                handle.write(delimData)
            }
            return true
        }
        return false
    }

    /// Write a line delimiter.
    ///
    /// - Returns: true if successfully.
    open func writeDelimiter() -> Bool {
        if let handle = fileHandle {
            handle.write(delimData)
            return true
        }
        return false
    }

    /// Causes all in-memory data and attributes of the file represented by the receiver to be written to permanent storage.
    open func synchronize() {
        fileHandle?.synchronizeFile()
    }
}

extension TextFile {

    /// Provide a writer to write line by line.
    ///
    /// - Parameter delimiter: the line delimiter (default: \n)
    /// - Parameter append: if true append at file end (default: false)
    ///
    /// - Returns: the `TextFileStreamWriter`
    ///
    /// - Throws:
    ///     `FileKitError.CreateFileFail`,
    ///     `FileKitError.writeToFileFail`
    public func streamWriter(_ delimiter: String = "\n", append: Bool = false) throws -> TextFileStreamWriter {
        return try TextFileStreamWriter(
            path: self.path,
            delimiter: delimiter,
            encoding: encoding,
            append: append
        )
    }

}
