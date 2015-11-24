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
        
        switch pageType {
        case .First:
            self.repostersOperation = SequenceRepostersOperation(sequenceID: sequenceID )
        case .Next:
            self.repostersOperation = self.repostersOperation?.nextPageOperation
        case .Previous:
            self.repostersOperation = self.repostersOperation?.previousPageOperation
        }
        self.repostersOperation?.queue()
    }
}
