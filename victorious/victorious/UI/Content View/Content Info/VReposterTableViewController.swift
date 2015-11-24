//
//  VReposterTableViewController.swift
//  victorious
//
//  Created by Patrick Lynch on 11/23/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import UIKit

extension VReposterTableViewController {
    
    func loadReposters( pageType pageType: VPageType, sequence: VSequence ) {
        guard let sequenceID = Int64(sequence.remoteId) else {
            return
        }
        
        SequenceRepostersOperation(sequenceID: sequenceID ).queue()
    }
}
