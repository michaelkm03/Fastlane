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
class VTracking: NSManagedObject, TrackingModel {
    
    func trackingURLsForKey(key: CellTrackingKey) -> [String]? {
        switch key {
            case .cellClick:
                return cellClick as? [String]
            case .cellView:
                return cellView as? [String]
            case .cellLoad:
                return cellLoad as? [String]
        }
    }
    
    func trackingURLsForKey(key: ViewTrackingKey) -> [String]? {
        switch key {
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
            case .stageView:
                return stageView as? [String]
        }
    }
    
    // Legacy way of doing things, would be better to just have the model store a single
    // dictionary and have all trackers access urls via the protocol method.
    //
    // Example future code:
    //
    //// This object is a dictionary of strings, each corresponding to a raw value for CellTrackingKey or ViewTrackingKey, keyed to values that are arrays of strings representing urls that should be hit for the provided tracking key.
    //@NSManaged var trackingMap: NSObject?
    //
    @NSManaged var id: String
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
    @NSManaged var stageView: NSObject?
    @NSManaged var content: VContent
}
