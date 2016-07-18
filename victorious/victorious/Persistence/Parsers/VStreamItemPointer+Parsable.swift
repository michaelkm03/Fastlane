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
    }
}
