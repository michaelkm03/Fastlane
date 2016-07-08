//
//  RefreshStage.swift
//  victorious
//
//  Created by Sebastian Nystorm on 23/3/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

/// Indicates to client to update either one of its stages.
public struct RefreshStage {
    
    public let serverTime: NSDate?
    
    /// Points to the different instaces of Stage.
    public let section: RefreshSection
    
    /// The new content to be fetched and played on stage.
    public let contentID: String
    
    /// May be set in order to sync clients to the same spot.
    public let startTime: NSDate?
    
    public init?(json: JSON, serverTime: NSDate? = nil) {
        guard let contentID = json["content_id"].string else {
            return nil
        }
        
        self.contentID = contentID
        self.serverTime = serverTime
        
        if let startTime = json["start_time"].double {
            self.startTime = NSDate(millisecondsSince1970: startTime)
        } else {
            self.startTime = nil
        }

        let section = json["section"].string ?? "main_stage"
        
        let lowerCasedSection = section.lowercaseString
        switch lowerCasedSection {
        case "vip_stage":
            self.section = RefreshSection.VIPStage
        case "main_stage":
            self.section = RefreshSection.MainStage
        default:
            return nil
        }
    }
}
