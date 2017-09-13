//
//  Path.swift
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
//  swiftlint:disable file_length
//

import Foundation

/**
 A representation of a filesystem path.

 An Path instance lets you manage files in a much easier way.
*/

public struct Path {

    // MARK: - Static Methods and Properties

    /// The standard separator for path components.
    public static let separator = "/"

    /// The root path.
    public static let root = Path(separator)

    /// The path of the program's current working directory.
    public static var current: Path {
        get {
            return Path(Path.fileManager.currentDirectoryPath)
        }
        set {
            Path.fileManager.changeCurrentDirectoryPath(newValue._safeRawValue)
        }
    }

    /// The paths of the mounted volumes available.
    public static func volumes(_ options: FileManager.VolumeEnumerationOptions = []) -> [Path] {
        let volumes = Path.fileManager.mountedVolumeURLs(includingResourceValuesForKeys: nil,
            options: options)
        return (volumes ?? []).flatMap { Path(url: $0) }
    }

    // MARK: - Properties

    public static let fileManager: FileManager = FileManager.default

    /// The stored path string value.
    public fileprivate(set) var rawValue: String

    /**
     The non-empty path string value. For internal use only.

     - Note: Some NSAPI may throw `NSInvalidArgumentException` when path is `""`, which can't catch in swift
     and cause crash
    */
    internal var _safeRawValue: String {
        return rawValue.isEmpty ? "." : rawValue
    }

    /// The standardized path string value
    public var standardRawValue: String {
        #if !os(Linux)
            return (self.rawValue as NSString).standardizingPath
        #else
            return NSString(string: self.rawValue).standardizingPath
        #endif
    }

    /// The standardized path string value without expanding tilde
    public var standardRawValueWithTilde: String {
        let comps = components
        if comps.isEmpty {
            return ""
        } else {
            return self[comps.count - 1].rawValue
        }
    }

    /**
     The components of the path.

     Returns [] if path is `.` or `""`
    */
    public var components: [Path] {
        guard rawValue != "" && rawValue != "." else {
            return []
        }
        #if !os(Linux)
            let nsstr = (self.rawValue as NSString)
        #else
            let nsstr = NSString(string: self.rawValue)
        #endif
        // remove extraneous `/` and `.`
        let cleanComps = nsstr.pathComponents.enumerated().flatMap { (arg) -> Path? in
            let (i, p) = arg
            return ((i == 0 || p != "/") && p != ".") ? Path(p) : nil
        }
        guard !isAbsolute else { return cleanComps }
        return _cleanComponents(cleanComps)
    }

    /// resolving `..` if possible
    fileprivate func _cleanComponents(_ comps: [Path]) -> [Path] {
        var isContinue = false
        let count = comps.count
        let cleanComps: [Path] = comps.enumerated().flatMap { (arg) -> Path? in
            let (i, p) = arg
            guard !(p.rawValue != ".." && i < count - 1 && comps[i + 1].rawValue == "..")
               && !(p.rawValue == ".." && i > 0 && comps[i - 1].rawValue != "..")
            else {
                isContinue = true
                return nil
            }
            return p
        }
        return isContinue ? _cleanComponents(cleanComps) : cleanComps
    }

    /// The name of the file at `self`.
    public var fileName: String {
        return self.absolute.components.last?.rawValue ?? ""
    }

    /// A new path created by removing extraneous components from the path.
    public var standardized: Path {
        #if !os(Linux)
            return Path((self.rawValue as NSString).standardizingPath)
        #else
            return Path(NSString(string: self.rawValue).standardizingPath)
        #endif
    }

    /// The standardized path string value without expanding tilde
    public var standardWithTilde: Path {
        let comps = components
        guard !comps.isEmpty else { return Path("") }
        return self[comps.count - 1]
    }

    /// A new path created by resolving all symlinks and standardizing the path.
    public var resolved: Path {
        #if !os(Linux)
            return Path((self.rawValue as NSString).resolvingSymlinksInPath)
        #else
            return Path(NSString(string: self.rawValue).resolvingSymlinksInPath)
        #endif
    }

    /**
     A new path created by making the path absolute.

     - Returns: If `self` begins with "/", then the standardized path is
                returned. Otherwise, the path is assumed to be relative to
                the current working directory and the standardized version of
                the path added to the current working directory is returned.
    */
    public var absolute: Path {
        return self.isAbsolute
            ? self.standardized
            : (Path.current + self).standardized
    }

    /// Returns `true` if the path is equal to "/".
    public var isRoot: Bool {
        return resolved.rawValue == Path.separator
    }

