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

/**
 A representation of a filesystem text file.

 The data type is String.
*/
open class TextFile: File<String> {

    /// The text file's string encoding.
    open var encoding: String.Encoding

    /**
     Initializes a text file from a path.

     - Parameter path: The path to be created a text file from.
    */
    public override init(path: Path) {
        self.encoding = String.Encoding.utf8
        super.init(path: path)
    }

    /**
     Initializes a text file from a path with an encoding.

     - Parameters:
         - path: The path to be created a text file from.
         - encoding: The encoding to be used for the text file.
    */
    public init(path: Path, encoding: String.Encoding) {
        self.encoding = encoding
        super.init(path: path)
    }

    /**
     Writes a string to a text file using the file's encoding.

     - Parameters:
         - data: The string to be written to the text file.
         - useAuxiliaryFile: If `true`, the data is written to an
                             auxiliary file that is then renamed to the
                             file. If `false`, the data is written to
                             the file directly.

     - Throws: `FileKitError.WriteToFileFail`
    */
    open override func write(_ data: String, atomically useAuxiliaryFile: Bool) throws {
        guard let _ = try? data.write(toFile: path._safeRawValue,
                                      atomically: useAuxiliaryFile,
                                      encoding: encoding)
        else {
            throw FileKitError.writeToFileFail(path: path)
        }
    }

}

// MARK: Line Reader

extension TextFile {

    /**
     Provide a reader to read line by line.

     - Parameters:
         - delimiter: the line delimiter (default: \n)
         - chunkSize: size of buffer (default: 4096)

     - Returns: the `TextFileStreamReader`
    */
    public func streamReader(_ delimiter: String = "\n",
                             chunkSize: Int = 4096) -> TextFileStreamReader? {
            return TextFileStreamReader(
                path: self.path,
                delimiter: delimiter,
                encoding: encoding,
                chunkSize: chunkSize
            )
    }

    /**
     Read file and return filtered lines.

     - Parameters:
         - motif: the motif to compare
         - include: check if line include motif if true, exclude if not (default: true)
         - options: optional options  for string comparaison

     - Returns: the lines
    */
    public func grep(_ motif: String, include: Bool = true,
                     options: String.CompareOptions = []) -> [String] {
            guard let reader = streamReader() else {
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
    open let encoding: String.Encoding

    let delimData: Data!
    var fileHandle: FileHandle?

    // MARK: - Initialization
    public init?(
        fileHandle: FileHandle,
        delimiter: String,
        encoding: String.Encoding = .utf8
        ) {
        self.encoding = encoding
        self.fileHandle = fileHandle
        guard let delimData = delimiter.data(using: encoding) else {
              return nil
        }
        self.delimData = delimData
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
}

/// A class to read `TextFile` line by line.
open class TextFileStreamReader: TextFileStream {

    /// The chunk size when reading.
    open let chunkSize: Int

    /// Tells if the position is at the end of file.
    open var atEOF: Bool = false

    var buffer: Data!

    // MARK: - Initialization

    /**
     - Parameters:
         - path: the file path
         - delimiter: the line delimiter (default: \n)
         - encoding: file encoding (default: .utf8)
         - chunkSize: size of buffer (default: 4096)
    */
    public init?(
        path: Path,
        delimiter: String = "\n",
        encoding: String.Encoding = .utf8,
        chunkSize: Int = 4096
    ) {
        self.chunkSize = chunkSize
        guard let fileHandle = path.fileHandleForReading else {
            self.buffer = nil
            return nil
        }
        self.buffer = Data(capacity: chunkSize)
        super.init(fileHandle: fileHandle, delimiter: delimiter, encoding: encoding)
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
            let tmpData = fileHandle?.readData(ofLength: chunkSize)
            guard let tmp = tmpData, !tmp.isEmpty else {
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
            buffer.append(tmp)
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
extension TextFileStreamReader : Sequence {
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

    public var append: Bool
    // MARK: - Initialization

    /**
     - Parameters:
         - path: the file path
         - delimiter: the line delimiter (default: \n)
         - encoding: file encoding (default: .utf8)
         - append: if true append at file end (default: false)
         - createIfNotExist: if true create file if not exixt (default: true)
    */
    public init?(
        path: Path,
        delimiter: String = "\n",
        encoding: String.Encoding = .utf8,
        append: Bool = false,
        createIfNotExist: Bool = true
        ) {
        if createIfNotExist && !path.exists {
            try? path.createFile()
        }
        guard let fileHandle = path.fileHandleForWriting else {
            return nil
        }
        self.append = append
        if append {
            fileHandle.seekToEndOfFile()
        }
        super.init(fileHandle: fileHandle, delimiter: delimiter, encoding: encoding)
    }

    /**
     Write a new line in file

     - Parameters:
         - line: the line
         - delim: append the delimiter (default: true)

     - Throws: `FileKitError.WriteToFileFail`
    */
    open func write(line: String, delim: Bool = true) -> Bool {
        guard let handle = fileHandle, let data = line.data(using: self.encoding) else {
            return false
        }
        if delim && append {
            handle.write(delimData)
        }
        handle.write(data)
        if delim && !append {
            handle.write(delimData)
        }
        return true
    }

    /// Causes all in-memory data and attributes of the file represented by the receiver to be written to permanent storage.
    open func synchronize() {
        fileHandle?.synchronizeFile()
    }
}

extension TextFile {

    /**
     Provide a writer to write line by line.

     - Parameters:
         - delimiter: the line delimiter (default: \n)
         - append: if true append at file end (default: false)

     - Returns: the `TextFileStreamWriter`
    */
    public func streamWriter(_ delimiter: String = "\n", append: Bool = false) -> TextFileStreamWriter? {
        return TextFileStreamWriter(
            path: self.path,
            delimiter: delimiter,
            encoding: encoding,
            append: append
        )
    }

}
