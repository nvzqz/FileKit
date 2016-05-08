/*:
# FileKit
Use this playground to try out FileKit
*/
import Cocoa
import FileKit
import XCPlayground

extension Path {
    static let SharedPlaygroundData = Path(url: XCPlaygroundSharedDataDirectoryURL)!
}

let shared = Path.SharedPlaygroundData
let sample = TextFile(path: shared/"filekit_sample.txt")
try? sample.write("Hello there!")
try? sample.read()
