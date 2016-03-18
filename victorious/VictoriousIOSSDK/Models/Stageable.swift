//
//  Stageable.swift
//  victorious
//
//  Created by Sebastian Nystorm on 10/3/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

/**
 *  This protocol allows conformers to be added to the Stage for a certain amount of time.
 */
public protocol Stageable {
    
    var duration: Double? { get }
    
    var url: NSURL { get }
}
