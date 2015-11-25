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
    private(set) var user: VUser?
    private(set) var recentSequences: [VSequence] = []
    private let persistentStore = MainPersistentStore()
    
    func populate(fromSourceModel suggestedUser: SuggestedUser) {
        persistentStore.syncFromBackground() { context in
            let user: VUser = context.findOrCreateObject(["remoteId": NSNumber(longLong: suggestedUser.user.userID)])
            user.populate(fromSourceModel: suggestedUser.user)
            self.user = user
            self.recentSequences = (suggestedUser.recentSequences.flatMap {
                let sequence: VSequence = context.findOrCreateObject(["remoteId": String($0.sequenceID)])
                sequence.populate(fromSourceModel: $0)
                return sequence
                })
        }
    }
}
