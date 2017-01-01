//
//  GCDFSEvent.swift
//  FileKit
//
//  Created by ijump on 5/2/16.
//  Copyright © 2017 Nikolai Vazquez. All rights reserved.
//

import Foundation

/// File System Events.
public struct DispatchFileSystemEvents: OptionSet, CustomStringConvertible, CustomDebugStringConvertible {

    // MARK: - Events

    /// The file-system object was deleted from the namespace.
    public static let Delete = DispatchFileSystemEvents(rawValue: DispatchSource.FileSystemEvent.delete.rawValue)

    /// The file-system object data changed.
    public static let Write = DispatchFileSystemEvents(rawValue: DispatchSource.FileSystemEvent.write.rawValue)

    /// The file-system object changed in size.
    public static let Extend = DispatchFileSystemEvents(rawValue: DispatchSource.FileSystemEvent.extend.rawValue)

    /// The file-system object metadata changed.
    public static let Attribute = DispatchFileSystemEvents(rawValue: DispatchSource.FileSystemEvent.attrib.rawValue)

    /// The file-system object link count changed.
    public static let Link = DispatchFileSystemEvents(rawValue: DispatchSource.FileSystemEvent.link.rawValue)

    /// The file-system object was renamed in the namespace.
    public static let Rename = DispatchFileSystemEvents(rawValue: DispatchSource.FileSystemEvent.rename.rawValue)

    /// The file-system object was revoked.
    public static let Revoke = DispatchFileSystemEvents(rawValue: DispatchSource.FileSystemEvent.revoke.rawValue)

    /// The file-system object was created.
    public static let Create = DispatchFileSystemEvents(rawValue: 0x1000)

    /// All of the event IDs.
    public static let All: DispatchFileSystemEvents = [.Delete, .Write, .Extend, .Attribute, .Link, .Rename, .Revoke, .Create]

    // MARK: - All Events

    /// An array of all of the events.
    public static let allEvents: [DispatchFileSystemEvents] = [
        .Delete, .Write, .Extend, .Attribute, .Link, .Rename, .Revoke, .Create
    ]

    /// The names of all of the events.
    public static let allEventNames: [String] = [
        "Delete", "Write", "Extend", "Attribute", "Link", "Rename", "Revoke", "Create"
    ]

    // MARK: - Properties

    /// The raw event value.
    public let rawValue: UInt

    /// A textual representation of `self`.
    public var description: String {
        var result = ""
        for (index, element) in DispatchFileSystemEvents.allEvents.enumerated() {
            if self.contains(element) {
                let name = DispatchFileSystemEvents.allEventNames[index]
                result += result.isEmpty ? "\(name)": ", \(name)"
            }
        }
        return String(describing: type(of: self)) + "[\(result)]"
    }

    /// A textual representation of `self`, suitable for debugging.
    public var debugDescription: String {
        var result = ""
        for (index, element) in DispatchFileSystemEvents.allEvents.enumerated() {
            if self.contains(element) {
                let name = DispatchFileSystemEvents.allEventNames[index] + "(\(element.rawValue))"
                result += result.isEmpty ? "\(name)": ", \(name)"
            }
        }
        return String(describing: type(of: self)) + "[\(result)]"
    }

    // MARK: - Initialization

    /// Creates a set of events from a raw value.
    ///
    /// - Parameter rawValue: The raw value to initialize from.
    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }

}
