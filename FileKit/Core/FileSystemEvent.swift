//
//  FileSystemEvent.swift
//  FileKit
//
//  The MIT License (MIT)
//
//  Copyright (c) 2015 Nikolai Vazquez
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

// MARK: - FileSystemEvent
/// A filesystem event.
public struct FileSystemEvent {

    /// All of the event IDs.
    static let AllEventId = 0

    /// The last event ID since now.
    static let NowEventId = FSEventStreamEventId(kFSEventStreamEventIdSinceNow)

    /// The ID of the event.
    public var id: FSEventStreamEventId

    /// The path for the event.
    public var path: Path

    /// The flags of the event.
    public var flags: FileSystemEventFlags
}

// MARK: - Path extension

extension Path {
    /// Watches a path for filesystem events and handles them in the callback.
    public func watch(latency: NSTimeInterval = 0, queue: dispatch_queue_t = dispatch_get_main_queue(), callback: (FileSystemEvent) -> Void) -> FileSystemWatcher {
        let watcher = FileSystemWatcher(paths: [self], latency: latency, queue: queue, callback: callback)
        watcher.watch()
        return watcher
    }
}

/*
extension SequenceType where Self.Generator.Element: Path {

    public func watch(latency: NSTimeInterval = 0, queue: dispatch_queue_t = dispatch_get_main_queue(), callback: (FileSystemEvent)->Void) -> FileSystemWatcher {
        let watcher = FileSystemWatcher(pathsToWatch: self.map{ $0.rawValue }, latency: latency, queue: queue, callback: callback)
        watcher.watch()
        return watcher
    }
}
*/


/// A set of fileystem event flags.
public struct FileSystemEventFlags : OptionSetType, CustomStringConvertible, CustomDebugStringConvertible {

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

    /// The raw event stream flag values.
    public let rawValue: Int

    /// Creates a set of event stream flags from a raw value.
    public init(rawValue: Int) { self.rawValue = rawValue }

    /// Flag for if the item is a hardlink.
    @available(iOS 9, OSX 10.10, *)
    public static let ItemIsHardlink = FileSystemEventFlags(rawValue: kFSEventStreamEventFlagItemIsHardlink)

    /// Flag for if the item was the last hardlink.
    @available(iOS 9, OSX 10.10, *)
    public static let ItemIsLastHardlink = FileSystemEventFlags(rawValue: kFSEventStreamEventFlagItemIsLastHardlink)

    /// An array of all of the flags.
    public static var AllArray: [FileSystemEventFlags] = {
        var array: [FileSystemEventFlags] = [
            .None,              .MustScanSubDirs,       .UserDropped,
            .KernelDropped,     .EventIdsWrapped,       .HistoryDone,
            .RootChanged,       .Mount,                 .Unmount,
            .ItemRemoved,       .ItemInodeMetaMod,      .ItemRenamed,
            .ItemModified,      .ItemFinderInfoMod,     .ItemChangeOwner,
            .ItemXattrMod,      .ItemIsFile,            .ItemIsDir,
            .ItemIsSymlink,     .OwnEvent
        ]
        if #available(iOS 9, OSX 10.10, *) {
            array += [.ItemIsHardlink, .ItemIsLastHardlink ]
        }
        return array
    }()

    /// The names of all of the flags.
    public static let AllNames: [String] = {
        var array: [String] = [
            "None",             "MustScanSubDirs",      "UserDropped",
            "KernelDropped",    "EventIdsWrapped",      "HistoryDone",
            "RootChanged",      "Mount",                "Unmount",
            "ItemRemoved",      "ItemInodeMetaMod",     "ItemRenamed",
            "ItemModified",     "ItemFinderInfoMod",    "ItemChangeOwner",
            "ItemXattrMod",     "ItemIsFile",           "ItemIsDir",
            "ItemIsSymlink",    "OwnEvent",
        ]
        if #available(iOS 9, OSX 10.10, *) {
            array += ["ItemIsHardlink", "ItemIsLastHardlink"]
        }
        return array
    }()

    /// A textual representation of `self`.
    public var description: String {
        var result = ""
        for (index, element) in FileSystemEventFlags.AllArray.enumerate() {
            if self.contains(element){
                let name = FileSystemEventFlags.AllNames[index]
                result += result.isEmpty ? "\(name)" : ",\(name)"
            }
        }
        return "[\(result)]"
    }

    /// A textual representation of `self`, suitable for debugging.
    public var debugDescription: String {
        var result = ""
        for (index, element) in FileSystemEventFlags.AllArray.enumerate() {
            if self.contains(element){
                let name = FileSystemEventFlags.AllNames[index] + "(\(element.rawValue))"
                result += result.isEmpty ? "\(name)" : ",\(name)"
            }
        }
        return "[\(result)]"
    }
    
}


