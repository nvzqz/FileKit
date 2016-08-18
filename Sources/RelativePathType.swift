//
//  RelativePathType.swift
//  FileKit
//
//  Created by ijump on 4/30/16.
//  Copyright © 2016 Nikolai Vazquez. All rights reserved.
//

import Foundation

/// The type attribute for a relative path.
public enum RelativePathType: String {

    /// path like "dir/path".
    case normal

    /// path like "." and "".
    case current

    /// path like "../path".
    case ancestor

    /// path like "..".
    case parent

    /// path like "/path".
    case absolute

}
