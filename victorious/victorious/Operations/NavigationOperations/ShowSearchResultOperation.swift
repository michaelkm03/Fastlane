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
    
    override func start() {
        super.start()
        dispatch_sync( dispatch_get_main_queue(), performNavigation )
    }
    
    private func performNavigation() {
        self.beganExecuting()
        
        if let userResult = searchResult as? UserSearchResultObject {
            let operation = FetchUserOperation(fromUser: userResult.sourceResult)
            operation.queue() { op in
                if let user = operation.result,
                    let vc = VUserProfileViewController.userProfileWithUser(user, andDependencyManager: self.dependencyManager) {
                        self.navigationController.pushViewController(vc, animated: true)
                        self.finishedExecuting()
                }
            }
            
        } else if let hashtagResult = searchResult as? HashtagSearchResultObject {
            let hashtag = hashtagResult.sourceResult.tag
            if let vc = dependencyManager.hashtagStreamWithHashtag(hashtag) {
                navigationController.pushViewController(vc, animated: true)
                finishedExecuting()
            }
        }
    }
}