    /// Returns `true` if the path begins with "/".
    public var isAbsolute: Bool {
        return rawValue.hasPrefix(Path.separator)
    }

    /// Returns `true` if the path does not begin with "/".
    public var isRelative: Bool {
        return !isAbsolute
    }

    /**
     Returns `true` if a file or directory exists at the path.

     - Note: This method does follow links.
    */
    public var exists: Bool {
        return Path.fileManager.fileExists(atPath: _safeRawValue)
    }

    /**
     Returns `true` if a file or directory or symbolic link exists at the path

     - Note: This method does **not** follow links.
    */
//    public var existsOrLink: Bool {
//        return self.isSymbolicLink || Path.fileManager.fileExistsAtPath(_safeRawValue)
//    }

    /**
     Returns `true` if the current process has write privileges for the file
     at the path.

     - Note: This method does follow links.
    */
    public var isWritable: Bool {
        return Path.fileManager.isWritableFile(atPath: _safeRawValue)
    }

    /**
     Returns `true` if the current process has read privileges for the file
     at the path.

     - Note: This method does follow links.
    */
    public var isReadable: Bool {
        return Path.fileManager.isReadableFile(atPath: _safeRawValue)
    }

    /**
     Returns `true` if the current process has execute privileges for the
     file at the path.

     - Note: This method does follow links.
    */
    public var isExecutable: Bool {
        return  Path.fileManager.isExecutableFile(atPath: _safeRawValue)
    }

    /**
     Returns `true` if the current process has delete privileges for the file
     at the path.

     - Note: This method does **not** follow links.
    */
    public var isDeletable: Bool {
        return  Path.fileManager.isDeletableFile(atPath: _safeRawValue)
    }

    /**
     Returns `true` if the path points to a directory.

     - Note: This method does follow links.
    */
    public var isDirectory: Bool {
        var isDirectory: ObjCBool = false
        #if !os(Linux)
            return Path.fileManager.fileExists(atPath: _safeRawValue, isDirectory: &isDirectory)
                && isDirectory.boolValue
        #else
            return Path.fileManager.fileExists(atPath: _safeRawValue, isDirectory: &isDirectory)
                && isDirectory
        #endif
    }

    /**
     Returns `true` if the path is a directory file.

     - Note: This method does not follow links.
    */
    public var isDirectoryFile: Bool {
        return fileType == .directory
    }

    /**
     Returns `true` if the path is a symbolic link.

     - Note: This method does not follow links.
    */
    public var isSymbolicLink: Bool {
        return fileType == .symbolicLink
    }

    /**
     Returns `true` if the path is a regular file.

     - Note: This method does not follow links.
    */
    public var isRegular: Bool {
        return fileType == .regular
    }

    /**
     Returns `true` if the path exists any fileType item.

     - Note: This method does not follow links.
    */
    public var isAny: Bool {
        return fileType != nil
    }

    /// The path's extension.
    public var pathExtension: String {
        get {
            #if !os(Linux)
                return (rawValue as NSString).pathExtension
            #else
                return NSString(string: rawValue).pathExtension
            #endif
        }
        set {
            #if !os(Linux)
                let path = (rawValue as NSString).deletingPathExtension
            #else
                let path = NSString(string: rawValue).deletingPathExtension
            #endif
            rawValue = path + ".\(newValue)"
        }
    }

    /// The path's parent path.
    public var parent: Path {
        if isAbsolute {
            #if !os(Linux)
                return Path((rawValue as NSString).deletingLastPathComponent)
            #else
                return Path(NSString(string: rawValue).deletingLastPathComponent)
            #endif
        } else {
            let comps = components
            if comps.isEmpty {
                return Path("..")
            } else if comps.last!.rawValue == ".." {
                return ".." + self[comps.count - 1]
            } else if comps.count == 1 {
                return Path("")
            } else {
                return self[comps.count - 2]
            }
        }
    }

    // MARK: - Initialization

    /// Initializes a path to root.
    public init() {
        self = .root
    }

    /// Initializes a path to the string's value.
    public init(_ path: String, expandingTilde: Bool = false) {
        // empty path may cause crash
        if expandingTilde {
            #if !os(Linux)
                self.rawValue = (path as NSString).expandingTildeInPath
            #else
                self.rawValue = NSString(string: path).expandingTildeInPath
            #endif
        } else {
            self.rawValue = path
        }
    }

}

extension Path {

    // MARK: - Methods

