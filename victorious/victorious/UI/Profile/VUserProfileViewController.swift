//
//  VUserProfileViewController.swift
//  victorious
//
//  Created by Patrick Lynch on 11/16/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import UIKit

extension VUserProfileViewController {
    
    func fetchUserInfo( userID userID: Int, completion:((NSError?)->())) -> NSOperation {
        let operation = UserInfoOperation( userID: userID )
        operation.queue() { error in
            completion( error )
        }
        return operation
    }
}
