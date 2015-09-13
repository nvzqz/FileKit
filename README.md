<p align="center">
    <img src="https://github.com/nvzqz/FileKit/raw/assets/banner.png">
</p>

<p align="center">
    <img src="https://img.shields.io/badge/platform-osx%20%7C%20ios-lightgrey.svg"
         alt="Platform">
    <img src="https://img.shields.io/badge/language-swift-orange.svg"
         alt="Language">
    <a href="https://cocoapods.org/pods/FileKit">
        <img src="https://img.shields.io/cocoapods/v/FileKit.svg"
             alt="CocoaPods">
    </a>
    <a href="https://github.com/Carthage/Carthage">
        <img src="https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat"
             alt="Carthage">
    </a>
    <img src="https://img.shields.io/badge/license-MIT-000000.svg"
         alt="License">
</p>

<p align="center">
    <a href="#installation">Installation</a>
  • <a href="#usage">Usage</a>
  • <a href="#license">License</a>
</p>


FileKit is a Swift framework that allows for simple and expressive file management.

## Installation

### Compatibility

- Xcode
    - Version:  **7.0**
    - Language: **Swift 2.0**
- OS X
    - Compatible With:   **OS X 10.11**
    - Deployment Target: **OS X 10.9**
- iOS
    - Compatible With:   **iOS 9.0**
    - Deployment Target: **iOS 8.0**

