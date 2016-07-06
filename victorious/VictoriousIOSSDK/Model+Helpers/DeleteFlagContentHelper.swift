//
//  DeleteFlagContentHelper.swift
//  victorious
//
//  Created by Vincent Ho on 7/5/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class DeleteFlagContentHelper: NSObject {
    private static var ids: Set<Content.ID> = Set()
    
    static func isFlagged(contentID: Content.ID) -> Bool {
        return ids.contains(contentID)
    }
    
    static func add(contentID: Content.ID) {
        ids.insert(contentID)
    }
}
