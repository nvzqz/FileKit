//
//  GCDFSWatcher.swift
//  FileKit
//
//  Created by ijump on 5/2/16.
//  Copyright © 2016 Nikolai Vazquez. All rights reserved.
//

import Foundation



/// Delegate for `GCDVNodeWatcher`
public protocol GCDFSWatcherDelegate: class {
    
    // MARK: - Protocol
    
    /// Call when the file-system object was deleted from the namespace.
    func fsWatcherDidObserveDelete(watch: GCDVNodeWatcher)
    
    /// Call when the file-system object data changed.
    func fsWatcherDidObserveWrite(watch: GCDVNodeWatcher)
    
    /// Call when the file-system object changed in size.
    func fsWatcherDidObserveExtend(watch: GCDVNodeWatcher)
    
    /// Call when the file-system object metadata changed.
    func fsWatcherDidObserveAttrib(watch: GCDVNodeWatcher)
    
    /// Call when the file-system object link count changed.
    func fsWatcherDidObserveLink(watch: GCDVNodeWatcher)
    
    /// Call when the file-system object was renamed in the namespace.
    func fsWatcherDidObserveRename(watch: GCDVNodeWatcher)
    
    /// Call when the file-system object was revoked.
    func fsWatcherDidObserveRevoke(watch: GCDVNodeWatcher)
    
    /// Call when the file-system object was created.
    func fsWatcherDidObserveCreate(watch: GCDVNodeWatcher)
    
    /// Call when the directory changed(additions, deletions, and renamings).
    /// 
    /// call `fsWatcherDidObserveWrite` by default
    func fsWatcherDidObserveDirectoryChange(watch: GCDVNodeWatcher)
}

// Optional func and default func for `GCDFSWatcherDelegate`
// Empty func treated as Optional func
public extension GCDFSWatcherDelegate {
    
    // MARK: - Extension
    
    func fsWatcherDidObserveDelete(watch: GCDVNodeWatcher) {
        
    }
    
    func fsWatcherDidObserveWrite(watch: GCDVNodeWatcher) {
        
    }
    
    func fsWatcherDidObserveExtend(watch: GCDVNodeWatcher) {
        
    }
    
    func fsWatcherDidObserveAttrib(watch: GCDVNodeWatcher) {
        
    }
    
    func fsWatcherDidObserveLink(watch: GCDVNodeWatcher) {
        
    }
    
    func fsWatcherDidObserveRename(watch: GCDVNodeWatcher) {
        
    }
    
    func fsWatcherDidObserveRevoke(watch: GCDVNodeWatcher) {
        
    }
    
    func fsWatcherDidObserveCreate(watch: GCDVNodeWatcher) {
        
    }
    
    func fsWatcherDidObserveDirectoryChange(watch: GCDVNodeWatcher) {
        fsWatcherDidObserveWrite(watch)
    }
}

/// Watcher for VNODE events
public class GCDVNodeWatcher {
    
    // MARK: - Properties
    
    /// The paths being watched.
    public let path: Path
    
    /// The events used to create the watcher.
    public let events: GCDVNodeEvents
    
    /// The delegate to call when events happen
    weak var delegate: GCDFSWatcherDelegate?
    
    /// The watcher for watching creation event
    weak var createWatcher: GCDVNodeWatcher?
    
    /// The callback for vnode events.
    private let callback: ((GCDVNodeWatcher) -> Void)?
    
    /// The queue for the watcher.
    private let queue: dispatch_queue_t?
    
    /// A file descriptor for the path.
    private var fileDescriptor: CInt = -1
    
    /// A dispatch source to monitor a file descriptor created from the path.
    private var source: dispatch_source_t?
    
