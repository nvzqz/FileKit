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
public struct FileSystemEvent {
    public var id: FSEventStreamEventId
    public var path: Path
    public var flags: FileSystemEventFlags
    
    static let AllEventId = 0
    static let NowEventId = FSEventStreamEventId(kFSEventStreamEventIdSinceNow)
}

// MARK: - Path extension

extension Path {
    public func watch(latency: NSTimeInterval = 0, queue: dispatch_queue_t = dispatch_get_main_queue(), callback: (FileSystemEvent)->Void) -> FileSystemWatcher {
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


// MARK: - FileSystemEventFlags
public struct FileSystemEventFlags: OptionSetType, CustomStringConvertible, CustomDebugStringConvertible {
    
    public let rawValue: Int
    public init(rawValue: Int) { self.rawValue = rawValue }
    
    public static let None = FileSystemEventFlags(rawValue: kFSEventStreamEventFlagNone)
    public static let MustScanSubDirs = FileSystemEventFlags(rawValue: kFSEventStreamEventFlagMustScanSubDirs)
    public static let UserDropped = FileSystemEventFlags(rawValue: kFSEventStreamEventFlagUserDropped)
    public static let KernelDropped = FileSystemEventFlags(rawValue: kFSEventStreamEventFlagKernelDropped)
    public static let EventIdsWrapped = FileSystemEventFlags(rawValue: kFSEventStreamEventFlagEventIdsWrapped)
    public static let HistoryDone = FileSystemEventFlags(rawValue: kFSEventStreamEventFlagHistoryDone)
    public static let RootChanged = FileSystemEventFlags(rawValue: kFSEventStreamEventFlagRootChanged)
    public static let Mount = FileSystemEventFlags(rawValue: kFSEventStreamEventFlagMount)
    public static let Unmount = FileSystemEventFlags(rawValue: kFSEventStreamEventFlagUnmount)
    // @available(iOS 6, *, OSX 10.7)
    public static let Created = FileSystemEventFlags(rawValue: kFSEventStreamEventFlagItemCreated)
    public static let ItemRemoved = FileSystemEventFlags(rawValue: kFSEventStreamEventFlagItemRemoved)
    public static let ItemInodeMetaMod = FileSystemEventFlags(rawValue: kFSEventStreamEventFlagItemInodeMetaMod)
    public static let ItemRenamed = FileSystemEventFlags(rawValue: kFSEventStreamEventFlagItemRenamed)
    public static let ItemModified = FileSystemEventFlags(rawValue: kFSEventStreamEventFlagItemModified)
    public static let ItemFinderInfoMod = FileSystemEventFlags(rawValue: kFSEventStreamEventFlagItemFinderInfoMod)
    public static let ItemChangeOwner = FileSystemEventFlags(rawValue: kFSEventStreamEventFlagItemChangeOwner)
    public static let ItemXattrMod = FileSystemEventFlags(rawValue: kFSEventStreamEventFlagItemXattrMod)
    public static let ItemIsFile = FileSystemEventFlags(rawValue: kFSEventStreamEventFlagItemIsFile)
    public static let ItemIsDir = FileSystemEventFlags(rawValue: kFSEventStreamEventFlagItemIsDir)
    public static let ItemIsSymlink = FileSystemEventFlags(rawValue: kFSEventStreamEventFlagItemIsSymlink)
    // @available(iOS 7, *, OSX 10.9)
    public static let OwnEvent = FileSystemEventFlags(rawValue: kFSEventStreamEventFlagOwnEvent)
    
    @available(iOS 9, OSX 10.10, *)
    public static let ItemIsHardlink = FileSystemEventFlags(rawValue: kFSEventStreamEventFlagItemIsHardlink)
    @available(iOS 9, OSX 10.10, *)
    public static let ItemIsLastHardlink = FileSystemEventFlags(rawValue: kFSEventStreamEventFlagItemIsLastHardlink)
    
    public static var AllArray: [FileSystemEventFlags] = {
        var array: [FileSystemEventFlags] = [.None, .MustScanSubDirs, .UserDropped, .KernelDropped, .EventIdsWrapped, .HistoryDone, .RootChanged, .Mount, .Unmount,
            .ItemRemoved, .ItemInodeMetaMod, .ItemRenamed, .ItemModified, .ItemFinderInfoMod, .ItemChangeOwner, .ItemXattrMod, .ItemIsFile, .ItemIsDir, .ItemIsSymlink, .OwnEvent]
        if #available(iOS 9, OSX 10.10, *) {
            array += [.ItemIsHardlink, .ItemIsLastHardlink ]
        }
        return array
    }()
    
    public static let AllNames: [String] = ["None", "MustScanSubDirs", "UserDropped", "KernelDropped", "EventIdsWrapped", "HistoryDone", "RootChanged", "Mount", "Unmount",
        "ItemRemoved", "ItemInodeMetaMod", "ItemRenamed", "ItemModified", "ItemFinderInfoMod", "ItemChangeOwner", "ItemXattrMod", "ItemIsFile", "ItemIsDir", "ItemIsSymlink", "OwnEvent",
        "ItemIsHardlink", "ItemIsLastHardlink"
    ]
    
    public var description : String {
        var result = ""
        for (index, element) in FileSystemEventFlags.AllArray.enumerate() {
            if self.contains(element){
                let name = FileSystemEventFlags.AllNames[index]
                result += result.isEmpty ? "\(name)" : ",\(name)"
            }
        }
        return "[\(result)]"
    }
    
    public var debugDescription : String{
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

// MARK: - FileSystemEventFlags
public struct FileSystemEventStreamCreateFlags: OptionSetType, CustomStringConvertible, CustomDebugStringConvertible {
    
    public let rawValue: Int
    public init(rawValue: Int) { self.rawValue = rawValue }
    
    public static let None = FileSystemEventStreamCreateFlags(rawValue: kFSEventStreamCreateFlagNone)
    public static let UseCFTypes = FileSystemEventStreamCreateFlags(rawValue: kFSEventStreamCreateFlagUseCFTypes)
    public static let FlagNoDefer = FileSystemEventStreamCreateFlags(rawValue: kFSEventStreamCreateFlagNoDefer)
    public static let WatchRoot = FileSystemEventStreamCreateFlags(rawValue: kFSEventStreamCreateFlagWatchRoot)
    public static let IgnoreSelf = FileSystemEventStreamCreateFlags(rawValue: kFSEventStreamCreateFlagIgnoreSelf)
    public static let FileEvents = FileSystemEventStreamCreateFlags(rawValue: kFSEventStreamCreateFlagFileEvents)
    public static let MarkSelf = FileSystemEventStreamCreateFlags(rawValue: kFSEventStreamCreateFlagMarkSelf)
    
    public static var AllArray: [FileSystemEventStreamCreateFlags] = [.None, .UseCFTypes, .FlagNoDefer, .WatchRoot, .IgnoreSelf, .FileEvents, .MarkSelf]
    public static let AllNames: [String] = ["None", "UseCFTypes", "FlagNoDefer", "WatchRoot", "IgnoreSelf", "FileEvents", "MarkSelf" ]
    
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
    
    public var debugDescription : String{
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

// MARK: - FileSystemEventStream - Wrapper for FSEventStream operation
struct FileSystemEventStream {
    
    var rawValue: FSEventStreamRef
    
    func scheduleWithRunLoop(runLoop: CFRunLoopRef, runLoopMode: CFStringRef) {
        FSEventStreamScheduleWithRunLoop(rawValue, runLoop, runLoopMode)
    }
    func invalidate() {
        FSEventStreamInvalidate(rawValue)
    }
    func start() {
        FSEventStreamStart(rawValue)
    }
    func stop() {
        FSEventStreamStop(rawValue)
    }
    func unscheduleFromRunLoop(runLoop: CFRunLoopRef, runLoopMode: CFStringRef) {
        FSEventStreamUnscheduleFromRunLoop(rawValue, runLoop, runLoopMode)
    }
    func setDispatchQueue(queue: dispatch_queue_t) {
        FSEventStreamSetDispatchQueue(rawValue, queue)
    }
    func release() {
        FSEventStreamRelease(rawValue)
    }
    func flushAsync() {
        FSEventStreamFlushAsync(rawValue)
    }
    func flushSync() {
        FSEventStreamFlushSync(rawValue)
    }
    func show() {
        FSEventStreamShow(rawValue)
    }
    func deviceBeingWatched() -> dev_t {
        return FSEventStreamGetDeviceBeingWatched(rawValue)
    }
    var lastEventId: FSEventStreamEventId {
        return FSEventStreamGetLatestEventId(rawValue)
    }
}

// MARK: - FileSystemWatcher
public class FileSystemWatcher {
    
    // MARK: - Initialization / Deinitialization
    
    public init(paths: [Path], sinceWhen: FSEventStreamEventId = FileSystemEvent.NowEventId,
        flags: FileSystemEventStreamCreateFlags = [.UseCFTypes,.FileEvents],
        latency: CFTimeInterval = 0, queue: dispatch_queue_t? = nil, callback: (FileSystemEvent) -> Void) {
            self.lastEventId = sinceWhen
            self.paths = paths
            self.flags = flags
            self.latency = latency
            self.queue = queue
            self.callback = callback
    }
    
    deinit {
        self.close()
    }
    
    // MARK: - Properties
    
    public let paths: [Path]
    public let latency: CFTimeInterval
    public let queue: dispatch_queue_t?
    public let flags: FileSystemEventStreamCreateFlags
    public var runLoopMode: CFStringRef = kCFRunLoopDefaultMode
    public var runLoop: CFRunLoop = CFRunLoopGetMain()
    private let callback: (FileSystemEvent) -> Void
    
    public private(set) var lastEventId: FSEventStreamEventId

    private var started = false
    private var stream: FileSystemEventStream?
    
    // MARK: - Private Methods
    
    private func processEvent(event: FileSystemEvent) {
        FileSystemWatcher.log("\t\(event.id) - \(event.flags) - \(event.path)")
        self.callback(event)
    }
    
    static func log(message: String) {
        #if DEBUG
            print(message)
        #endif
    }
    
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
            lastEventId,// since when
            latency,// how long to wait after an event occurs before forwarding it
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
    public func close() {
        guard started == true else { return }
        
        stream?.stop()
        stream?.invalidate()
        stream?.release()
        stream = nil
        
        started = false
    }
    
    // Requests that the fseventsd daemon send any events it has already buffered (via the latency parameter).
    // This occurs asynchronously; clients will not have received all the callbacks by the time this call returns to them.
    public func flushAsync() {
        stream?.flushAsync()
    }
    
    // Requests that the fseventsd daemon send any events it has already buffered (via the latency)
    // Then runs the runloop in its private mode till all events that have occurred have been reported (via the clients callback).
    // This occurs synchronously; clients will have received all the callbacks by the time this call returns to them.
    public func flushSync() {
        stream?.flushSync()
    }
    
}

#endif
