//
//  PropertyListFile.swift
//  FileKit
//
//  Created by phimage on 30/09/2017.
//  Copyright © 2017 Nikolai Vazquez. All rights reserved.
//

import Foundation

public typealias PropertyListReadableWritable = PropertyListReadable & PropertyListWritable

// MARK: PropertyListReadable

/// A PropertyList readable object is `Decodable`and provide it`s own decoder
public protocol PropertyListReadable: Readable, Decodable {
    static var propertyListDecoder: PropertyListDecoder { get }
}
extension PropertyListReadable {
    // default implementation return the shared one
    public static var propertyListDecoder: PropertyListDecoder {
        return FileKit.propertyListDecoder
    }
}
// Implement Readable
extension PropertyListReadable {

    /// Read a Decodable object
    public static func read(from path: Path) throws -> Self {
        let data = try DataFile(path: path).read()
        do {
            return try propertyListDecoder.decode(self, from: data)
        } catch {
            throw FileKitError.readFromFileFail(path: path, error: error)
        }
    }

}

// MARK: PropertyListWritable

/// A PropertyList readable object is `Decodable`and provide it`s own decoder
public protocol PropertyListWritable: Writable, Encodable {
    var propertyListEncoder: PropertyListEncoder { get }
}
extension PropertyListWritable {
    // default implementation return the shared one
    public var propertyListEncoder: PropertyListEncoder {
        return FileKit.propertyListEncoder
    }
}
// Implement Writable
extension PropertyListWritable {

    public func write(to path: Path, atomically useAuxiliaryFile: Bool) throws {
        do {
            let data = try propertyListEncoder.encode(self)
            try DataFile(path: path).write(data, atomically: useAuxiliaryFile)
        } catch let error as FileKitError {
            throw error
        } catch {
            throw FileKitError.writeToFileFail(path: path, error: error)
        }
    }

}
