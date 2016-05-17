//
//  ViewedContent+ChatMessageType.swift
//  victorious
//
//  Created by Tian Lan on 5/9/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

extension ViewedContent: ChatMessageType {
    
    var mediaAttachment: MediaAttachment? {
        return nil
    }
    
    var dateSent: NSDate {
        return content.releasedAt
    }
    
    var text: String? {
        return content.title
    }
    
    var userID: Int {
        return author.userID
    }
    
    var username: String {
        return author.name ?? ""
    }
    
    var profileURL: NSURL {
        return author.previewImageAssets?.first?.mediaMetaData.url ?? NSURL(string: "")!
    }
    
    var timeLabel: String {
        return content.releasedAt.stringDescribingTimeIntervalSinceNow(format: .concise, precision: .seconds)
    }
}
