//
//  ShowSearchResultOperation.swift
//  victorious
//
//  Created by Patrick Lynch on 1/26/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class ShowSearchResultOperation: MainQueueOperation {
    
    let searchResult: AnyObject
    let navigationController: UINavigationController
    let dependencyManager: VDependencyManager
    
    required init(searchResult: AnyObject, onNavigationController navigationController: UINavigationController, dependencyManager: VDependencyManager) {
        self.searchResult = searchResult
        self.navigationController = navigationController
        self.dependencyManager = dependencyManager
    }
    
    override func start() {
        super.start()
        self.beganExecuting()
    
        if let userResult = searchResult as? UserSearchResultObject {
            if let viewController = self.dependencyManager.userProfileViewControllerWithRemoteID(userResult.sourceResult.userID) {
                navigationController.pushViewController(viewController, animated: true)
            }
            
        } else if let hashtagResult = searchResult as? HashtagSearchResultObject {
            let hashtag = hashtagResult.sourceResult.tag
            if let viewController = dependencyManager.hashtagStreamWithHashtag(hashtag) {
                navigationController.pushViewController(viewController, animated: true)
            }
        }
        
        self.finishedExecuting()
    }
}
