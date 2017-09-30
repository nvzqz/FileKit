//
//  FileSystemEvent.swift
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

#if os(OSX)

/// A filesystem event.
public struct FileSystemEvent {

    // MARK: - Static Properties

    /// All of the event IDs.
    public static let allEventId = 0

    /// The last event ID since now.
    public static let nowEventId = FSEventStreamEventId(kFSEventStreamEventIdSinceNow)

    // MARK: - Properties

    /// The ID of the event.
    public var id: FSEventStreamEventId // swiftlint:disable:this variable_name

    /// The path for the event.
    public var path: Path

    /// The flags of the event.
    public var flags: FileSystemEventFlags
}

extension Path {

    // MARK: - Watching

    /// Watches a path for filesystem events and handles them in the callback.
    ///
    /// - Parameter latency: The latency in seconds.
    /// - Parameter queue: The queue to be run within.
    /// - Parameter callback: The callback to handle events.
    /// - Returns: The `FileSystemWatcher` object.
    public func watch(_ latency: TimeInterval = 0, queue: DispatchQueue = DispatchQueue.main, callback: @escaping (FileSystemEvent) -> Void) -> FileSystemWatcher {
        let watcher = FileSystemWatcher(paths: [self], latency: latency, queue: queue, callback: callback)
        watcher.watch()
        return watcher
    }
}

extension Sequence where Self.Iterator.Element == Path {

    // MARK: - Watching

    /// Watches the sequence of paths for filesystem events and handles them in
    /// the callback.
    ///
    /// - Parameter latency: The latency in seconds.
    /// - Parameter queue: The queue to be run within.
    /// - Parameter callback: The callback to handle events.
    /// - Returns: The `FileSystemWatcher` object.
    public func watch(_ latency: TimeInterval = 0, queue: DispatchQueue = DispatchQueue.main, callback: @escaping (FileSystemEvent) -> Void) -> FileSystemWatcher {
        let watcher = FileSystemWatcher(paths: Array(self), latency: latency, queue: queue, callback: callback)
        watcher.watch()
        return watcher
    }

}

/// A set of fileystem event flags.
public struct FileSystemEventFlags: OptionSet, CustomStringConvertible, CustomDebugStringConvertible {

    // MARK: - Options

    /// There was some change in the directory at the specific path supplied in
    /// this event.
    public static let None = FileSystemEventFlags(rawValue: kFSEventStreamEventFlagNone)

    /// Your application must rescan not just the directory given in the event,
    /// but all its children, recursively.
    public static let MustScanSubDirs = FileSystemEventFlags(rawValue: kFSEventStreamEventFlagMustScanSubDirs)

    /// May be set in addition to `MustScanSubDirs` indicate that a problem
    /// occurred in buffering the events (the particular flag set indicates
    /// where the problem occurred) and that the client must do a full scan of
    /// any directories (and their subdirectories, recursively) being monitored
    /// by this stream.
    public static let UserDropped = FileSystemEventFlags(rawValue: kFSEventStreamEventFlagUserDropped)

    /// May be set in addition to `MustScanSubDirs` indicate that a problem
    /// occurred in buffering the events (the particular flag set indicates
    /// where the problem occurred) and that the client must do a full scan of
    /// any directories (and their subdirectories, recursively) being monitored
    /// by this stream.
    public static let KernelDropped = FileSystemEventFlags(rawValue: kFSEventStreamEventFlagKernelDropped)

    /// The 64-bit event ID counter wrapped around.
    public static let EventIdsWrapped = FileSystemEventFlags(rawValue: kFSEventStreamEventFlagEventIdsWrapped)

    /// Denotes a sentinel event sent to mark the end of the "historical" events
    /// sent as a result of specifying a `sinceWhen` value in the
    /// FSEventStreamCreate...() call that created this event stream.
    public static let HistoryDone = FileSystemEventFlags(rawValue: kFSEventStreamEventFlagHistoryDone)

    /// Denotes a special event sent when there is a change to one of the
    /// directories along the path to one of the directories asked to watch.
    public static let RootChanged = FileSystemEventFlags(rawValue: kFSEventStreamEventFlagRootChanged)

    /// Denotes a special event sent when a volume is mounted underneath one of
    /// the paths being monitored.
    public static let Mount = FileSystemEventFlags(rawValue: kFSEventStreamEventFlagMount)

    /// Denotes a special event sent when a volume is unmounted underneath one
    /// of the paths being monitored.
    public static let Unmount = FileSystemEventFlags(rawValue: kFSEventStreamEventFlagUnmount)

