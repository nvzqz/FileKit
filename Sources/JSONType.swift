//
//  JSONFile.swift
//  FileKit
//
//  Created by phimage on 30/09/2017.
//  Copyright © 2017 Nikolai Vazquez. All rights reserved.
//

import Foundation

public typealias JSONReadableWritable = JSONReadable & JSONWritable

// MARK: JSONReadable

/// A JSON readable object is `Decodable`and provide it`s own decoder
public protocol JSONReadable: Readable, Decodable {
    static var jsonDecoder: JSONDecoder { get }
}
extension JSONReadable {
    // default implementation return the shared one
    public static var jsonDecoder: JSONDecoder {
        return FileKit.jsonDecoder
    }
}
// Implement Readable
extension JSONReadable {

    /// Read a Decodable object
    public static func read(from path: Path) throws -> Self {
        let data = try DataFile(path: path).read()
        do {
            return try jsonDecoder.decode(self, from: data)
        } catch {
            throw FileKitError.readFromFileFail(path: path, error: error)
        }
    }

}

// MARK: JSONWritable

/// A JSON readable object is `Decodable`and provide it`s own decoder
public protocol JSONWritable: Writable, Encodable {
    var jsonEncoder: JSONEncoder { get }
}
extension JSONWritable {
    // default implementation return the shared one
    public var jsonEncoder: JSONEncoder {
        return FileKit.jsonEncoder
    }
}
// Implement Writable
extension JSONWritable {

    public func write(to path: Path, atomically useAuxiliaryFile: Bool) throws {
        do {
            let data = try jsonEncoder.encode(self)
            try DataFile(path: path).write(data, atomically: useAuxiliaryFile)
        } catch let error as FileKitError {
            throw error
        } catch {
            throw FileKitError.writeToFileFail(path: path, error: error)
        }
    }

}
