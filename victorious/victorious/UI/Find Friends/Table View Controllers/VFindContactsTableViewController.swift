//
//  VFindContactsTableViewController.swift
//  victorious
//
//  Created by Michael Sena on 1/5/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

extension VFindContactsTableViewController {

    func findFriendsByEmails(emails: [String], completion:(results: [VUser]?, error: NSError?)->()) {
        
        guard let operation = FriendFindByEmailOperation(emails: emails) else {
            completion(results: nil,error: nil)
            return
        }
        
        operation.queue() { error in
            guard let users = operation.results as? [VUser] else {
                completion(results: nil, error: error)
                return
            }
            completion(results: users, error: error)
        }
    }
}

