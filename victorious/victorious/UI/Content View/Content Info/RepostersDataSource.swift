//
//  RepostersDataSource.swift
//  victorious
//
//  Created by Patrick Lynch on 2/8/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class RepostersDataSource: PaginatedDataSource, UITableViewDataSource {
    
    let sequence: VSequence
    let dependencyManager: VDependencyManager
    
    init(sequence: VSequence, dependencyManager: VDependencyManager) {
        self.sequence = sequence
        self.dependencyManager = dependencyManager
    }
    
    func loadRepostersWithPageType(pageType: VPageType ) {
        self.loadPage(pageType,
            createOperation: {
                return SequenceRepostersOperation(sequenceID: self.sequence.remoteId)
            },
            completion: nil
        )
    }
    
    func registerCells(tableView: UITableView) {
        let identifier = VInviteFriendTableViewCell.suggestedReuseIdentifier()
        tableView.registerNib(VInviteFriendTableViewCell.nibForCell(), forCellReuseIdentifier: identifier)
    }
    
    // MARK: - UITableViewDataSource
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.visibleItems.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let identifier = VInviteFriendTableViewCell.suggestedReuseIdentifier()
        let cell = tableView.dequeueReusableCellWithIdentifier(identifier) as! VInviteFriendTableViewCell
        cell.profile = self.visibleItems[indexPath.row] as! VUser
        cell.dependencyManager = self.dependencyManager
        return cell
    }
}
