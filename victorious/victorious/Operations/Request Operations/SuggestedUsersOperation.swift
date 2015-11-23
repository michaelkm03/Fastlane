//
//  SuggestedUsersOperation.swift
//  victorious
//
//  Created by Tian Lan on 11/23/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

class SuggestedUsersOperation: RequestOperation<SuggestedUsersRequest> {
    private let persistenceStore = PersistentStore()
    
    init() {
        super.init(request: SuggestedUsersRequest())
    }
}
