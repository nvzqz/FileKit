//
//  FileSystemEvent.swift
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

#if os(OSX)

/// Watches a given set of paths and runs a callback per event.
public class FileSystemWatcher {

    // MARK: - Private Static Properties

    /// The event stream callback for when events occur.
    private static let _eventCallback: FSEventStreamCallback = {
        (stream: ConstFSEventStreamRef,
        contextInfo: UnsafeMutableRawPointer?,
        numEvents: Int,
        eventPaths: UnsafeMutableRawPointer,
        eventFlags: UnsafePointer<FSEventStreamEventFlags>?,
        eventIds: UnsafePointer<FSEventStreamEventId>?) in

        defer {
            if let lastEventId = eventIds?[numEvents - 1] {
                watcher.lastEventId = lastEventId
            }
        }

        FileSystemWatcher.log("Callback Fired")

        let watcher: FileSystemWatcher = unsafeBitCast(contextInfo, to: FileSystemWatcher.self)
        guard let paths = unsafeBitCast(eventPaths, to: NSArray.self) as? [String], let eventFlags = eventFlags, let eventIds = eventIds else {
            return
        }

        for index in 0..<numEvents {
            let id = eventIds[index]
            let path = paths[index]
            let flags = eventFlags[index]

            let event = FileSystemEvent(
                id: id,
                path: Path(path),
                flags: FileSystemEventFlags(rawValue: Int(flags)))
            watcher._processEvent(event)
        }
    }

    // MARK: - Properties

    /// The paths being watched.
    public let paths: [Path]

    /// How often the watcher updates.
    public let latency: CFTimeInterval

    /// The queue for the watcher.
    public let queue: DispatchQueue?

    /// The flags used to create the watcher.
    public let flags: FileSystemEventStreamCreateFlags

    /// The run loop mode for the watcher.
    public var runLoopMode: CFRunLoopMode = CFRunLoopMode.defaultMode

    /// The run loop for the watcher.
    public var runLoop: CFRunLoop = CFRunLoopGetMain()

    /// The callback for filesystem events.
    private let _callback: (FileSystemEvent) -> Void

    /// The last event ID for the watcher.
    public private(set) var lastEventId: FSEventStreamEventId

    /// Whether or not the watcher has started yet.
    private var _started = false

    /// The event stream for the watcher.
    private var _stream: FileSystemEventStream?

    // MARK: - Initialization

    /// Creates a watcher for the given paths.
    ///
    /// - Parameter paths: The paths.
    /// - Parameter sinceWhen: The date to start at.
    /// - Parameter flags: The create flags.
    /// - Parameter latency: The latency.
    /// - Parameter queue: The queue to be run within.
    /// - Parameter callback: The callback to be called on changes.
    public init(paths: [Path],
                sinceWhen: FSEventStreamEventId = FileSystemEvent.NowEventId,
                flags: FileSystemEventStreamCreateFlags = [.UseCFTypes, .FileEvents],
                latency: CFTimeInterval = 0,
                queue: DispatchQueue? = nil,
                callback: @escaping (FileSystemEvent) -> Void
        ) {
        self.lastEventId = sinceWhen
        self.paths       = paths
        self.flags       = flags
        self.latency     = latency
        self.queue       = queue
        self._callback   = callback
    }

    // MARK: - Deinitialization

    deinit {
        self.close()
    }

    // MARK: - Private Methods

    /// Processes the event by logging it and then running the callback.
    ///
    /// - Parameter event: The file system event to be logged.
    private func _processEvent(_ event: FileSystemEvent) {
        FileSystemWatcher.log("\t\(event.id) - \(event.flags) - \(event.path)")
        self._callback(event)
    }

    /// Prints the message when in debug mode.
    ///
    /// - Parameter message: The message to be logged.
    private static func log(_ message: String) {
        #if DEBUG
            print(message)
        #endif
    }

    // MARK: - Methods

    // Start watching by creating the stream
    /// Starts watching.
    public func watch() {
        guard _started == false else { return }

        var context = FSEventStreamContext(
            version: 0,
            info: nil,
            retain: nil,
            release: nil,
            copyDescription: nil
        )
        // add self into context
        context.info = Unmanaged.passUnretained(self).toOpaque()

        guard let streamRef = FSEventStreamCreate(
            kCFAllocatorDefault,
            FileSystemWatcher._eventCallback,
            &context,
            paths.map {$0.rawValue} as CFArray,
            // since when
            lastEventId,
            // how long to wait after an event occurs before forwarding it
            latency,
            UInt32(flags.rawValue)
            ) else {
                return
        }
        _stream = FileSystemEventStream(rawValue: streamRef)

        _stream?.scheduleWithRunLoop(runLoop, runLoopMode: runLoopMode)
        if let q = queue {
            _stream?.setDispatchQueue(q)
        }
        _stream?.start()

        _started = true
    }

    // Stops, invalidates and releases the stream
    /// Closes the watcher.
    public func close() {
        guard _started == true else { return }

        _stream?.stop()
        _stream?.invalidate()
        _stream?.release()
        _stream = nil

        _started = false
    }

    /// Requests that the fseventsd daemon send any events it has already
    /// buffered (via the latency parameter).
    ///
    /// This occurs asynchronously; clients will not have received all the
    /// callbacks by the time this call returns to them.
    public func flushAsync() {
        _stream?.flushAsync()
    }

    /// Requests that the fseventsd daemon send any events it has already
    /// buffered (via the latency). Then runs the runloop in its private mode
    /// till all events that have occurred have been reported (via the client's
    /// callback).
    ///
    /// This occurs synchronously; clients will have received all the callbacks
    /// by the time this call returns to them.
    public func flushSync() {
        _stream?.flushSync()
    }

}

#endif
