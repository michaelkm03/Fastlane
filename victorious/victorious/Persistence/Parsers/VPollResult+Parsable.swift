//
//  VPollResult+Parsable.swift
//  victorious
//
//  Created by Patrick Lynch on 12/1/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

extension VPollResult: PersistenceParsable {
    
    func populate( fromSourceModel pollResult: PollResult ) {
        self.answerId = pollResult.answerID
        self.sequenceId = pollResult.sequenceID
    }
}
