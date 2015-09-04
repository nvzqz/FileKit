//
//  FileType.swift
//  FileKit
//
//  Created by Nikolai Vazquez on 9/3/15.
//  Copyright © 2015 Nikolai Vazquez. All rights reserved.
//

import Foundation

public protocol FKFileType {
    
    typealias DataType
    
    var path: FKPath { get set }
    
    init(path: FKPath)
    
    func read() throws -> DataType
    
    func write(data: DataType) throws
    
}
