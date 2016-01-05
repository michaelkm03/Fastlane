//
//  VFindContactsTableViewController.swift
//  victorious
//
//  Created by Michael Sena on 1/4/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import VictoriousIOSSDK

extension VFindContactsTableViewController {
    
    func findFriendsByEmails(emails: [String], completion:(results: [VUser]?, error: NSError?)->()) {
        let operation = FriendFindByEmailOperation(emails: emails)
        operation.queue() { error in
            completion(results: operation.results, error: error)
        }
    }
}