    /**
     Runs `closure` with `self` as its current working directory.

     - Parameter closure: The block to run while `Path.current` is changed.
    */
    public func changeDirectory(_ closure: () throws -> Void) throws {
        let previous = Path.current
        defer { Path.current = previous }
        guard Path.fileManager.changeCurrentDirectoryPath(_safeRawValue) else {
            throw FileKitError.changeDirectoryFail(from: previous, to: self)
        }
        try closure()
    }

    /**
     Returns the path's children paths.

     - Parameter recursive: Whether to obtain the paths recursively.
                            Default value is `false`.

     - Note: This method follow links if recursive is `false`, otherwise not follow links
    */
    public func children(recursive: Bool = false) -> [Path] {
        let obtainFunc = recursive
            ? Path.fileManager.subpathsOfDirectory(atPath:)
            : Path.fileManager.contentsOfDirectory(atPath:)
        return (try? obtainFunc(_safeRawValue))?.map { self + Path($0) } ?? []
    }

    /**
     Returns true if `path` is a child of `self`.

     - Parameter recursive: Whether to check the paths recursively.
                            Default value is `true`.
    */
    public func isChildOfPath(_ path: Path, recursive: Bool = true) -> Bool {
        guard (isRelative && path.isRelative) || (isAbsolute && path.isAbsolute) else {
            return self.absolute.isChildOfPath(path.absolute)
        }
        guard !isRoot else { return true }
        if recursive {
            return path.isAncestorOfPath(self)
        }
        return path.parent == self
    }

    /**
     Returns true if `path` is a parent of `self`.

     Relative paths can't be compared return `false`. like `../../path1/path2` and `../path2`
    */
    public func isAncestorOfPath(_ path: Path) -> Bool {
        guard (isRelative && path.isRelative) || (isAbsolute && path.isAbsolute) else {
            return self.absolute.isAncestorOfPath(path.absolute)
        }
        guard !path.isRoot else { return true }
        return self != path && self.commonAncestor(path) == path
    }

    /**
     Returns the common ancestor between `self` and `path`.

     Relative path return the most precise path if possible
    */
    public func commonAncestor(_ path: Path) -> Path {
        guard (isRelative && path.isRelative) || (isAbsolute && path.isAbsolute) else {
            return self.absolute.commonAncestor(path.absolute)
        }
        let selfComponents = self.components
        let pathComponents = path.components

        let minCount = Swift.min(selfComponents.count, pathComponents.count)
        var total = minCount

        for index in 0 ..< total {
            guard selfComponents[index].rawValue == pathComponents[index].rawValue else {
                total = index
                break
            }
        }

        let ancestorComponents = selfComponents[0..<total]
        let common =  ancestorComponents.reduce("") { $0 + $1 }
        switch (self.relativePathType, path.relativePathType) {
        case (.absolute, .absolute), (.normal, .normal), (.normal, .current), (.current, .normal), (.current, .current):
            return common
        case (.normal, .parent), (.current, .parent), (.parent, .normal), (.parent, .current), (.parent, .parent):
            return Path("..")
        default:
            // count for prefix ".." in components
            var n1 = 0, n2 = 0
            for elem in selfComponents {
                guard elem.rawValue == ".." else { break }
                n1 += 1
            }
            for elem in pathComponents {
                guard elem.rawValue == ".." else { break }
                n2 += 1
            }

            // paths like "../../common/path1" and "../../common/path2"
            guard n1 != n2 else { return common }

            // paths like "../path" and "../../path2/path1"
            let maxCount = Swift.max(n1, n2)
            var dotPath: Path = ""
            for _ in 0..<maxCount {
                dotPath += ".."
            }
            return dotPath
        }
    }

    /// Returns the relative path type.
    public var relativePathType: RelativePathType {
        guard !isAbsolute else { return .absolute }

        let comp = self.components
        switch comp.first?.rawValue {
        case nil:
            return .current
        case ".."? where comp.count > 1:
            return .ancestor
        case ".."?:
            return .parent
        default:
            return .normal
        }
    }

    // swiftlint:disable line_length

    /**
     Returns paths in `self` that match a condition.

     - Parameters:
         - searchDepth: How deep to search before exiting. A negative
                        value will cause the search to exit only when
                        every subdirectory has been searched through.
                        Default value is `-1`.
         - condition: If `true`, the path is added.

     - Returns: An Array containing the paths in `self` that match the
                condition.

    */
    public func find(searchDepth depth: Int = -1, condition: (Path) throws -> Bool) rethrows -> [Path] {
        return try self.find(searchDepth: depth) { path in
            try condition(path) ? path : nil
        }
    }

