//
//  Stageable.swift
//  victorious
//
//  Created by Sebastian Nystorm on 10/3/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

// TODO: remove this shit, cast it to asset types instead
//public enum StageMediaType {
//    case Image
//    case Video
//    case Gif
//    case Empty
//}

public protocol Stageable {
    
//    var stageMediaType: StageMediaType { get }
    
    var duration: Double? { get }
    
    // Maybe?
    var endTime: Double? { get }
    
    // NSURL?
    var resourceLocation: String? { get }
}
