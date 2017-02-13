//
//  GCDFSWatcher.swift
//  FileKit
//
//  Created by ijump on 5/2/16.
//  Copyright © 2017 Nikolai Vazquez. All rights reserved.
//

import Foundation

/// Delegate for `DispatchFileSystemWatcher`
public protocol DispatchFileSystemWatcherDelegate: class {

    // MARK: - Protocol

    /// Call when the file-system object was deleted from the namespace.
    func fsWatcherDidObserveDelete(_ watch: DispatchFileSystemWatcher)

    /// Call when the file-system object data changed.
    func fsWatcherDidObserveWrite(_ watch: DispatchFileSystemWatcher)

    /// Call when the file-system object changed in size.
    func fsWatcherDidObserveExtend(_ watch: DispatchFileSystemWatcher)

    /// Call when the file-system object metadata changed.
    func fsWatcherDidObserveAttrib(_ watch: DispatchFileSystemWatcher)

    /// Call when the file-system object link count changed.
    func fsWatcherDidObserveLink(_ watch: DispatchFileSystemWatcher)

    /// Call when the file-system object was renamed in the namespace.
    func fsWatcherDidObserveRename(_ watch: DispatchFileSystemWatcher)

    /// Call when the file-system object was revoked.
    func fsWatcherDidObserveRevoke(_ watch: DispatchFileSystemWatcher)

    /// Call when the file-system object was created.
    func fsWatcherDidObserveCreate(_ watch: DispatchFileSystemWatcher)

    /// Call when the directory changed (additions, deletions, and renamings).
    ///
    /// Calls `fsWatcherDidObserveWrite` by default.
    func fsWatcherDidObserveDirectoryChange(_ watch: DispatchFileSystemWatcher)
}

// Optional func and default func for `GCDFSWatcherDelegate`
// Empty func treated as Optional func
public extension DispatchFileSystemWatcherDelegate {

    // MARK: - Extension

    /// Call when the file-system object was deleted from the namespace.
    public func fsWatcherDidObserveDelete(_ watch: DispatchFileSystemWatcher) {

    }

    /// Call when the file-system object data changed.
    public func fsWatcherDidObserveWrite(_ watch: DispatchFileSystemWatcher) {

    }

    /// Call when the file-system object changed in size.
    public func fsWatcherDidObserveExtend(_ watch: DispatchFileSystemWatcher) {

    }

    /// Call when the file-system object metadata changed.
    public func fsWatcherDidObserveAttrib(_ watch: DispatchFileSystemWatcher) {

    }

    /// Call when the file-system object link count changed.
    public func fsWatcherDidObserveLink(_ watch: DispatchFileSystemWatcher) {

    }

    /// Call when the file-system object was renamed in the namespace.
    public func fsWatcherDidObserveRename(_ watch: DispatchFileSystemWatcher) {

    }

    /// Call when the file-system object was revoked.
    public func fsWatcherDidObserveRevoke(_ watch: DispatchFileSystemWatcher) {

    }

    /// Call when the file-system object was created.
    public func fsWatcherDidObserveCreate(_ watch: DispatchFileSystemWatcher) {

    }

    /// Call when the directory changed (additions, deletions, and renamings).
    ///
    /// Calls `fsWatcherDidObserveWrite` by default.
    public func fsWatcherDidObserveDirectoryChange(_ watch: DispatchFileSystemWatcher) {
        fsWatcherDidObserveWrite(watch)
    }
}

/// Watcher for Vnode events
open class DispatchFileSystemWatcher {

    // MARK: - Properties

    /// The paths being watched.
    open let path: Path

    /// The events used to create the watcher.
    open let events: DispatchFileSystemEvents

    /// The delegate to call when events happen
    weak var delegate: DispatchFileSystemWatcherDelegate?

    /// The watcher for watching creation event
    weak var createWatcher: DispatchFileSystemWatcher?

    /// The callback for file system events.
    fileprivate let callback: ((DispatchFileSystemWatcher) -> Void)?

    /// The queue for the watcher.
    fileprivate let queue: DispatchQueue?

    /// A file descriptor for the path.
    fileprivate var fileDescriptor: CInt = -1

    /// A dispatch source to monitor a file descriptor created from the path.
    fileprivate var source: DispatchSourceProtocol?

    /// Current events
    open var currentEvent: DispatchFileSystemEvents? {
        if let source = source {
            return DispatchFileSystemEvents(rawValue: source.data)
        }
        if createWatcher != nil {
            return .Create
        }
        return nil
    }

    // MARK: - Initialization

    /// Creates a watcher for the given paths.
    ///
    /// - Parameter paths: The paths.
    /// - Parameter events: The create events.
    /// - Parameter queue: The queue to be run within.
    /// - Parameter callback: The callback to be called on changes.
    ///
    /// This method does follow links.
    init(path: Path,
         events: DispatchFileSystemEvents,
         queue: DispatchQueue,
         callback: ((DispatchFileSystemWatcher) -> Void)?
        ) {
        self.path = path.absolute
        self.events = events
        self.queue = queue
        self.callback = callback
    }

    // MARK: - Deinitialization

    deinit {
        //print("\(path): Deinit")
        close()
    }

    // MARK: - Private Methods