    /**
     Returns non-nil values for paths found in `self`.

     - Parameters:
         - searchDepth: How deep to search before exiting. A negative
                        value will cause the search to exit only when
                        every subdirectory has been searched through.
                        Default value is `-1`.
         - transform: The transform run on each path found.

     - Returns: An Array containing the non-nil values for paths found in
                `self`.
    */
    public func find<T>(searchDepth depth: Int = -1, transform: (Path) throws -> T?) rethrows -> [T] {
        return try self.children().reduce([]) { values, child in
            if let value = try transform(child) {
                return values + [value]
            } else if depth != 0 {
                return try values + child.find(searchDepth: depth - 1, transform: transform)
            } else {
                return values
            }
        }
    }

    // swiftlint:enable line_length

    /// Standardizes the path.
    public mutating func standardize() {
        self = self.standardized
    }

    /// Resolves the path's symlinks and standardizes it.
    public mutating func resolve() {
        self = self.resolved
    }

    /**
     Creates a symbolic link at a path that points to `self`.

     - Parameter path: The Path to which at which the link of the file at
                       `self` will be created.
                       If `path` exists and is a directory, then the link
                       will be made inside of `path`. Otherwise, an error
                       will be thrown.

     - Throws:
         `FileKitError.FileDoesNotExist`,
         `FileKitError.CreateSymlinkFail`
    */
    public func symlinkFile(to path: Path) throws {
        // it's possible to create symbolic links to locations that do not yet exist.
//        guard self.exists else {
//            throw FileKitError.FileDoesNotExist(path: self)
//        }

        let linkPath = path.isDirectory ? path + self.fileName : path

        // Throws if linking to an existing non-directory file.
        guard !linkPath.isAny else {
            throw FileKitError.createSymlinkFail(from: self, to: path)
        }

        guard let _ = try? Path.fileManager.createSymbolicLink(
            atPath: linkPath._safeRawValue,
            withDestinationPath: self._safeRawValue)
        else {
            throw FileKitError.createSymlinkFail(from: self, to: linkPath)
        }
    }

    /**
     Creates a hard link at a path that points to `self`.

     - Parameter path: The Path to which the link of the file at
                       `self` will be created.
                       If `path` exists and is a directory, then the link
                       will be made inside of `path`. Otherwise, an error
                       will be thrown.

     - Throws:
         `FileKitError.FileDoesNotExist`,
         `FileKitError.CreateHardlinkFail`
    */
    public func hardlinkFile(to path: Path) throws {
        let linkPath = path.isDirectory ? path + self.fileName : path

        guard !linkPath.isAny else {
            throw FileKitError.createHardlinkFail(from: self, to: path)
        }

        guard let _ = try? Path.fileManager.linkItem(atPath: self._safeRawValue,
                                                     toPath: linkPath._safeRawValue)
        else {
            throw FileKitError.createHardlinkFail(from: self, to: path)
        }
    }

    /**
     Creates a file at path.

     Throws an error if the file cannot be created.

     - Throws: `FileKitError.CreateFileFail`

     - Note: This method does not follow links.

     If a file or symlink exists, this method removes the file or symlink and create regular file
    */
    public func createFile() throws {
        guard Path.fileManager.createFile(atPath: _safeRawValue,
                                          contents: nil,
                                          attributes: nil)
        else {
            throw FileKitError.createFileFail(path: self)
        }
    }

    /**
     Creates a file at path if not exist
     or update the modification date.

     Throws an error if the file cannot be created
     or if modification date could not be modified.

     - Throws:
         `FileKitError.CreateFileFail`,
         `FileKitError.AttributesChangeFail`
    */
    public func touch(_ updateModificationDate: Bool = true) throws {
        guard !self.exists else {
            if updateModificationDate {
                try _setAttribute(FileAttributeKey.modificationDate, value: Date())
            }
            return
        }
        try createFile()
    }

    // swiftlint:disable line_length

    /**
     Creates a directory at the path.

     Throws an error if the directory cannot be created.

     - Parameter createIntermediates: If `true`, any non-existent parent
                                      directories are created along with that
                                      of `self`. Default value is `true`.

     - Throws: `FileKitError.CreateDirectoryFail`

     - Note: This method does not follow links.
    */
    public func createDirectory(withIntermediateDirectories createIntermediates: Bool = true) throws {
        let manager = Path.fileManager
        guard let _ = try? manager.createDirectory(atPath: _safeRawValue,
                withIntermediateDirectories: createIntermediates,
                attributes: nil)
        else {
            throw FileKitError.createDirectoryFail(path: self)
        }
    }

    // swiftlint:enable line_length