    /// A file system object was created at the specific path supplied in this
    /// event.
    public static let Created = FileSystemEventFlags(rawValue: kFSEventStreamEventFlagItemCreated)

    /// A file system object was removed at the specific path supplied in this
    /// event.
    public static let ItemRemoved = FileSystemEventFlags(rawValue: kFSEventStreamEventFlagItemRemoved)

    /// A file system object at the specific path supplied in this event had its
    /// metadata modified.
    public static let ItemInodeMetaMod = FileSystemEventFlags(rawValue: kFSEventStreamEventFlagItemInodeMetaMod)

    /// A file system object was renamed at the specific path supplied in this
    /// event.
    public static let ItemRenamed = FileSystemEventFlags(rawValue: kFSEventStreamEventFlagItemRenamed)

    /// A file system object at the specific path supplied in this event had its
    /// data modified.
    public static let ItemModified = FileSystemEventFlags(rawValue: kFSEventStreamEventFlagItemModified)

    /// A file system object at the specific path supplied in this event had its
    /// FinderInfo data modified.
    public static let ItemFinderInfoMod = FileSystemEventFlags(rawValue: kFSEventStreamEventFlagItemFinderInfoMod)

    /// A file system object at the specific path supplied in this event had its
    /// ownership changed.
    public static let ItemChangeOwner = FileSystemEventFlags(rawValue: kFSEventStreamEventFlagItemChangeOwner)

    /// A file system object at the specific path supplied in this event had its
    /// extended attributes modified.
    public static let ItemXattrMod = FileSystemEventFlags(rawValue: kFSEventStreamEventFlagItemXattrMod)

    /// The file system object at the specific path supplied in this event is a
    /// regular file.
    public static let ItemIsFile = FileSystemEventFlags(rawValue: kFSEventStreamEventFlagItemIsFile)

    /// The file system object at the specific path supplied in this event is a
    /// directory.
    public static let ItemIsDir = FileSystemEventFlags(rawValue: kFSEventStreamEventFlagItemIsDir)

    /// The file system object at the specific path supplied in this event is a
    /// symbolic link.
    public static let ItemIsSymlink = FileSystemEventFlags(rawValue: kFSEventStreamEventFlagItemIsSymlink)

    /// Indicates the event was triggered by the current process.
    public static let OwnEvent = FileSystemEventFlags(rawValue: kFSEventStreamEventFlagOwnEvent)

    /// Flag for if the item is a hardlink.
    @available(iOS 9, OSX 10.10, *)
    public static let ItemIsHardlink = FileSystemEventFlags(rawValue: kFSEventStreamEventFlagItemIsHardlink)

    /// Flag for if the item was the last hardlink.
    @available(iOS 9, OSX 10.10, *)
    public static let ItemIsLastHardlink = FileSystemEventFlags(rawValue: kFSEventStreamEventFlagItemIsLastHardlink)

    // MARK: - All Flags

    /// An array of all of the flags.
    public static var allFlags: [FileSystemEventFlags] = {
        var array: [FileSystemEventFlags] = [ // swiftlint:disable comma
            .None,              .MustScanSubDirs,       .UserDropped,
            .KernelDropped,     .EventIdsWrapped,       .HistoryDone,
            .RootChanged,       .Mount,                 .Unmount,
            .ItemRemoved,       .ItemInodeMetaMod,      .ItemRenamed,
            .ItemModified,      .ItemFinderInfoMod,     .ItemChangeOwner,
            .ItemXattrMod,      .ItemIsFile,            .ItemIsDir,
            .ItemIsSymlink,     .OwnEvent
        ] // swiftlint:enable comma
        if #available(iOS 9, OSX 10.10, *) {
            array += [.ItemIsHardlink, .ItemIsLastHardlink ]
        }
        return array
    }()

    /// The names of all of the flags.
    public static let allFlagNames: [String] = {
        var array: [String] = [ // swiftlint:disable comma
            "None",             "MustScanSubDirs",      "UserDropped",
            "KernelDropped",    "EventIdsWrapped",      "HistoryDone",
            "RootChanged",      "Mount",                "Unmount",
            "ItemRemoved",      "ItemInodeMetaMod",     "ItemRenamed",
            "ItemModified",     "ItemFinderInfoMod",    "ItemChangeOwner",
            "ItemXattrMod",     "ItemIsFile",           "ItemIsDir",
            "ItemIsSymlink",    "OwnEvent"
        ] // swiftlint:enable comma
        if #available(iOS 9, OSX 10.10, *) {
            array += ["ItemIsHardlink", "ItemIsLastHardlink"]
        }
        return array
    }()

    // MARK: - Properties

    /// The raw event stream flag values.
    public let rawValue: Int

    /// A textual representation of `self`.
    public var description: String {
        var result = ""
        for (index, element) in FileSystemEventFlags.allFlags.enumerated() {
            if self.contains(element) {
                let name = FileSystemEventFlags.allFlagNames[index]
                result += result.isEmpty ? "\(name)": ", \(name)"
            }
        }
        return String(describing: type(of: self)) + "[\(result)]"
    }

    /// A textual representation of `self`, suitable for debugging.
    public var debugDescription: String {
        var result = ""
        for (index, element) in FileSystemEventFlags.allFlags.enumerated() {
            if self.contains(element) {
                let name = FileSystemEventFlags.allFlagNames[index] + "(\(element.rawValue))"
                result += result.isEmpty ? "\(name)": ", \(name)"
            }
        }
        return String(describing: type(of: self)) + "[\(result)]"
    }

    // MARK: - Initialization

    /// Creates a set of event stream flags from a raw value.
    ///
    /// - Parameter rawValue: The raw value to initialize from.
    public init(rawValue: Int) { self.rawValue = rawValue }

}

