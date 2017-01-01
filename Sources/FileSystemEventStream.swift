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

/// A filesystem event stream.
internal struct FileSystemEventStream: RawRepresentable {

    /// The raw FSEventStreamRef value of `self`.
    var rawValue: FSEventStreamRef

    /// Schedules the stream on the specified run loop.
    ///
    /// - Parameter runLoop: The run loop.
    /// - Parameter runLoopMode: The run loop mode.
    func scheduleWithRunLoop(_ runLoop: CFRunLoop, runLoopMode: CFRunLoopMode) {
        FSEventStreamScheduleWithRunLoop(rawValue, runLoop, runLoopMode.rawValue)
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
    ///
    /// - Parameter runLoop: The run loop.
    /// - Parameter runLoopMode: The run loop mode.
    func unscheduleFromRunLoop(_ runLoop: CFRunLoop, runLoopMode: CFString) {
        FSEventStreamUnscheduleFromRunLoop(rawValue, runLoop, runLoopMode)
    }

    /// Schedules the stream on the specified dispatch queue
    ///
    /// - Parameter queue: The queue to be run within.
    func setDispatchQueue(_ queue: DispatchQueue) {
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
    ///
    /// - Returns: The dev_t for a device-relative stream or 0.
    func deviceBeingWatched() -> dev_t {
        return FSEventStreamGetDeviceBeingWatched(rawValue)
    }

    /// The sinceWhen attribute of the stream.
    var lastEventId: FSEventStreamEventId {
        return FSEventStreamGetLatestEventId(rawValue)
    }
}

#endif
