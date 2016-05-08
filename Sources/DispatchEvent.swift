//
//  GCDFSEvent.swift
//  FileKit
//
//  Created by ijump on 5/2/16.
//  Copyright © 2016 Nikolai Vazquez. All rights reserved.
//

import Foundation

/// Dispatch source type.
public struct DispatchSourceType {

    // MARK: - Static Properties

    /// A dispatch source that monitors a file descriptor for events defined by `dispatch_source_vnode_flags_t`.
    public static let Vnode = DISPATCH_SOURCE_TYPE_VNODE

    /// A dispatch source that monitors a file descriptor for pending bytes available to be read.
    public static let Read = DISPATCH_SOURCE_TYPE_READ

    /// A dispatch source that monitors a file descriptor for available buffer space to write bytes.
    public static let Write = DISPATCH_SOURCE_TYPE_WRITE

}


/// Vnode Events.
public struct DispatchVnodeEvents: OptionSetType, CustomStringConvertible, CustomDebugStringConvertible {

    // MARK: - Events

    /// The file-system object was deleted from the namespace.
    public static let Delete = DispatchVnodeEvents(rawValue: DISPATCH_VNODE_DELETE)

    /// The file-system object data changed.
    public static let Write = DispatchVnodeEvents(rawValue: DISPATCH_VNODE_WRITE)

    /// The file-system object changed in size.
    public static let Extend = DispatchVnodeEvents(rawValue: DISPATCH_VNODE_EXTEND)

    /// The file-system object metadata changed.
    public static let Attribute = DispatchVnodeEvents(rawValue: DISPATCH_VNODE_ATTRIB)

    /// The file-system object link count changed.
    public static let Link = DispatchVnodeEvents(rawValue: DISPATCH_VNODE_LINK)

    /// The file-system object was renamed in the namespace.
    public static let Rename = DispatchVnodeEvents(rawValue: DISPATCH_VNODE_RENAME)

    /// The file-system object was revoked.
    public static let Revoke = DispatchVnodeEvents(rawValue: DISPATCH_VNODE_REVOKE)

    /// The file-system object was created.
    public static let Create = DispatchVnodeEvents(rawValue: 0x1000)

    /// All of the event IDs.
    public static let All: DispatchVnodeEvents = [.Delete, .Write, .Extend, .Attribute, .Link, .Rename, .Revoke, .Create]

    // MARK: - All Events

    /// An array of all of the events.
    public static let allEvents: [DispatchVnodeEvents] = [
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
        for (index, element) in DispatchVnodeEvents.allEvents.enumerate() {
            if self.contains(element) {
                let name = DispatchVnodeEvents.allEventNames[index]
                result += result.isEmpty ? "\(name)": ", \(name)"
            }
        }
        return String(self.dynamicType) + "[\(result)]"
    }

    /// A textual representation of `self`, suitable for debugging.
    public var debugDescription: String {
        var result = ""
        for (index, element) in DispatchVnodeEvents.allEvents.enumerate() {
            if self.contains(element) {
                let name = DispatchVnodeEvents.allEventNames[index] + "(\(element.rawValue))"
                result += result.isEmpty ? "\(name)": ", \(name)"
            }
        }
        return String(self.dynamicType) + "[\(result)]"
    }

    // MARK: - Initialization

    /// Creates a set of events from a raw value.
    ///
    /// - Parameter rawValue: The raw value to initialize from.
    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }

}
