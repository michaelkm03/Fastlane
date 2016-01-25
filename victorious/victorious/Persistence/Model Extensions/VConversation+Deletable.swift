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
            return self.markForDeletion.boolValue
        }
        set {
            self.markForDeletion = newValue
        }
    }
    
    static var markedForDeletionPredicate: NSPredicate {
        return NSPredicate(format: "%K == YES", VConversation.Keys.markForDeletion.rawValue)
    }
    
    static var notMarkedForDeletionPredicate: NSPredicate{
        return NSPredicate(format: "%K == NO", VConversation.Keys.markForDeletion.rawValue)
    }
}
