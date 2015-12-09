//
//  VSuggestedUser.swift
//  victorious
//
//  Created by Tian Lan on 11/24/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

@objc class VSuggestedUser: NSObject {
    
    let recentSequences: [VSequence]
    let user: VUser
    
    init( user: VUser, recentSequences: [VSequence] ) {
        self.user = user
        self.recentSequences = recentSequences
    }
}
