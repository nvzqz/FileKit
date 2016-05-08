//
//  FileProtection.swift
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

#if os(iOS) || os(watchOS) || os(tvOS)

/// The values that can be obtained from `NSFileProtectionKey` on a
/// file's attributes. Only available on iOS, watchOS, and tvOS.
public enum FileProtection: String {

    /// The file has no special protections associated with it.
    case None

    /// The file is stored in an encrypted format on disk and cannot be read
    /// from or written to while the device is locked or booting.
    case Complete

    /// The file is stored in an encrypted format on disk. Files can be created
    /// while the device is locked, but once closed, cannot be opened again
    /// until the device is unlocked.
    case CompleteUnlessOpen

    /// The file is stored in an encrypted format on disk and cannot be accessed
    /// until after the device has booted.
    case CompleteUntilFirstUserAuthentication

    /// Initializes `self` from a file protection value.
    ///
    /// - Parameter rawValue: The raw value to initialize from.
    ///
    public init?(rawValue: String) {
        switch rawValue {
        case NSFileProtectionNone:
            self = None
        case NSFileProtectionComplete:
            self = Complete
        case NSFileProtectionCompleteUnlessOpen:
            self = CompleteUnlessOpen
        case NSFileProtectionCompleteUntilFirstUserAuthentication:
            self = CompleteUntilFirstUserAuthentication
        default:
            return nil
        }
    }

    /// The file protection string value of `self`.
    public var rawValue: String {
        switch self {
        case .None:
            return NSFileProtectionNone
        case .Complete:
            return NSFileProtectionComplete
        case .CompleteUnlessOpen:
            return NSFileProtectionCompleteUnlessOpen
        case .CompleteUntilFirstUserAuthentication:
            return NSFileProtectionCompleteUntilFirstUserAuthentication
        }
    }

    ///  Return the equivalent NSDataWritingOptions
    public var dataWritingOption: NSDataWritingOptions {
        switch self {
        case .None:
            return .DataWritingFileProtectionNone
        case .Complete:
            return .DataWritingFileProtectionComplete
        case .CompleteUnlessOpen:
            return .DataWritingFileProtectionCompleteUnlessOpen
        case .CompleteUntilFirstUserAuthentication:
            return .DataWritingFileProtectionCompleteUntilFirstUserAuthentication
        }
    }

}

extension Path {

    // MARK: File Protection

    /// The protection of the file at the path.
    public var fileProtection: FileProtection? {
        guard let value = attributes[NSFileProtectionKey] as? String,
            protection  = FileProtection(rawValue: value) else {
            return nil
        }
        return protection
    }

    /// Creates a file at path with specified file protection.
    ///
    /// - Parameter fileProtection: the protection to apply to the file.
    ///
    /// Throws an error if the file cannot be created.
    ///
    /// - Throws: `FileKitError.CreateFileFail`
    ///
    public func createFile(fileProtection: FileProtection) throws {
        let manager = NSFileManager()
        let attributes = [NSFileProtectionKey : fileProtection.rawValue]
        if !manager.createFileAtPath(_safeRawValue, contents: nil, attributes: attributes) {
            throw FileKitError.CreateFileFail(path: self)
        }
    }

}

extension File {

    // MARK: File Protection

    /// The protection of `self`.
    public var protection: FileProtection? {
        return path.fileProtection
    }

    /// Creates the file with specified file protection.
    ///
    /// - Parameter fileProtection: the protection to apply to the file.
    ///
    /// Throws an error if the file cannot be created.
    ///
    /// - Throws: `FileKitError.CreateFileFail`
    ///
    public func create(fileProtection: FileProtection) throws {
        try path.createFile(fileProtection)
    }

}

extension File where Data: NSData {

    /// Writes data to the file.
    ///
    /// - Parameter data: The data to be written to the file.
    /// - Parameter fileProtection: the protection to apply to the file.
    /// - Parameter atomically: If `true`, the data is written to an
    ///                         auxiliary file that is then renamed to the
    ///                         file. If `false`, the data is written to
    ///                         the file directly.
    ///
    /// - Throws: `FileKitError.WriteToFileFail`
    ///
    public func write(data: Data, fileProtection: FileProtection, atomically: Bool = true) throws {
        var options = fileProtection.dataWritingOption
        if atomically {
            options.unionInPlace(NSDataWritingOptions.DataWritingAtomic)
        }
        try self.write(data, options: options)
    }

}

#endif
