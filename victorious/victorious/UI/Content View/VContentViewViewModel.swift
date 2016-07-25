//
//  VContentViewViewModel+Networking.swift
//  victorious
//
//  Created by Patrick Lynch on 11/17/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

extension VContentViewViewModel {
    
    func loadNetworkData() {
        
    }
    
    func addComment( text text: String, publishParameters: VPublishParameters?, currentTime: NSNumber? ) {
    }
    
    func answerPoll( pollAnswer: VPollAnswer, completion: ((NSError?) -> ())? ) {
    }
}

private extension VSequence {
    
    func answerModelForPollAnswer( answer: VPollAnswer ) -> VAnswer? {
        switch answer {
        case .A:
            return self.firstNode()?.firstAnswers()?.first as? VAnswer
        case .B:
            return self.firstNode()?.firstAnswers()?.last as? VAnswer
        default:
            return nil
        }
    }
}
