//
//  VSuggestedUser.swift
//  victorious
//
//  Created by Tian Lan on 11/24/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

@objc class VSuggestedUser: NSObject, PersistenceParsable {
    var user = VUser()
    var recentSequences: [VSequence] = []
    
    func populate(fromSourceModel suggestedUser: SuggestedUser) {
        user.populate(fromSourceModel: suggestedUser.user)
        recentSequences = (suggestedUser.recentSequences.flatMap {
            let sequence: VSequence = VSequence()
            sequence.populate(fromSourceModel: $0)
            return sequence
            })
    }
}