    /**
     Deletes the file or directory at the path.

     Throws an error if the file or directory cannot be deleted.

     - Throws: `FileKitError.DeleteFileFail`

     - Note: This method does not follow links.
    */
    public func deleteFile() throws {
        guard let _ = try? Path.fileManager.removeItem(atPath: _safeRawValue) else {
            throw FileKitError.deleteFileFail(path: self)
        }
    }

    /**
     Moves the file at `self` to a path.

     Throws an error if the file cannot be moved.

     - Throws: `FileKitError.FileDoesNotExist`, `FileKitError.MoveFileFail`

     - Note: This method does not follow links.
    */
    public func moveFile(to path: Path) throws {
        guard self.isAny else {
            throw FileKitError.fileDoesNotExist(path: self)
        }
        guard !path.isAny else {
            throw FileKitError.fileAlreadyExists(path: path)
        }
        guard let _ = try? Path.fileManager.moveItem(atPath: self._safeRawValue,
                                                     toPath: path._safeRawValue)
        else {
            throw FileKitError.moveFileFail(from: self, to: path)
        }
    }

    /**
     Renames the file at `self` to a new name.

     Throws an error if the file cannot be moved.

     - Throws: `FileKitError.FileDoesNotExist`, `FileKitError.MoveFileFail`

     - Note: This method does not follow links.
    */
    public func renameFile(to newName: Path) throws {
        #if !os(Linux)
            let newPath = (self.rawValue as NSString).deletingLastPathComponent + newName
        #else
            let newPath = NSString(self.rawValue).deletingLastPathComponent + newName
        #endif
        try self.moveFile(to: newPath)
    }

    /**
     Copies the file at `self` to a path.

     Throws an error if the file at `self` could not be copied or if a file
     already exists at the destination path.

     - Throws: `FileKitError.FileDoesNotExist`, `FileKitError.CopyFileFail`

     - Note: This method does not follow links.
    */
    public func copyFile(to path: Path) throws {
        guard self.isAny else {
            throw FileKitError.fileDoesNotExist(path: self)
        }
        guard !path.isAny else {
            throw FileKitError.fileAlreadyExists(path: path)
        }
        guard let _ = try? Path.fileManager.copyItem(atPath: self._safeRawValue,
                                                     toPath: path._safeRawValue)
        else {
            throw FileKitError.copyFileFail(from: self, to: path)
        }
    }

}

extension Path: ExpressibleByStringLiteral {

    // MARK: - ExpressibleByStringLiteral

    public typealias ExtendedGraphemeClusterLiteralType = StringLiteralType

    public typealias UnicodeScalarLiteralType = StringLiteralType

    /// Initializes a path to the literal.
    public init(extendedGraphemeClusterLiteral value: ExtendedGraphemeClusterLiteralType) {
        self.rawValue = value
    }

    /// Initializes a path to the literal.
    public init(stringLiteral value: StringLiteralType) {
        self.rawValue = value
    }

    /// Initializes a path to the literal.
    public init(unicodeScalarLiteral value: UnicodeScalarLiteralType) {
        self.rawValue = value
    }

}

extension Path: RawRepresentable {

    // MARK: - RawRepresentable

    /*
     Initializes a path to the string value.

     - Parameter rawValue: The raw value to initialize from.
    */
    public init(rawValue: String) {
        self.rawValue = rawValue
    }

}

extension Path: Hashable {

    // MARK: - Hashable

    /// The hash value of the path.
    public var hashValue: Int {
        return rawValue.hashValue
    }

}

extension Path { // : Indexable {

    // MARK: - Indexable

    /// The path's start index.
    public var startIndex: Int {
        return components.startIndex
    }

    /// The path's end index; the successor of the last valid subscript argument.
    public var endIndex: Int {
        return components.endIndex
    }

    /**
     The path's subscript. (read-only)

     - Returns: All of the path's elements up to and including the index.
    */
    public subscript(position: Int) -> Path {
        let components = self.components
        guard position >= 0 && position < components.count else {
            fatalError("Path index '\(position)' out of range")
        }
        var result = components.first!
        for i in 1 ..< position + 1 {
            result += components[i]
        }
        return result
    }

    public subscript(bounds: Range<Int>) -> Path {
        let components = self.components
        guard bounds.lowerBound >= 0 && bounds.upperBound < components.count else {
            fatalError("Subscript bounds '\(bounds.lowerBound)..<\(bounds.upperBound)' out of range")
        }
        var result = components[bounds.lowerBound]
        for i in (bounds.lowerBound + 1) ..< bounds.upperBound {
            result += components[i]
        }
        return result
    }