/// Flags for creating an event stream.
public struct FileSystemEventStreamCreateFlags : OptionSetType, CustomStringConvertible, CustomDebugStringConvertible {

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

    /// The raw event stream creation flags.
    public let rawValue: Int

    /// Creates a set of event stream creation flags from a raw value.
    public init(rawValue: Int) { self.rawValue = rawValue }

    /// All of the event stream creation flags.
    public static let AllArray: [FileSystemEventStreamCreateFlags] = [.None, .UseCFTypes, .FlagNoDefer, .WatchRoot, .IgnoreSelf, .FileEvents, .MarkSelf]

    /// All of the names of the event stream creation flags.
    public static let AllNames: [String] = ["None", "UseCFTypes", "FlagNoDefer", "WatchRoot", "IgnoreSelf", "FileEvents", "MarkSelf" ]

    /// A textual representation of `self`.
    public var description : String {
        var result = ""
        for (index, element) in FileSystemEventStreamCreateFlags.AllArray.enumerate() {
            if self.contains(element){
                let name = FileSystemEventStreamCreateFlags.AllNames[index]
                result += result.isEmpty ? "\(name)" : ",\(name)"
            }
        }
        return "[\(result)]"
    }

    /// A textual representation of `self`, suitable for debugging.
    public var debugDescription : String {
        var result = ""
        for (index, element) in FileSystemEventStreamCreateFlags.AllArray.enumerate() {
            if self.contains(element){
                let name = FileSystemEventStreamCreateFlags.AllNames[index] + "(\(element.rawValue))"
                result += result.isEmpty ? "\(name)" : ",\(name)"
            }
        }
        return "[\(result)]"
    }

}


/// A filesystem event stream.
struct FileSystemEventStream {

    /// The raw FSEventStreamRef value of `self`.
    var rawValue: FSEventStreamRef

    /// Schedules the stream on the specified run loop.
    func scheduleWithRunLoop(runLoop: CFRunLoopRef, runLoopMode: CFStringRef) {
        FSEventStreamScheduleWithRunLoop(rawValue, runLoop, runLoopMode)
    }

    /// Invalidates the stream.
    func invalidate() {
        FSEventStreamInvalidate(rawValue)
    }

    /// Registers the stream.
    func start() {
        FSEventStreamStart(rawValue)
    }

    /// Unregisters the stream.
    func stop() {
        FSEventStreamStop(rawValue)
    }

    /// Removes the stream from the specified run loop.
    func unscheduleFromRunLoop(runLoop: CFRunLoopRef, runLoopMode: CFStringRef) {
        FSEventStreamUnscheduleFromRunLoop(rawValue, runLoop, runLoopMode)
    }

    /// Schedules the stream on the specified dispatch queue
    func setDispatchQueue(queue: dispatch_queue_t) {
        FSEventStreamSetDispatchQueue(rawValue, queue)
    }

    /// Decrements the FSEventStreamRef's refcount.
    func release() {
        FSEventStreamRelease(rawValue)
    }

    /// Asks the FS Events service to flush out any events that have occurred
    /// but have not yet been delivered, due to the latency parameter that was
    /// supplied when the stream was created. This flushing occurs
    /// asynchronously.
    func flushAsync() {
        FSEventStreamFlushAsync(rawValue)
    }

    /// Asks the FS Events service to flush out any events that have occurred
    /// but have not yet been delivered, due to the latency parameter that was
    /// supplied when the stream was created. This flushing occurs
    /// synchronously.
    func flushSync() {
        FSEventStreamFlushSync(rawValue)
    }

    /// Prints a description of the stream to stderr.
    func show() {
        FSEventStreamShow(rawValue)
    }

    /// The dev_t for a device-relative stream, otherwise 0.
    func deviceBeingWatched() -> dev_t {
        return FSEventStreamGetDeviceBeingWatched(rawValue)
    }

    /// The sinceWhen attribute of the stream.
    var lastEventId: FSEventStreamEventId {
        return FSEventStreamGetLatestEventId(rawValue)
    }
}


/// Watches a given set of paths and runs a callback per event.
public class FileSystemWatcher {
    
    // MARK: - Initialization

    /// Creates a watcher for the given paths.
    public init(paths: [Path], sinceWhen: FSEventStreamEventId = FileSystemEvent.NowEventId, flags: FileSystemEventStreamCreateFlags = [.UseCFTypes, .FileEvents], latency: CFTimeInterval = 0, queue: dispatch_queue_t? = nil, callback: (FileSystemEvent) -> Void) {
        self.lastEventId = sinceWhen
        self.paths       = paths
        self.flags       = flags
        self.latency     = latency
        self.queue       = queue
        self.callback    = callback
    }

