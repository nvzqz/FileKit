<p align="center">
    <img src="https://github.com/nvzqz/FileKit/raw/assets/banner.png">
</p>

<p align="center">
    <img src="https://img.shields.io/badge/platform-osx%20%7C%20ios-lightgrey.svg"
         alt="Platform">
    <img src="https://img.shields.io/badge/language-swift-orange.svg"
         alt="Language">
    <img src="https://img.shields.io/badge/license-MIT-000000.svg"
         alt="License">
</p>

<p align="center">
    <a href="#usage">Usage</a>
  • <a href="#license">License</a>
</p>


FileKit is a Swift framework that allows for simple and expressive file management.

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
`parent`            | `FKPath`      | The path's parent path
`children`          | `[FKPath]`    | The path's child paths
`standardized`      | `FKPath`      | The path by removing extraneous components
`resolved`          | `FKPath`      | The path by resolving all symlinks
`absolute`          | `FKPath`      | The path as absolute (begins with `"/"`)
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

##### `•` Operator

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
