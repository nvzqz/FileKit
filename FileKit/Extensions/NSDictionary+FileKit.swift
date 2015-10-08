//
//  NSDictionary+FileKit.swift
//  FileKit
//
//  Created by Nikolai Vazquez on 10/8/15.
//  Copyright © 2015 Nikolai Vazquez. All rights reserved.
//

import Foundation

extension NSDictionary: FKWritable {

    /// Writes the dictionary to a path.
    public func writeToPath(path: FKPath) throws {
        try writeToPath(path, atomically: true)
    }

    /// Writes the dictionary to a path.
    public func writeToPath(path: FKPath, atomically useAuxiliaryFile: Bool) throws {
        guard self.writeToFile(path.rawValue, atomically: useAuxiliaryFile) else {
            throw FKError.WriteToFileFail
        }
    }
    
}