/// Flags for creating an event stream.
public struct FileSystemEventStreamCreateFlags: OptionSet, CustomStringConvertible, CustomDebugStringConvertible {

    // MARK: - Options

    /// The default.
    public static let None = FileSystemEventStreamCreateFlags(rawValue: kFSEventStreamCreateFlagNone)

    /// The callback function will be invoked with CF types rather than raw C
    /// types.
    public static let UseCFTypes = FileSystemEventStreamCreateFlags(rawValue: kFSEventStreamCreateFlagUseCFTypes)

    /// Affects the meaning of the latency parameter.
    public static let FlagNoDefer = FileSystemEventStreamCreateFlags(rawValue: kFSEventStreamCreateFlagNoDefer)

    /// Request notifications of changes along the path to the path(s) watched.
    public static let WatchRoot = FileSystemEventStreamCreateFlags(rawValue: kFSEventStreamCreateFlagWatchRoot)

    /// Don't send events that were triggered by the current process.
    public static let IgnoreSelf = FileSystemEventStreamCreateFlags(rawValue: kFSEventStreamCreateFlagIgnoreSelf)

    /// Request file-level notifications.
    public static let FileEvents = FileSystemEventStreamCreateFlags(rawValue: kFSEventStreamCreateFlagFileEvents)

    /// Tag events that were triggered by the current process with the
    /// `OwnEvent` flag.
    public static let MarkSelf = FileSystemEventStreamCreateFlags(rawValue: kFSEventStreamCreateFlagMarkSelf)

    // MARK: - All Flags

    /// All of the event stream creation flags.
    public static let allFlags: [FileSystemEventStreamCreateFlags] = [.None, .UseCFTypes, .FlagNoDefer, .WatchRoot, .IgnoreSelf, .FileEvents, .MarkSelf]

    /// All of the names of the event stream creation flags.
    public static let allFlagNames: [String] = ["None", "UseCFTypes", "FlagNoDefer", "WatchRoot", "IgnoreSelf", "FileEvents", "MarkSelf" ]

    // MARK: - Properties

    /// The raw event stream creation flags.
    public let rawValue: Int

    /// A textual representation of `self`.
    public var description: String {
        var result = ""
        for (index, element) in FileSystemEventStreamCreateFlags.allFlags.enumerated() {
            if self.contains(element) {
                let name = FileSystemEventStreamCreateFlags.allFlagNames[index]
                result += result.isEmpty ? "\(name)": ", \(name)"
            }
        }
        return String(describing: type(of: self)) + "[\(result)]"
    }

    /// A textual representation of `self`, suitable for debugging.
    public var debugDescription: String {
        var result = ""
        for (index, element) in FileSystemEventStreamCreateFlags.allFlags.enumerated() {
            if self.contains(element) {
                let name = FileSystemEventStreamCreateFlags.allFlagNames[index] + "(\(element.rawValue))"
                result += result.isEmpty ? "\(name)": ", \(name)"
            }
        }
        return String(describing: type(of: self)) + "[\(result)]"
    }

    // MARK: - Initialization

    /// Creates a set of event stream creation flags from a raw value.
    ///
    /// - Parameter rawValue: The raw value to initialize from.
    public init(rawValue: Int) { self.rawValue = rawValue }

}

#endif