    public subscript(partialBounds: PartialRangeFrom<Int>) -> Path {
        let components = self.components
        guard partialBounds.lowerBound >= 0 && partialBounds.lowerBound < components.count else {
            fatalError("Subscript bounds '\(partialBounds.lowerBound)...' out of range")
        }
        var result = components[partialBounds.lowerBound]
        for i in (partialBounds.lowerBound + 1) ... (components.count - 1) {
            result += components[i]
        }
        return result
    }

    public subscript(partialBounds: PartialRangeUpTo<Int>) -> Path {
        let components = self.components
        var result = components[0]
        guard partialBounds.upperBound < components.count else {
            fatalError("Subscript bounds '..<\(partialBounds.upperBound)' out of range")
        }
        for i in 1 ..< partialBounds.upperBound {
            result += components[i]
        }
        return result
    }

    public subscript(partialBounds: PartialRangeThrough<Int>) -> Path {
        let components = self.components
        var result = components[0]
        guard partialBounds.upperBound < components.count else {
            fatalError("Subscript bounds '...\(partialBounds.upperBound)' out of range")
        }
        for i in 1 ..< partialBounds.upperBound {
            result += components[i]
        }
        return result
    }

    public func index(after i: Int) -> Int {
        return components.index(after: i)
    }

}

extension Path {

    // MARK: - Attributes

    /**
     Returns the path's attributes.

     - Note: This method does not follow links.
    */
    public var attributes: [FileAttributeKey : Any] {
        return (try? Path.fileManager.attributesOfItem(atPath: _safeRawValue)) ?? [:]
    }

    /**
     Modify attributes

     - Note: This method does not follow links.
    */
    fileprivate func _setAttributes(_ attributes: [FileAttributeKey : Any]) throws {
        guard let _ = try? Path.fileManager.setAttributes(attributes,
                                                          ofItemAtPath: self._safeRawValue)
        else {
            throw FileKitError.attributesChangeFail(path: self)
        }
    }

    /// Modify one attribute
    fileprivate func _setAttribute(_ key: FileAttributeKey, value: Any) throws {
        try _setAttributes([key: value])
    }

    /// The creation date of the file at the path.
    public var creationDate: Date? {
        return attributes[FileAttributeKey.creationDate] as? Date
    }

    /// The modification date of the file at the path.
    public var modificationDate: Date? {
        return attributes[FileAttributeKey.modificationDate] as? Date
    }

    /// The name of the owner of the file at the path.
    public var ownerName: String? {
        return attributes[FileAttributeKey.ownerAccountName] as? String
    }

    /// The ID of the owner of the file at the path.
    public var ownerID: UInt? {
        if let value = attributes[FileAttributeKey.ownerAccountID] as? NSNumber {
            return value.uintValue
        }
        return nil
    }

    /// The group name of the owner of the file at the path.
    public var groupName: String? {
        return attributes[FileAttributeKey.groupOwnerAccountName] as? String
    }

    /// The group ID of the owner of the file at the path.
    public var groupID: UInt? {
        if let value = attributes[FileAttributeKey.groupOwnerAccountID] as? NSNumber {
            return value.uintValue
        }
        return nil
    }

    /// Indicates whether the extension of the file at the path is hidden.
    public var extensionIsHidden: Bool? {
        if let value = attributes[FileAttributeKey.extensionHidden] as? NSNumber {
            return value.boolValue
        }
        return nil
    }

    /// The POSIX permissions of the file at the path.
    public var posixPermissions: Int16? {
        if let value = attributes[FileAttributeKey.posixPermissions] as? NSNumber {
            return value.int16Value
        }
        return nil
    }

    /// The number of hard links to a file.
    public var fileReferenceCount: UInt? {
        if let value = attributes[FileAttributeKey.referenceCount] as? NSNumber {
            return value.uintValue
        }
        return nil
    }

    /// The size of the file at the path in bytes.
    public var fileSize: UInt64? {
        if let value = attributes[FileAttributeKey.size] as? NSNumber {
            return value.uint64Value
        }
        return nil
    }

    /// The filesystem number of the file at the path.
    public var filesystemFileNumber: UInt? {
        if let value = attributes[FileAttributeKey.systemFileNumber] as? NSNumber {
            return value.uintValue
        }
        return nil
    }
}

extension Path {

    // MARK: - FileType

    /// The FileType attribute for the file at the path.
    public var fileType: FileType? {
        guard let value = attributes[FileAttributeKey.type] as? String else {
            return nil
        }
        return FileType(rawValue: value)
    }

}

extension Path {

    // MARK: - FilePermissions

    /// The permissions for the file at the path.
    public var filePermissions: FilePermissions {
        return FilePermissions(forPath: self)
    }

}

