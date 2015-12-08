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
        switch pageType {
        case .First:
            operation = SequenceRepostersOperation(sequenceID: sequenceID )
        case .Next:
            operation = self.repostersOperation?.next()
        case .Previous:
            operation = self.repostersOperation?.prev()
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
