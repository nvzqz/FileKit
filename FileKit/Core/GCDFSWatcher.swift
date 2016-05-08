//
//  GCDFSWatcher.swift
//  FileKit
//
//  Created by ijump on 5/2/16.
//  Copyright © 2016 Nikolai Vazquez. All rights reserved.
//

import Foundation



/// Delegate for `DispatchVnodeWatcher`
public protocol DispatchVnodeWatcherDelegate: class {
    
    // MARK: - Protocol
    
    /// Call when the file-system object was deleted from the namespace.
    func fsWatcherDidObserveDelete(watch: DispatchVnodeWatcher)
    
    /// Call when the file-system object data changed.
    func fsWatcherDidObserveWrite(watch: DispatchVnodeWatcher)
    
    /// Call when the file-system object changed in size.
    func fsWatcherDidObserveExtend(watch: DispatchVnodeWatcher)
    
    /// Call when the file-system object metadata changed.
    func fsWatcherDidObserveAttrib(watch: DispatchVnodeWatcher)
    
    /// Call when the file-system object link count changed.
    func fsWatcherDidObserveLink(watch: DispatchVnodeWatcher)
    
    /// Call when the file-system object was renamed in the namespace.
    func fsWatcherDidObserveRename(watch: DispatchVnodeWatcher)
    
    /// Call when the file-system object was revoked.
    func fsWatcherDidObserveRevoke(watch: DispatchVnodeWatcher)
    
    /// Call when the file-system object was created.
    func fsWatcherDidObserveCreate(watch: DispatchVnodeWatcher)
    
    /// Call when the directory changed(additions, deletions, and renamings).
    ///
    /// call `fsWatcherDidObserveWrite` by default
    func fsWatcherDidObserveDirectoryChange(watch: DispatchVnodeWatcher)
}

// Optional func and default func for `GCDFSWatcherDelegate`
// Empty func treated as Optional func
public extension DispatchVnodeWatcherDelegate {
    
    // MARK: - Extension
    
    public func fsWatcherDidObserveDelete(watch: DispatchVnodeWatcher) {
        
    }
    
    public func fsWatcherDidObserveWrite(watch: DispatchVnodeWatcher) {
        
    }
    
    public func fsWatcherDidObserveExtend(watch: DispatchVnodeWatcher) {
        
    }
    
    public func fsWatcherDidObserveAttrib(watch: DispatchVnodeWatcher) {
        
    }
    
    public func fsWatcherDidObserveLink(watch: DispatchVnodeWatcher) {
        
    }
    
    public func fsWatcherDidObserveRename(watch: DispatchVnodeWatcher) {
        
    }
    
    public func fsWatcherDidObserveRevoke(watch: DispatchVnodeWatcher) {
        
    }
    
    public func fsWatcherDidObserveCreate(watch: DispatchVnodeWatcher) {
        
    }
    
    public func fsWatcherDidObserveDirectoryChange(watch: DispatchVnodeWatcher) {
        fsWatcherDidObserveWrite(watch)
    }
}

/// Watcher for Vnode events
public class DispatchVnodeWatcher {
    
    // MARK: - Properties
    
    /// The paths being watched.
    public let path: Path
    
    /// The events used to create the watcher.
    public let events: DispatchVnodeEvents
    
    /// The delegate to call when events happen
    weak var delegate: DispatchVnodeWatcherDelegate?
    
    /// The watcher for watching creation event
    weak var createWatcher: DispatchVnodeWatcher?
    
    /// The callback for vnode events.
    private let callback: ((DispatchVnodeWatcher) -> Void)?
    
    /// The queue for the watcher.
    private let queue: dispatch_queue_t?
    
    /// A file descriptor for the path.
    private var fileDescriptor: CInt = -1
    
    /// A dispatch source to monitor a file descriptor created from the path.
    private var source: dispatch_source_t?
    
    /// Current events
    public var currentEvent: DispatchVnodeEvents? {
        if let source = source {
            return DispatchVnodeEvents(rawValue: dispatch_source_get_data(source))
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
         events: DispatchVnodeEvents,
         queue: dispatch_queue_t,
         callback: ((DispatchVnodeWatcher) -> Void)?
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
    private func dispatchDelegate(eventType: DispatchVnodeEvents) {
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
    public func startWatching() -> Bool {
        
        // create a watcher for CREATE event if path not exists and events contains CREATE
        if !path.exists {
            if events.contains(.Create) {
                let parent = path.parent.absolute
                var _events = events
                _events.remove(.Create)
                // only watch a CREATE event if parent exists and is a directory
                if parent.isDirectoryFile {
                    createWatcher = parent.watch(.Write) { [weak self] watch in
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
                fileDescriptor = open(path.safeRawValue, O_EVTONLY)
                if fileDescriptor == -1 { return false }
                var _events = events
                _events.remove(.Create)
                source = dispatch_source_create(DispatchSourceType.Vnode, UInt(fileDescriptor), _events.rawValue , queue)
                
                // Recheck if open success and source create success
                if source != nil && fileDescriptor != -1 {
                    guard callback != nil || delegate != nil else {
                        return false
                    }
                    
                    // Define the block to call when a file change is detected.
                    dispatch_source_set_event_handler(source!) { //[unowned self] () in
                        let eventType = DispatchVnodeEvents(rawValue: dispatch_source_get_data(self.source!))
                        self.dispatchDelegate(eventType)
                    }
                    
                    // Define a cancel handler to ensure the path is closed when the source is cancelled.
                    dispatch_source_set_cancel_handler(source!) { //[unowned self] () in
                        Darwin.close(self.fileDescriptor)
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
    
    /// Stop watching.
    ///
    /// **Note:** make sure call this func, or `self` will not release
    public func stopWatching() {
        if source != nil {
            dispatch_source_cancel(source!)
        }
    }
    
    /// Closes the watcher.
    public func close() {
        createWatcher?.stopWatching()
        Darwin.close(self.fileDescriptor)
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
    public func watch2(events: DispatchVnodeEvents = .All,
                       queue: dispatch_queue_t = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                       delegate: DispatchVnodeWatcherDelegate? = nil,
                       callback: ((DispatchVnodeWatcher) -> Void)? = nil
        ) -> DispatchVnodeWatcher {
        let watcher = DispatchVnodeWatcher(path: self, events: events, queue: queue, callback: callback)
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
    public func watch(events: DispatchVnodeEvents = .All,
                      queue: dispatch_queue_t = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),
                      delegate: DispatchVnodeWatcherDelegate? = nil,
                      callback: ((DispatchVnodeWatcher) -> Void)? = nil
        ) -> DispatchVnodeWatcher {
        let watcher = DispatchVnodeWatcher(path: self, events: events, queue: queue, callback: callback)
        watcher.delegate = delegate
        watcher.startWatching()
        return watcher
    }
    #endif
}