### Install Using CocoaPods
[CocoaPods](https://cocoapods.org/) is a centralized dependency manager for
Objective-C and Swift. Go [here](https://guides.cocoapods.org/using/index.html)
to learn more.

1. Add the project to your [Podfile](https://guides.cocoapods.org/using/the-podfile.html).

    ```
    use_frameworks!

    pod 'FileKit', '~> 1.3.0'
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

Paths are handled with the `FKPath` structure.

#### Initialization

Paths can be created with an initializer or with a string literal.

```swift
let home = FKPath("~")
let drive: FKPath = "/Volumes/Macintosh HD"
```

#### Properties

Property            | Type          | Value
 ------------------ |:-------------:| ------------------------------------------
_`Current`_         | `FKPath`      | The program's current working directory
_`Separator`_       | `String`      | `"/"`
`rawValue`          | `String`      | The path as a string
`components`        | `[FKPath]`    | The path's components
`pathExtension`     | `String`      | The path's extension
`parent`            | `FKPath`      | The path's parent path
`children`          | `[FKPath]`    | The path's child paths
`standardized`      | `FKPath`      | The path by removing extraneous components
`resolved`          | `FKPath`      | The path by resolving all symlinks
`absolute`          | `FKPath`      | The path as absolute (begins with `"/"`)
`exists`            | `Bool`        | True if a file exists at the path
`isAbsolute`        | `Bool`        | True if the path begins with `"/"`
`isRelative`        | `Bool`        | True if the path does not begin with `"/"`
`isDirectory`       | `Bool`        | True if the path refers to a directory

#### Operations

##### New Files

A blank file can be written by calling `createFile()` on an `FKPath`.

```swift
do {
    try FKPath(".gitignore").createFile()
} catch {
    print("Could not create .gitignore")
}
```

##### New Directories

A directory can be created by calling `createDirectory()` on an `FKPath`.

```swift
do {
    try FKPath("~/Files").createDirectory()
} catch {
    print("Could not create Files")
}
```

##### New Symlinks

A symbolic link can be created by calling `createSymlinkToPath(_:)` on an `FKPath`.

```swift
do {
    let filePath = FKPath.UserDesktop + "text.txt"
    try filePath.createFile()

    let linkPath = FKPath.UserDesktop + "link.txt"
    try filePath.createSymlinkToPath(linkPath)
    print(linkPath.exists)  // true

    let text = "If she weighs the same as a duck, she's made of wood."
    try text |>  FKTextFile(path: filePath)

    let contents = try FKTextFile(path: linkPath).read()
    print(contents == text)  // true
} catch {
    print("Could not create symlink")
}
```

##### Finding Paths

You can find all paths with the ".txt" extension five folders deep into the
Desktop with:

```swift
let textFiles = FKPath.UserDesktop.findPaths(searchDepth: 5) { path in
    path.pathExtension == "txt"
}
```

Setting `searchDepth` to a negative value will make it run until every path in
`self` is checked against. If the checked path passes the condition, it'll be
added to the returned paths and the next path will be checked. If it doesn't and
it's a directory, its children paths will be checked.

##### `+` Operator

Appends two paths and returns the result

```swift
// ~/Documents/My Essay.docx
let essay  = FKPath.UserDocuments + "My Essay.docx"
```

##### `+=` Operator

Appends the right path to the left path

```swift
var photos = FKPath.UserPictures + "My Photos"  // ~/Pictures/My Photos
photos += "../My Other Photos"                  // ~/Pictures/My Photos/../My Other Photos
```

##### `•` Operator (alt+8)

Returns the standardized version of the path.

```swift
let path: FKPath = "~/Desktop"
path• == path.standardized  // true
```

##### `^` Operator

Returns the path's parent path.

```swift
let path: FKPath = "~/Movies"
path^ == "~"  // true
```

##### `->>` Operator

Moves the file at the left path to the right path.

`FKPath` counterpart: **`moveFileToPath(_:)`**

`FKFileType` counterpart: **`moveToPath(_:)`**

##### `->!` Operator

Forcibly moves the file at the left path to the right path by deleting anything
at the left path before moving the file.

##### `+>>` Operator

Copies the file at the left path to the right path.

`FKPath` counterpart: **`copyFileToPath(_:)`**

`FKFileType` counterpart: **`copyToPath(_:)`**

##### `+>!` Operator

Forcibly copies the file at the left path to the right path by deleting anything
at the left path before copying the file.

##### `~>>` Operator

Creates a symlink of the left path at the right path.

`FKPath` counterpart: **`symlinkFileToPath(_:)`**

`FKFileType` counterpart: **`symlinkToPath(_:)`**

##### `~>!` Operator

Forcibly creates a symlink of the left path at the right path by deleting
anything at the left path before creating the symlink.

##### Subscripting

Subscripting an `FKPath` will return all of its components up to and including
the index.

```swift
let users = FKPath("/Users/me/Desktop")[1]  // /Users
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

#### FKFileType

Files are represented with the `FKFileType` protocol.

##### `|>` Operator

Writes the data on the left to the file on the right.

```swift
do {
    try "My name is Bob." |> FKTextFile(path: FKPath.UserDesktop + "name.txt")
} catch {
    print("I can't write to a desktop file?!")
}
```

#### FKFile

A file can be made using `FKFile` with an `FKDataType` for its data type.

The generic constraint defines the file's data type.

```swift
let textFile = FKFile<String>(path: FKPath.UserDesktop + "sample.txt")
```

#### FKTextFile

The `FKTextFile` class allows for reading and writing strings to a file.

Although it is a subclass of `FKFile<String>`, `FKTextFile` offers some functionality
that `FKFile<String>` doesn't.

##### `|>>` Operator

Appends the string on the left to the `FKTextFile` on the right.

```swift
let readme = FKTextFile(path: "README.txt")

do {
    try "My Awesome Project" |> readme
    try "This is an awesome project." |>> readme
} catch {
    print("Could not write to \(readme.path)")
}
```

#### FKDictionaryFile

The `FKDictionaryFile` class allows for reading and writing dictionaries to a file.

It is not a subclass of `FKFile` but still conforms to `FKFileType`.

```swift
do {
    let df = FKDictionaryFile(path: FKPath.UserDesktop + "Sample.plist")
    let someDictionary: NSDictionary = ["FileKit" : true,
                                        "Hello"   : "World"]
    try someDictionary |> df
} catch {
    print("Something went wrong :( ...")
}
```

## License

FileKit and its assets are released under the [MIT License](LICENSE.md). Assets
can be found in the [`assets`](https://github.com/nvzqz/FileKit/tree/assets)
branch.
