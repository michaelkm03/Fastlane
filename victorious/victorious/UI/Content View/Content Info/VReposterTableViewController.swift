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
        
        let operation: SequenceRepostersOperation?
        switch pageType {
        case .Refresh:
            operation = SequenceRepostersOperation(sequenceID: sequence.remoteId )
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