extension Path {

    // MARK: - NSURL

    /**
     Creates a new path with given url if possible.

     - Parameter url: The url to create a path for.
    */
    public init?(url: URL) {
        guard url.isFileURL else {
            return nil
        }
        rawValue = url.path
    }

    /// - Returns: The `Path` objects url.
    public var url: URL {
        return URL(fileURLWithPath: _safeRawValue, isDirectory: self.isDirectory)
    }

}

// The following two extensions contain functionality not available on linux...yet
#if !os(Linux)
extension Path {

    // MARK: - BookmarkData

    /**
     Creates a new path with given url if possible.

     - Parameter bookmarkData: The bookmark data to create a path for.
    */
    public init?(bookmarkData bookData: Data) {
        var isStale: ObjCBool = false
        let url = try? (NSURL(
            resolvingBookmarkData: bookData,
            options: [],
            relativeTo: nil,
            bookmarkDataIsStale: &isStale) as URL)
        guard let fullURL = url else {
            return nil
        }
        self.init(url: fullURL)
    }

    /// - Returns: The `Path` objects bookmarkData.
    public var bookmarkData: Data? {
        return try? url.bookmarkData(
            options: .suitableForBookmarkFile,
            includingResourceValuesForKeys: nil,
            relativeTo: nil)
    }

}

extension Path {

    // MARK: - SecurityApplicationGroupIdentifier

    /**
     Returns the container directory associated with the specified security application group ID.

     - Parameter groupIdentifier: The group identifier.
    */
    public init?(groupIdentifier: String) {
        guard let url = FileManager().containerURL(forSecurityApplicationGroupIdentifier: groupIdentifier) else {
            return nil
        }
        self.init(url: url)
    }

}
#endif

extension Path {

    // MARK: - NSFileHandle

    /// Returns a file handle for reading the file at the path, or `nil` if no
    /// file exists.
    public var fileHandleForReading: FileHandle? {
        return FileHandle(forReadingAtPath: absolute._safeRawValue)
    }

    /// Returns a file handle for writing to the file at the path, or `nil` if
    /// no file exists.
    public var fileHandleForWriting: FileHandle? {
        return FileHandle(forWritingAtPath: absolute._safeRawValue)
    }

    /// Returns a file handle for reading and writing to the file at the path,
    /// or `nil` if no file exists.
    public var fileHandleForUpdating: FileHandle? {
        return FileHandle(forUpdatingAtPath: absolute._safeRawValue)
    }

}

extension Path {

    // MARK: - NSStream

    /// Returns an input stream that reads data from the file at the path, or
    /// `nil` if no file exists.
    public func inputStream() -> InputStream? {
        return InputStream(fileAtPath: absolute._safeRawValue)
    }

    /**
     Returns an output stream for writing to the file at the path, or `nil`
     if no file exists.

     - Parameter shouldAppend: `true` if newly written data should be
                               appended to any existing file contents,
                               `false` otherwise. Default value is `false`.
    */
    public func outputStream(append shouldAppend: Bool = false) -> OutputStream? {
        return OutputStream(toFileAtPath: absolute._safeRawValue, append: shouldAppend)
    }

}

extension Path: ExpressibleByStringInterpolation {

    // MARK: - StringInterpolationConvertible

    /// Initializes a path from the string interpolation paths.
    public init(stringInterpolation paths: Path...) {
        self.init(paths.reduce("", { $0 + $1.rawValue }))
    }

    /// Initializes a path from the string interpolation segment.
    public init<T>(stringInterpolationSegment expr: T) {
        if let path = expr as? Path {
            self = path
        } else {
            self = Path(String(describing: expr))
        }
    }
}

extension Path: CustomStringConvertible {

    // MARK: - CustomStringConvertible

    /// A textual representation of `self`.
    public var description: String {
        return rawValue
    }

}

extension Path: CustomDebugStringConvertible {

    // MARK: - CustomDebugStringConvertible

    /// A textual representation of `self`, suitable for debugging.
    public var debugDescription: String {
        return "Path(\(rawValue.debugDescription))"
    }

}

extension Path: Sequence {

    // MARK: - Sequence

    /// - Returns: An *iterator* over the contents of the path.
    public func makeIterator() -> DirectoryEnumerator {
        return DirectoryEnumerator(path: self)
    }

}

extension Path {

    // MARK: - Paths

    /// Returns the path to the user's or application's home directory,
    /// depending on the platform.
    public static var userHome: Path {
        // same as FileManager.default.homeDirectoryForCurrentUser
        return Path(NSHomeDirectory()).standardized
    }

