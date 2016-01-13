//
//  VAnswer+PersistenceParsable.swift
//  victorious
//
//  Created by Patrick Lynch on 12/14/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

extension VAnswer: PersistenceParsable {
    
    func populate( fromSourceModel answer: Answer ) {
        isCorrect       = answer.isCorrect
        label           = answer.label
        mediaUrl        = answer.mediaUrl
        remoteId        = answer.answerID
        thumbnailUrl    = answer.thumbnailUrl
    }
}
