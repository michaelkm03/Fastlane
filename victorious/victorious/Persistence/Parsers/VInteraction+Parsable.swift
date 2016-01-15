//
//  VInteraction+Parseable.swift
//  victorious
//
//  Created by Patrick Lynch on 12/14/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

extension VInteraction: PersistenceParsable {
    
    func populate( fromSourceModel interaction: Interaction ) {
        nodeId          = interaction.remoteID
        question        = interaction.question
        remoteId        = interaction.remoteID
        startTime       = NSNumber(double: interaction.startTime)
        timeout         = NSNumber(double: interaction.timeout)
        type            = interaction.type
        
        answers = NSOrderedSet( array: interaction.answers.flatMap {
            let answer: VAnswer = self.v_managedObjectContext.v_findOrCreateObject(  [ "remoteId" : $0.answerID ] )
            answer.populate( fromSourceModel: $0 )
            return answer
        })
    }
}
