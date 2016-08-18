/*:
# FileKit
Use this playground to try out FileKit
*/
import Cocoa
import FileKit
import XCPlayground
import PlaygroundSupport

extension Path {
    static let SharedPlaygroundData = Path(url: playgroundSharedDataDirectory)!
}

let shared = Path.SharedPlaygroundData
let sample = TextFile(path: shared/"filekit_sample.txt")
try? sample.write("Hello there!")
try? sample.read()
