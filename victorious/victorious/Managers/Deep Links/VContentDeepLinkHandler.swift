//
//  VContentDeepLinkHandler.swift
//  victorious
//
//  Created by Patrick Lynch on 12/2/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import UIKit

extension VContentDeepLinkHandler {
    
    func loadSequence( sequenceID: NSString, completion:((NSError?)->())? ) {
        SequenceFetchOperation(sequenceID: Int64(sequenceID as String)! ).queue() { error in
            completion?( error )
        }
    }
}