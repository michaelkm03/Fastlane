//
//  VTracking.swift
//  victorious
//
//  Created by Sharif Ahmed on 6/20/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import CoreData

@objc(VTracking)
class VTracking: NSManagedObject, Tracking {
    
    func trackingURLsForKey(key: TrackingKey) -> [String]? {
        switch key {
            case .cellClick:
                return cellClick as? [String]
            case .cellView:
                return cellView as? [String]
            case .viewStart:
                return viewStart as? [String]
            case .viewStop:
                return viewStop as? [String]
            case .videoSkip:
                return videoSkip as? [String]
            case .videoError:
                return videoError as? [String]
            case .videoStall:
                return videoStall as? [String]
            case .videoComplete25:
                return videoComplete25 as? [String]
            case .videoComplete50:
                return videoComplete50 as? [String]
            case .videoComplete75:
                return videoComplete75 as? [String]
            case .videoComplete100:
                return videoComplete100 as? [String]
            case .share:
                return share as? [String]
            case .cellLoad:
                return cellLoad as? [String]
        }
    }
    
    //Legacy way of doing things, would be better to just have the model store a single
    //dictionary and have all trackers access urls via the protocol method
    @NSManaged var cellClick: NSObject?
    @NSManaged var cellView: NSObject?
    @NSManaged var cellLoad: NSObject?
    @NSManaged var share: NSObject?
    @NSManaged var videoComplete25: NSObject?
    @NSManaged var videoComplete50: NSObject?
    @NSManaged var videoComplete75: NSObject?
    @NSManaged var videoComplete100: NSObject?
    @NSManaged var videoError: NSObject?
    @NSManaged var videoSkip: NSObject?
    @NSManaged var videoStall: NSObject?
    @NSManaged var viewStart: NSObject?
    @NSManaged var viewStop: NSObject?
    @NSManaged var streamItemPointer: VStreamItemPointer?
    @NSManaged var content: VContent?
}
