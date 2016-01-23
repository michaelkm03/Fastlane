//
//  VConversation+Predicates.swift
//  victorious
//
//  Created by Michael Sena on 1/22/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

extension VConversation {
    
    static var defaultPredicate: NSPredicate {
        return NSCompoundPredicate(andPredicateWithSubpredicates: [hasPostedAtPredicate, notMarkedForDeletionPredicate])
    }
    
    static var hasPostedAtPredicate: NSPredicate {
        return NSPredicate(format: "%K != nil", VConversation.Keys.postedAt.rawValue)
    }

}
