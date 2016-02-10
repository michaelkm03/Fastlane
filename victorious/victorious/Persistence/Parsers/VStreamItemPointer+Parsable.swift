//
//  VStreamItemPointer+Parsable.swift
//  victorious
//
//  Created by Patrick Lynch on 2/5/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

extension VStreamItemPointer: PersistenceParsable {
    
    func populate( fromSourceModel sourceSequence: Sequence ) {
        
        headline = sourceSequence.headline ?? headline
        
        if let trackingData = sourceSequence.tracking {
            let tracking = v_managedObjectContext.v_createObject() as VTracking
            tracking.populate(fromSourceModel: trackingData)
            self.tracking = tracking
        }
    }
}
