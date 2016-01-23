//
//  VConversation+FlaggableForDeletion.swift
//  victorious
//
//  Created by Michael Sena on 1/22/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

extension VConversation: Deletable {
    
    var markedForDeletion: Bool {
        get {
            return self.flaggedForDeletion.boolValue
        }
        set {
            self.flaggedForDeletion = newValue
        }
    }
    
    static var markedForDeletionPredicate: NSPredicate {
        return NSPredicate(format: "%K == YES", VConversation.Keys.flaggedForDeletion.rawValue)
    }
    
    static var notMarkedForDeletionPredicate: NSPredicate{
        return NSPredicate(format: "%K == NO", VConversation.Keys.flaggedForDeletion.rawValue)
    }
}
