//
//  DisplayableChatMessage.swift
//  victorious
//
//  Created by Tian Lan on 5/9/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

/// Conformers are content objects that can be displayed in a chat message cell
protocol DisplayableChatMessage {
    
    var mediaAttachment: MediaAttachment? { get }
    var dateSent: NSDate { get }
    var text: String? { get }
    var userID: Int { get }
    var username: String { get }
    var profileURL: NSURL? { get }
    var timeLabel: String { get }
}
