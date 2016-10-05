<p align="center">
    <img src="https://github.com/nvzqz/FileKit/raw/assets/banner.png">
</p>

<p align="center">
    <img src="https://img.shields.io/badge/platform-osx%20%7C%20ios%20%7C%20watchos%20%7C%20tvos-lightgrey.svg"
         alt="Platform">
    <img src="https://img.shields.io/badge/language-swift-orange.svg"
         alt="Language: Swift">
    <a href="https://cocoapods.org/pods/FileKit">
        <img src="https://img.shields.io/cocoapods/v/FileKit.svg"
             alt="CocoaPods">
    </a>
    <a href="https://github.com/Carthage/Carthage">
        <img src="https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat"
             alt="Carthage">
    </a>
    <br>
    <a href="https://trello.com/b/s1MOyp2h/filekit">
        <img src="https://img.shields.io/badge/Trello-filekit-blue.svg"
             alt="Trello Board">
    </a>
    <a href="https://gitter.im/nvzqz/FileKit?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge">
        <img src="https://img.shields.io/badge/GITTER-join%20chat-00D06F.svg"
             alt="GITTER: join chat">
    </a>
    <img src="https://img.shields.io/badge/license-MIT-000000.svg"
         alt="License">
</p>

<p align="center">
    <a href="#installation">Installation</a>
  • <a href="#usage">Usage</a>
  • <a href="#license">License</a>
  • <a href="https://nvzqz.github.io/FileKit/docs/">Documentation</a>
</p>


FileKit is a Swift framework that allows for simple and expressive file management.

