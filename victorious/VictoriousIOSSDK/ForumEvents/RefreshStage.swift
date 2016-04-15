//
//  RefreshStage.swift
//  victorious
//
//  Created by Sebastian Nystorm on 23/3/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

/// Indicates to client to update either one of its stages.
public struct RefreshStage: ForumEvent {
    
    // MARK: ForumEvent
    public let timestamp: NSDate
    
    /// Points to the different instaces of Stage.
    public let section: RefreshSection
    
    /// The new content to be fetched and played on stage.
    public let contentID: String
    
    public init?(json: JSON, timestamp: NSDate) {
        self.timestamp = timestamp
        
        guard let section = json["section"].string,
            let contentID = json["content_id"].string else {
            return nil
        }
        self.contentID = contentID
        
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
