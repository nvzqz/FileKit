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

- Xcode
    - Version:  **7.0**
    - Language: **Swift 2.0**
- OS X
    - Compatible With:   **OS X 10.11**
    - Deployment Target: **OS X 10.9**
- iOS
    - Compatible With:   **iOS 9.0**
    - Deployment Target: **iOS 8.0**
- watchOS
    - Compatible With:   **watchOS 2.0**
    - Deployment Target: **watchOS 2.0**
- tvOS
    - Compatible With:   **tvOS 9.0**
    - Deployment Target: **tvOS 9.0**

### Install Using CocoaPods
[CocoaPods](https://cocoapods.org/) is a centralized dependency manager for
Objective-C and Swift. Go [here](https://guides.cocoapods.org/using/index.html)
to learn more.

1. Add the project to your [Podfile](https://guides.cocoapods.org/using/the-podfile.html).

    ```ruby
    use_frameworks!

    pod 'FileKit', '~> 1.7.0'
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

#### Initialization

Paths can be created with an initializer or with a string literal.

```swift
let home = Path("~")
let drive: Path = "/Volumes/Macintosh HD"
```

#### Operations

##### New Files

A blank file can be written by calling `createFile()` on an `Path`.

```swift
do {
    try Path(".gitignore").createFile()
} catch {
    print("Could not create .gitignore")
}
```

##### New Directories

A directory can be created by calling `createDirectory()` on an `Path`.

```swift
do {
    try Path("~/Files").createDirectory()
} catch {
    print("Could not create Files")
}
```

##### New Symlinks

A symbolic link can be created by calling `createSymlinkToPath(_:)` on an `Path`.

```swift
do {
    let filePath = Path.UserDesktop + "text.txt"
    try filePath.createFile()

    let linkPath = Path.UserDesktop + "link.txt"
    try filePath.createSymlinkToPath(linkPath)
    print(linkPath.exists)  // true

    let text = "If she weighs the same as a duck, she's made of wood."
    try text |>  TextFile(path: filePath)

    let contents = try TextFile(path: linkPath).read()
    print(contents == text)  // true
} catch {
    print("Could not create symlink")
}
```

##### Finding Paths

You can find all paths with the ".txt" extension five folders deep into the
Desktop with:

```swift
let textFiles = Path.UserDesktop.findPaths(searchDepth: 5) { path in
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
let essay  = Path.UserDocuments + "My Essay.docx"
```

It can also be used to concatenate a string and a path, making the string value
a `Path` beforehand.

##### `+=` Operator

Appends the right path to the left path

```swift
var photos = Path.UserPictures + "My Photos"  // ~/Pictures/My Photos
photos += "../My Other Photos"                  // ~/Pictures/My Photos/../My Other Photos
```

##### `%` Operator

Returns the standardized version of the path.

```swift
let path: Path = "~/Desktop"
path% == path.standardized  // true
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
let textFile = File<String>(path: Path.UserDesktop + "sample.txt")
```

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

do {
    try "My Awesome Project" |> readme
    try "This is an awesome project." |>> readme
} catch {
    print("Could not write to \(readme.path)")
}
```

#### DictionaryFile

A typealias to `File<NSDictionary>`.

#### ArrayFile

A typealias to `File<NSArray>`

#### DataFile

A typealias to `File<NSData>`

## License

FileKit and its assets are released under the [MIT License](LICENSE.md). Assets
can be found in the [`assets`](https://github.com/nvzqz/FileKit/tree/assets)
branch.
