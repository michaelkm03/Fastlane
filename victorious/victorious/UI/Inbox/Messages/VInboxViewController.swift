//
//  VInboxViewController.swift
//  victorious
//
//  Created by Michael Sena on 12/30/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

extension VInboxViewController: SearchResultsViewControllerDelegate {
    
    func showSearch() {
        VTrackingManager.sharedInstance().trackEvent(VTrackingEventUserDidSelectCreateMessage)
        
        let newUserSearch = UserSearchViewController.newWithDependencyManager(dependencyManager)
        newUserSearch.searchResultsDelegate = self
        presentViewController(newUserSearch, animated: true, completion: nil)
    }
    
    func searchResultsViewControllerDidSelectCancel() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func searchResultsViewControllerDidSelectResult(result: AnyObject) {
        guard let userResult = result as? UserSearchResultObject else {
            return
        }
        
        let loadedUser: VUser? = PersistentStoreSelector.defaultPersistentStore.mainContext.v_performBlockAndWait() { context in
            let uniqueInfo = [ "remoteId" : userResult.sourceResult.userID ]
            return context.v_findObjects( uniqueInfo ).first as? VUser
        }
        
        if let user = loadedUser {
            self.displayConversationForUser(user, animated: true)
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
}
