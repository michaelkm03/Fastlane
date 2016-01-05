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
    
    private let persistentStore: PersistentStoreType = PersistentStoreSelector.mainPersistentStore
    
    private(set) var user: VUser?
    private(set) var recentSequences: [VSequence] = []
    
    func populate(fromSourceModel suggestedUser: SuggestedUser) {
        persistentStore.backgroundContext.v_performBlockAndWait() { context in
            let user: VUser = context.v_findOrCreateObject(["remoteId": NSNumber(longLong: suggestedUser.user.userID)])
            user.populate(fromSourceModel: suggestedUser.user)
            self.user = user
            self.recentSequences = suggestedUser.recentSequences.flatMap {
                let sequence: VSequence = context.v_findOrCreateObject(["remoteId": String($0.sequenceID)])
                sequence.populate(fromSourceModel: $0)
                return sequence
            }
        }
    }
}
