//
//  Stageable.swift
//  victorious
//
//  Created by Sebastian Nystorm on 10/3/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation


public protocol Stageable {
    
    var duration: Double? { get }
    
    var endTime: Double? { get }
    
    var resourceLocation: String? { get }
}
