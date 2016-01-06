//
//  VInboxViewController.swift
//  victorious
//
//  Created by Michael Sena on 12/30/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

extension VInboxViewController: UserSearchViewControllerDelegate {
    
    func showSearch() {
        VTrackingManager.sharedInstance().trackEvent(VTrackingEventUserDidSelectCreateMessage)
        
        let newUserSearch = UserSearchViewController.newWithDependencyManager(dependencyManager)
        newUserSearch.userSearchViewControllerDelegate = self
        presentViewController(newUserSearch, animated: true, completion: nil)
    }
    
    func userSearchViewControllerDidSelectCancel(userSearchViewController: UserSearchViewController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func userSearchViewController(userSearchViewController: UserSearchViewController, didSelectUser user: User) {
        // TODO: hacky glue code to get user search working on new persistence layer. Remove this once Conversation/Inbox doesn't require VUSer objects
        let user = MainPersistentStore().mainContext.v_findObjectsWithEntityName(VUser.v_entityName(), queryDictionary: ["remoteId": NSNumber(integer: user.userID)]).first
        if let user = user as? VUser {
            displayConversationForUser(user, animated: true)
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
}