    /// Returns the path to the user's temporary directory.
    public static var userTemporary: Path {
        // same as FileManager.default.temporaryDirectory
        return Path(NSTemporaryDirectory()).standardized
    }

    /// Returns a temporary path for the process.
    public static var processTemporary: Path {
        return Path.userTemporary + ProcessInfo.processInfo.globallyUniqueString
    }

    /// Returns a unique temporary path.
    public static var uniqueTemporary: Path {
        return Path.processTemporary + UUID().uuidString
    }

    /// Returns the path to the user's caches directory.
    public static var userCaches: Path {
        return _pathInUserDomain(.cachesDirectory)
    }

    /// Returns the path to the user's applications directory.
    public static var userApplications: Path {
        return _pathInUserDomain(.applicationDirectory)
    }

    /// Returns the path to the user's application support directory.
    public static var userApplicationSupport: Path {
        return _pathInUserDomain(.applicationSupportDirectory)
    }

    /// Returns the path to the user's desktop directory.
    public static var userDesktop: Path {
        return _pathInUserDomain(.desktopDirectory)
    }

    /// Returns the path to the user's documents directory.
    public static var userDocuments: Path {
        return _pathInUserDomain(.documentDirectory)
    }

    /// Returns the path to the user's autosaved documents directory.
    public static var userAutosavedInformation: Path {
        return _pathInUserDomain(.autosavedInformationDirectory)
    }

    /// Returns the path to the user's downloads directory.
    public static var userDownloads: Path {
        return _pathInUserDomain(.downloadsDirectory)
    }

    /// Returns the path to the user's library directory.
    public static var userLibrary: Path {
        return _pathInUserDomain(.libraryDirectory)
    }

    /// Returns the path to the user's movies directory.
    public static var userMovies: Path {
        return _pathInUserDomain(.moviesDirectory)
    }

    /// Returns the path to the user's music directory.
    public static var userMusic: Path {
        return _pathInUserDomain(.musicDirectory)
    }

    /// Returns the path to the user's pictures directory.
    public static var userPictures: Path {
        return _pathInUserDomain(.picturesDirectory)
    }

    /// Returns the path to the user's Public sharing directory.
    public static var userSharedPublic: Path {
        return _pathInUserDomain(.sharedPublicDirectory)
    }

    #if os(OSX) || os(macOS)

    /// Returns the path to the user scripts folder for the calling application
    public static var userApplicationScripts: Path {
        return _pathInUserDomain(.applicationScriptsDirectory)
    }

    /// Returns the path to the user's trash directory
    public static var userTrash: Path {
        return _pathInUserDomain(.trashDirectory)
    }

    #endif

    /// Returns the path to the system's applications directory.
    public static var systemApplications: Path {
        return _pathInSystemDomain(.applicationDirectory)
    }

    /// Returns the path to the system's application support directory.
    public static var systemApplicationSupport: Path {
        return _pathInSystemDomain(.applicationSupportDirectory)
    }

    /// Returns the path to the system's library directory.
    public static var systemLibrary: Path {
        return _pathInSystemDomain(.libraryDirectory)
    }

    /// Returns the path to the system's core services directory.
    public static var systemCoreServices: Path {
        return _pathInSystemDomain(.coreServiceDirectory)
    }

    /// Returns the path to the system's PPDs directory.
    public static var systemPrinterDescription: Path {
        return _pathInSystemDomain(.printerDescriptionDirectory)
    }

    /// Returns the path to the system's PreferencePanes directory.
    public static var systemPreferencePanes: Path {
        return _pathInSystemDomain(.preferencePanesDirectory)
    }

    /// Returns the paths where resources can occur.
    public static var allLibraries: [Path] {
        return _pathsInDomains(.allLibrariesDirectory, .allDomainsMask)
    }

    /// Returns the paths where applications can occur
    public static var allApplications: [Path] {
        return _pathsInDomains(.allApplicationsDirectory, .allDomainsMask)
    }

    fileprivate static func _pathInUserDomain(_ directory: FileManager.SearchPathDirectory) -> Path {
        return _pathsInDomains(directory, .userDomainMask)[0]
    }

    fileprivate static func _pathInSystemDomain(_ directory: FileManager.SearchPathDirectory) -> Path {
        return _pathsInDomains(directory, .systemDomainMask)[0]
    }

    fileprivate static func _pathsInDomains(_ directory: FileManager.SearchPathDirectory,
                                            _ domainMask: FileManager.SearchPathDomainMask) -> [Path] {
        return NSSearchPathForDirectoriesInDomains(directory, domainMask, true)
            .map({ Path($0).standardized })
    }

}
