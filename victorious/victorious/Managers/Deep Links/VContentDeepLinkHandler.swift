//
//  VContentDeepLinkHandler.swift
//  victorious
//
//  Created by Patrick Lynch on 12/2/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import UIKit

extension VContentDeepLinkHandler {
    
    func loadSequence( sequenceID: String, streamID: String?, completion:((NSError?)->())? ) {
        SequenceFetchOperation(sequenceID: sequenceID, streamID: streamID).queue() { error in
            completion?( error )
        }
    }
}