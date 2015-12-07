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
        
        let operation: SequenceRepostersOperation?
        if pageType == .First {
            operation = SequenceRepostersOperation(sequenceID: sequenceID )
        } else {
            operation = self.repostersOperation?.operation(forPageType: pageType)
        }
        
        if let operation = operation {
            operation.queue() { error in
                let hasReposters: Bool = self.sequence.reposters.count > 0 && error == nil
                self.setHasReposters( hasReposters )
                self.tableView.reloadData()
            }
            self.repostersOperation = operation
        }
    }
}