    // MARK: - Deinitialization
    
    deinit {
        self.close()
    }
    
    // MARK: - Properties

    /// The paths being watched.
    public let paths: [Path]

    /// How often the watcher updates.
    public let latency: CFTimeInterval

    /// The queue for the watcher.
    public let queue: dispatch_queue_t?

    /// The flags used to create the watcher.
    public let flags: FileSystemEventStreamCreateFlags

    /// The run loop mode for the watcher.
    public var runLoopMode: CFStringRef = kCFRunLoopDefaultMode

    /// The run loop for the watcher.
    public var runLoop: CFRunLoop = CFRunLoopGetMain()

    /// The callback for filesystem events.
    private let callback: (FileSystemEvent) -> Void

    /// The last event ID for the watcher.
    public private(set) var lastEventId: FSEventStreamEventId

    /// Whether or not the watcher has started yet.
    private var started = false

    /// The event stream for the watcher.
    private var stream: FileSystemEventStream?
    
    // MARK: - Private Methods

    /// Processes the event by logging it and then running the callback.
    private func processEvent(event: FileSystemEvent) {
        FileSystemWatcher.log("\t\(event.id) - \(event.flags) - \(event.path)")
        self.callback(event)
    }

    /// Prints the message when in debug mode.
    private static func log(message: String) {
        #if DEBUG
            print(message)
        #endif
    }

    /// The event stream callback for when events occur.
    private static let eventCallback: FSEventStreamCallback = {(
        stream: ConstFSEventStreamRef,
        contextInfo: UnsafeMutablePointer<Void>,
        numEvents: Int,
        eventPaths: UnsafeMutablePointer<Void>,
        eventFlags: UnsafePointer<FSEventStreamEventFlags>,
        eventIds: UnsafePointer<FSEventStreamEventId>) in
        
        FileSystemWatcher.log("Callback Fired")
        
        let fileSystemWatcher: FileSystemWatcher = unsafeBitCast(contextInfo, FileSystemWatcher.self)
        let paths = unsafeBitCast(eventPaths, NSArray.self) as! [String]
        for index in 0..<numEvents {
            let id = eventIds[index]
            let path = paths[index]
            let flags = eventFlags[index]
            
            let event = FileSystemEvent(id: id, path: Path(path), flags: FileSystemEventFlags(rawValue: Int(flags)))
            fileSystemWatcher.processEvent(event)
        }
        
        fileSystemWatcher.lastEventId = eventIds[numEvents - 1]
    }
    
    // MARK: - Public Methods
    
    // Start watching by creating the stream
    /// Starts watching.
    public func watch() {
        guard started == false else { return }
        
        var context = FSEventStreamContext(
            version: 0,
            info: nil,
            retain: nil,
            release: nil,
            copyDescription: nil
        )
        // add self into context
        context.info = UnsafeMutablePointer<Void>(unsafeAddressOf(self))
        
        let streamRef = FSEventStreamCreate(
            kCFAllocatorDefault,
            FileSystemWatcher.eventCallback,
            &context,
            paths.map{$0.rawValue},
            // since when
            lastEventId,
            // how long to wait after an event occurs before forwarding it
            latency,
            UInt32(flags.rawValue)
        )
        stream = FileSystemEventStream(rawValue: streamRef)
        
        stream?.scheduleWithRunLoop(runLoop, runLoopMode: runLoopMode)
        if let q = queue {
            stream?.setDispatchQueue(q)
        }
        stream?.start()
        
        started = true
    }
    
    // Stops, invalidates and releases the stream
    /// Closes the watcher.
    public func close() {
        guard started == true else { return }
        
        stream?.stop()
        stream?.invalidate()
        stream?.release()
        stream = nil
        
        started = false
    }
    
    /// Requests that the fseventsd daemon send any events it has already
    /// buffered (via the latency parameter).
    ///
    /// This occurs asynchronously; clients will not have received all the
    /// callbacks by the time this call returns to them.
    public func flushAsync() {
        stream?.flushAsync()
    }
    
    /// Requests that the fseventsd daemon send any events it has already
    /// buffered (via the latency). Then runs the runloop in its private mode
    /// till all events that have occurred have been reported (via the client's
    /// callback).
    ///
    /// This occurs synchronously; clients will have received all the callbacks
    /// by the time this call returns to them.
    public func flushSync() {
        stream?.flushSync()
    }
    
}

#endif
