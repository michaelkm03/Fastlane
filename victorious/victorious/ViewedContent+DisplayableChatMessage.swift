//
//  ViewedContent+DisplayableChatMessage.swift
//  victorious
//
//  Created by Tian Lan on 5/9/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

extension ViewedContent: DisplayableChatMessage {
    
    var mediaAttachment: MediaAttachment? {
        return nil
    }
    
    var dateSent: NSDate {
        return content.releasedAt
    }
    
    var text: String? {
        return content.text
    }
    
    var userID: Int {
        return author.userID
    }
    
    var username: String {
        return author.name ?? ""
    }
    
    var profileURL: NSURL? {
        return nil
    }
    
    var timeLabel: String {
        return content.releasedAt.stringDescribingTimeIntervalSinceNow(format: .concise, precision: .seconds)
    }
}