Development happens in the
[`develop`](https://github.com/nvzqz/FileKit/tree/develop) branch.

## Installation

### Compatibility

- OS X 10.9+ / iOS 8.0+ / watchOS 2.0 / tvOS 9.0

- Xcode 7.1+, Swift 2.1+

### Install Using CocoaPods
[CocoaPods](https://cocoapods.org/) is a centralized dependency manager for
Objective-C and Swift. Go [here](https://guides.cocoapods.org/using/index.html)
to learn more.

1. Add the project to your [Podfile](https://guides.cocoapods.org/using/the-podfile.html).

    ```ruby
    use_frameworks!

    pod 'FileKit', '~> 4.0.0'
    ```

2. Run `pod install` and open the `.xcworkspace` file to launch Xcode.

3. Import the FileKit framework.

    ```swift
    import FileKit
    ```

### Install Using Carthage
[Carthage](https://github.com/Carthage/Carthage) is a decentralized dependency
manager for Objective-C and Swift.

1. Add the project to your [Cartfile](https://github.com/Carthage/Carthage/blob/master/Documentation/Artifacts.md#cartfile).

    ```
    github "nvzqz/FileKit"
    ```

2. Run `carthage update` and follow [the additional steps](https://github.com/Carthage/Carthage#getting-started)
   in order to add FileKit to your project.

3. Import the FileKit framework.

    ```swift
    import FileKit
    ```

## Usage

### Paths

Paths are handled with the `Path` structure.

```swift
let home = Path("~")
let drive: Path = "/Volumes/Macintosh HD"
let file:  Path = "~/Desktop/file\(1)"
```

#### Operations

##### New Files

A blank file can be written by calling `createFile()` on an `Path`.

```swift
try Path(".gitignore").createFile()
```

##### New Directories

A directory can be created by calling `createDirectory()` on an `Path`.

```swift
try Path("~/Files").createDirectory()
try Path("~/Books").createDirectory(withIntermediateDirectories: false)
```

Intermediate directories are created by default.

##### New Symlinks

A symbolic link can be created by calling `createSymlinkToPath(_:)` on an `Path`.

```swift
try Path("path/to/MyApp.app").createSymlinkToPath("~/Applications")
print(Path("~/Applications/MyApp.app").exists)  // true
```

##### Finding Paths

You can find all paths with the ".txt" extension five folders deep into the
Desktop with:

```swift
let textFiles = Path.UserDesktop.find(searchDepth: 5) { path in
    path.pathExtension == "txt"
}
```

A negative `searchDepth` will make it run until every path in `self` is checked
against.

You can even map a function to paths found and get the non-nil results:

```swift
let documents = Path.UserDocuments.find(searchDepth: 1) { path in
    String(path)
}
```

##### Iterating Through Paths

Because `Path` conforms to `SequenceType`, it can be iterated through with a
`for` loop.

```swift
for download in Path.UserDownloads {
    print("Downloaded file: \(download)")
}
```

##### Current Working Directory

The current working directory for the process can be changed with `Path.Current`.

To quickly change the current working directory to a path and back, there's the
`changeDirectory(_:)` method:

```swift
Path.UserDesktop.changeDirectory {
    print(Path.Current)  // "/Users/nvzqz/Desktop"
}
```

##### Common Ancestor

A common ancestor between two paths can be obtained:

```swift
print(Path.Root.commonAncestor(.UserHome))       // "/"
print("~/Desktop"  <^> "~/Downloads")            // "~"
print(.UserLibrary <^> .UserApplicationSupport)  // "/Users/nvzqz/Library"
```

##### `+` Operator

Appends two paths and returns the result

```swift
// ~/Documents/My Essay.docx
let essay = Path.UserDocuments + "My Essay.docx"
```

It can also be used to concatenate a string and a path, making the string value
a `Path` beforehand.

```swift
let numberedFile: Path = "path/to/dir" + String(10)  // "path/to/dir/10"
```

##### `+=` Operator

Appends the right path to the left path. Also works with a `String`.

```swift
var photos = Path.UserPictures + "My Photos"  // ~/Pictures/My Photos
photos += "../My Other Photos"                // ~/Pictures/My Photos/../My Other Photos
```

##### `%` Operator

Returns the standardized version of the path.

```swift
let path: Path = "~/Desktop"
path% == path.standardized  // true
```

##### `*` Operator

Returns the resolved version of the path.

```swift
let path: Path = "~/Documents"
path* == path.resolved  // true
```

##### `^` Operator

Returns the path's parent path.

```swift
let path: Path = "~/Movies"
path^ == "~"  // true
```

##### `->>` Operator

Moves the file at the left path to the right path.

`Path` counterpart: **`moveFileToPath(_:)`**

`File` counterpart: **`moveToPath(_:)`**

##### `->!` Operator

Forcibly moves the file at the left path to the right path by deleting anything
at the left path before moving the file.

##### `+>>` Operator

Copies the file at the left path to the right path.

`Path` counterpart: **`copyFileToPath(_:)`**

`File` counterpart: **`copyToPath(_:)`**

##### `+>!` Operator

Forcibly copies the file at the left path to the right path by deleting anything
at the left path before copying the file.

##### `=>>` Operator

Creates a symlink of the left path at the right path.

`Path` counterpart: **`symlinkFileToPath(_:)`**

`File` counterpart: **`symlinkToPath(_:)`**

##### `=>!` Operator

Forcibly creates a symlink of the left path at the right path by deleting
anything at the left path before creating the symlink.

##### Subscripting

Subscripting an `Path` will return all of its components up to and including
the index.

```swift
let users = Path("/Users/me/Desktop")[1]  // /Users
```

##### `standardize()`

Standardizes the path.

The same as doing:
```swift
somePath = somePath.standardized
```

##### `resolve()`

Resolves the path's symlinks.

The same as doing:
```swift
somePath = somePath.resolved
```

### Files

A file can be made using `File` with a `DataType` for its data type.

```swift
let plistFile = File<NSDictionary>(path: Path.UserDesktop + "sample.plist")
```

Files can be compared by size.

#### Operators

##### `|>` Operator

Writes the data on the left to the file on the right.

```swift
do {
    try "My name is Bob." |> TextFile(path: Path.UserDesktop + "name.txt")
} catch {
    print("I can't write to a desktop file?!")
}
```

#### TextFile

The `TextFile` class allows for reading and writing strings to a file.

Although it is a subclass of `File<String>`, `TextFile` offers some functionality
that `File<String>` doesn't.

##### `|>>` Operator

Appends the string on the left to the `TextFile` on the right.

```swift
let readme = TextFile(path: "README.txt")
try "My Awesome Project" |> readme
try "This is an awesome project." |>> readme
```

#### DictionaryFile

A typealias to `File<NSDictionary>`.

#### ArrayFile

A typealias to `File<NSArray>`

#### DataFile

A typealias to `File<NSData>`

### File Permissions

The `FilePermissions` struct allows for seeing the permissions of the current
process for a given file.

```swift
let swift: Path = "/usr/bin/swift"
print(swift.filePermissions)  // FilePermissions[Read, Execute]
```

### Data Types

All types that conform to `DataType` can be used to satisfy the generic type for
`File`.

#### Readable Protocol

A `Readable` type must implement the static method `readFromPath(_:)`.

All `Readable` types can be initialized with `init(contentsOfPath:)`.

#### Writable Protocol

A `Writable` type must implement `writeToPath(_:atomically:)`.

Writing done by `writeToPath(_:)` is done atomically by default.

##### WritableToFile

Types that have a `writeToFile(_:atomically:)` method that takes in a `String`
for the file path can conform to `Writable` by simply conforming to
`WritableToFile`.

##### WritableConvertible

If a type itself cannot be written to a file but can output a writable type,
then it can conform to `WritableConvertible` and become a `Writable` that way.

### FileKitError

The type for all errors thrown by FileKit operations is `FileKitError`.

Errors can be converted to `String` directly for any logging. If only the error
message is needed, `FileKitError` has a `message` property that states why the
error occurred.

```swift
// FileKitError(Could not copy file from "path/to/file" to "path/to/destination")
String(FileKitError.CopyFileFail(from: "path/to/file", to: "path/to/destination"))
```

## License

FileKit and its assets are released under the [MIT License](LICENSE.md). Assets
can be found in the [`assets`](https://github.com/nvzqz/FileKit/tree/assets)
branch.