    /// Dispatch the event.
    ///
    /// If `callback` is set, call the `callback`. Else if `delegate` is set, call the `delegate`
    ///
    /// - Parameter eventType: The current event to be watched.
    fileprivate func dispatchDelegate(_ eventType: DispatchFileSystemEvents) {
        if let callback = self.callback {
            callback(self)
        } else if let delegate = self.delegate {
            if eventType.contains(.Delete) {
                delegate.fsWatcherDidObserveDelete(self)
            }
            if eventType.contains(.Write) {
                if path.isDirectoryFile {
                    delegate.fsWatcherDidObserveDirectoryChange(self)
                } else {
                    delegate.fsWatcherDidObserveWrite(self)
                }
            }
            if eventType.contains(.Extend) {
                delegate.fsWatcherDidObserveExtend(self)
            }
            if eventType.contains(.Attribute) {
                delegate.fsWatcherDidObserveAttrib(self)
            }
            if eventType.contains(.Link) {
                delegate.fsWatcherDidObserveLink(self)
            }
            if eventType.contains(.Rename) {
                delegate.fsWatcherDidObserveRename(self)
            }
            if eventType.contains(.Revoke) {
                delegate.fsWatcherDidObserveRevoke(self)
            }
            if eventType.contains(.Create) {
                delegate.fsWatcherDidObserveCreate(self)
            }
        }

    }

    // MARK: - Methods

    /// Start watching.
    ///
    /// This method does follow links.
    @discardableResult
    open func startWatching() -> Bool {

        // create a watcher for CREATE event if path not exists and events contains CREATE
        if !path.exists {
            if events.contains(.Create) {
                let parent = path.parent.absolute
                var _events = events
                _events.remove(.Create)
                // only watch a CREATE event if parent exists and is a directory
                if parent.isDirectoryFile {
                    #if os(OSX)
                        let watch = { parent.watch2($0, callback: $1) }
                    #else
                        let watch = { parent.watch($0, callback: $1) }
                    #endif
                    createWatcher = watch(.Write) { [weak self] watch in
                        // stop watching when path created
                        if self?.path.isRegular == true || self?.path.isDirectoryFile == true {
                            self?.dispatchDelegate(.Create)
                            //self.delegate?.fsWatcherDidObserveCreate(self)
                            self?.createWatcher = nil
                            self?.startWatching()
                            watch.stopWatching()
                        }
                    }
                    return true
                }
            }
            return false
        }

            // Only watching for regular file and directory
        else if path.isRegular || path.isDirectoryFile {

            if source == nil && fileDescriptor == -1 {
                fileDescriptor = open(path._safeRawValue, O_EVTONLY)
                if fileDescriptor == -1 { return false }
                var _events = events
                _events.remove(.Create)
                source = DispatchSource.makeFileSystemObjectSource(fileDescriptor: fileDescriptor, eventMask: DispatchSource.FileSystemEvent(rawValue: _events.rawValue), queue: queue)

                // Recheck if open success and source create success
                if source != nil && fileDescriptor != -1 {
                    guard callback != nil || delegate != nil else {
                        return false
                    }

                    // Define the block to call when a file change is detected.
                    source!.setEventHandler { //[unowned self] () in
                        let eventType = DispatchFileSystemEvents(rawValue: self.source!.data)
                        self.dispatchDelegate(eventType)
                    }

                    // Define a cancel handler to ensure the path is closed when the source is cancelled.
                    source!.setCancelHandler { //[unowned self] () in
                        _ = Darwin.close(self.fileDescriptor)
                        self.fileDescriptor = -1
                        self.source = nil
                    }

                    // Start monitoring the path via the source.
                    source!.resume()
                    return true
                }
            }
            return false
        } else {
            return false
        }

    }

    /// Stop watching.
    ///
    /// **Note:** make sure call this func, or `self` will not release
    open func stopWatching() {
        if source != nil {
            source!.cancel()
        }
    }

    /// Closes the watcher.
    open func close() {
        createWatcher?.stopWatching()
        _ = Darwin.close(self.fileDescriptor)
        self.fileDescriptor = -1
        self.source = nil
    }

}

extension Path {

    #if os(OSX)
    // MARK: - Watching

    /// Watches a path for filesystem events and handles them in the callback or delegate.
    ///
    /// - Parameter events: The create events.
    /// - Parameter queue: The queue to be run within.
    /// - Parameter delegate: The delegate to call when events happen.
    /// - Parameter callback: The callback to be called on changes.
    public func watch2(_ events: DispatchFileSystemEvents = .All,
                       queue: DispatchQueue? = nil,
                       delegate: DispatchFileSystemWatcherDelegate? = nil,
                       callback: ((DispatchFileSystemWatcher) -> Void)? = nil
        ) -> DispatchFileSystemWatcher {
        let dispathQueue: DispatchQueue
        if #available(OSX 10.10, *) {
            dispathQueue = queue ?? DispatchQueue.global(qos: .default)
        } else {
            dispathQueue = queue ?? DispatchQueue.global(priority: .default)
        }
        let watcher = DispatchFileSystemWatcher(path: self, events: events, queue: dispathQueue, callback: callback)
        watcher.delegate = delegate
        watcher.startWatching()
        return watcher
    }

    #else

    // MARK: - Watching

    /// Watches a path for filesystem events and handles them in the callback or delegate.
    ///
    /// - Parameter events: The create events.
    /// - Parameter queue: The queue to be run within.
    /// - Parameter delegate: The delegate to call when events happen.
    /// - Parameter callback: The callback to be called on changes.
    public func watch(_ events: DispatchFileSystemEvents = .All,
                      queue: DispatchQueue = DispatchQueue.global(qos: .default),
                      delegate: DispatchFileSystemWatcherDelegate? = nil,
                      callback: ((DispatchFileSystemWatcher) -> Void)? = nil
        ) -> DispatchFileSystemWatcher {
        let watcher = DispatchFileSystemWatcher(path: self, events: events, queue: queue, callback: callback)
        watcher.delegate = delegate
        watcher.startWatching()
        return watcher
    }
    #endif
}
