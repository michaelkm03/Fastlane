//
//  ShowSearchResultOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 1/26/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class ShowSearchResultOperation: Operation {
    
    let searchResult: AnyObject
    let navigationController: UINavigationController
    let dependencyManager: VDependencyManager
    
    required init(searchResult: AnyObject, onNavigationController navigationController: UINavigationController, dependencyManager: VDependencyManager) {
        self.searchResult = searchResult
        self.navigationController = navigationController
        self.dependencyManager = dependencyManager
    }
    
    override func main() {
        dispatch_sync( dispatch_get_main_queue(), performNavigation )
    }
    
    private func performNavigation() {
        
        if let userResult = searchResult as? UserSearchResultObject {
            if let viewController = self.dependencyManager.userProfileViewControllerWithRemoteId(userResult.sourceResult.userID) {
                navigationController.pushViewController(viewController, animated: true)
            }
            
        } else if let hashtagResult = searchResult as? HashtagSearchResultObject {
            let hashtag = hashtagResult.sourceResult.tag
            if let viewController = dependencyManager.hashtagStreamWithHashtag(hashtag) {
                navigationController.pushViewController(viewController, animated: true)
            }
        }
    }
}