    /// Current events
    public var currentEvent: GCDVNodeEvents? {
        if let source = source {
            return GCDVNodeEvents(rawValue: dispatch_source_get_data(source))
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
        events: GCDVNodeEvents,
        queue: dispatch_queue_t,
        callback: ((GCDVNodeWatcher) -> Void)?
        ) {
        self.path = path.absolute
        self.events = events
        self.queue = queue
        self.callback = callback
    }
    
    // MARK: - Deinitialization
    
    deinit {
        //print("\(path): Deinit")
        createWatcher?.stopWatching()
        close(self.fileDescriptor)
        self.fileDescriptor = -1
        self.source = nil
    }
    
    // MARK: - Private Methods
    
    /// Dispatch the event.
    ///
    /// If `callback` is set, call the `callback`. Else if `delegate` is set, call the `delegate`
    ///
    /// - Parameter eventType: The current event to be watched.
    private func dispatchDelegate(eventType: GCDVNodeEvents) {
        if let callback = self.callback {
            callback(self)
        } else if let delegate = self.delegate {
            if eventType.contains(.DELETE) {
                delegate.fsWatcherDidObserveDelete(self)
            }
            if eventType.contains(.WRITE) {
                if path.isDirectoryFile {
                    delegate.fsWatcherDidObserveDirectoryChange(self)
                } else {
                    delegate.fsWatcherDidObserveWrite(self)
                }
            }
            if eventType.contains(.EXTEND) {
                delegate.fsWatcherDidObserveExtend(self)
            }
            if eventType.contains(.ATTRIB) {
                delegate.fsWatcherDidObserveAttrib(self)
            }
            if eventType.contains(.LINK) {
                delegate.fsWatcherDidObserveLink(self)
            }
            if eventType.contains(.RENAME) {
                delegate.fsWatcherDidObserveRename(self)
            }
            if eventType.contains(.REVOKE) {
                delegate.fsWatcherDidObserveRevoke(self)
            }
            if eventType.contains(.CREATE) {
                delegate.fsWatcherDidObserveCreate(self)
            }
        }

    }
    
    // MARK: - Methods
    
    /// Start watching.
    ///
    /// This method does follow links.
    public func startWatching() -> Bool {
        
        // create a watcher for CREATE event if path not exists and events contains CREATE
        if !path.exists {
            if events.contains(.CREATE) {
                let parent = path.parent.absolute
                var _events = events
                _events.remove(.CREATE)
                // only watch a CREATE event if parent exists and is a directory
                if parent.isDirectoryFile {
                    createWatcher = parent.watch(.WRITE) { [unowned self] watch in
                        // stop watching when path created
                        if self.path.isRegular || self.path.isDirectoryFile {
                            self.delegate?.fsWatcherDidObserveCreate(self)
                            self.startWatching()
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
                fileDescriptor = open(path._rawValue, O_EVTONLY)
                if fileDescriptor == -1 { return false }
                var _events = events
                _events.remove(.CREATE)
                source = dispatch_source_create(GCDSourceType.VNODE, UInt(fileDescriptor), _events.rawValue , queue)
                
                // Recheck if open success and source create success
                if source != nil && fileDescriptor != -1 {
                    guard callback != nil || delegate != nil else {
                        return false
                    }
                    
                    // Define the block to call when a file change is detected.
                    dispatch_source_set_event_handler(source!) { //[unowned self] () in
                        let eventType = GCDVNodeEvents(rawValue: dispatch_source_get_data(self.source!))
                        self.dispatchDelegate(eventType)
                    }
                    
                    // Define a cancel handler to ensure the path is closed when the source is cancelled.
                    dispatch_source_set_cancel_handler(source!) { //[unowned self] () in
                        close(self.fileDescriptor)
                        self.fileDescriptor = -1
                        self.source = nil
                    }
                    
                    // Start monitoring the path via the source.
                    dispatch_resume(source!)
                    return true
                }
            }
            return false
        } else {
            return false
        }
        
    }
    
    /// Start watching.
    ///
    /// **Note:** make sure call this func, or `self` will not release
    public func stopWatching() {
        if source != nil {
            dispatch_source_cancel(source!)
        }
    }
    
    
}

extension Path {
    
    // MARK: - Watching
    
    /// Watches a path for filesystem events and handles them in the callback or delegate.
    ///
    /// - Parameter events: The create events.
    /// - Parameter queue: The queue to be run within.
    /// - Parameter delegate: The delegate to call when events happen.
    /// - Parameter callback: The callback to be called on changes.
    public func watch2(events: GCDVNodeEvents = .ALL,
                      queue: dispatch_queue_t = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                      delegate: GCDFSWatcherDelegate? = nil,
                      callback: ((GCDVNodeWatcher) -> Void)? = nil
        ) -> GCDVNodeWatcher {
        let watcher = GCDVNodeWatcher(path: self, events: events, queue: queue, callback: callback)
        watcher.delegate = delegate
        watcher.startWatching()
        return watcher
    }
    
    #if os(iOS)
    // MARK: - Watching
    
    /// Watches a path for filesystem events and handles them in the callback or delegate.
    ///
    /// - Parameter events: The create events.
    /// - Parameter queue: The queue to be run within.
    /// - Parameter delegate: The delegate to call when events happen.
    /// - Parameter callback: The callback to be called on changes.
    public func watch(events: GCDVNodeEvents = .ALL,
                      queue: dispatch_queue_t = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                      delegate: GCDFSWatcherDelegate? = nil,
                      callback: ((GCDVNodeWatcher) -> Void)? = nil
                    ) -> GCDVNodeWatcher {
        let watcher = GCDVNodeWatcher(path: self, events: events, queue: queue, callback: callback)
        watcher.delegate = delegate
        watcher.startWatching()
        return watcher
    }
    #endif
}


