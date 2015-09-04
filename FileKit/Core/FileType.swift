//
//  FileType.swift
//  FileKit
//
//  Created by Nikolai Vazquez on 9/3/15.
//  Copyright © 2015 Nikolai Vazquez. All rights reserved.
//

import Foundation

public protocol FileType {
    
    typealias DataType
    
    var path: Path { get set }
    
    init(path: Path)
    
    func read() throws -> DataType
    
    func write(data: DataType) throws
    
}
