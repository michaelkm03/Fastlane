//
//  DeleteFlagContentHelper.swift
//  victorious
//
//  Created by Vincent Ho on 7/5/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class DeleteFlagContentHelper: NSObject {
    private static let sharedInstance = DeleteFlagContentHelper()
    private var ids: Set<Content.ID> = Set()
    
    static func canParse(contentID: Content.ID) -> Bool {
        return sharedInstance.ids.contains(contentID)
    }
    
    static func add(contentID: Content.ID) {
        sharedInstance.ids.insert(contentID)
    }
}
