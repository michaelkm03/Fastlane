//
//  ProfileDeepLinkHandler.swift
//  victorious
//
//  Created by Vincent Ho on 6/6/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class ProfileDeepLinkHandler: NSObject, VDeeplinkHandler {
    static let profileDeeplinkURLHostComponent = "profile"
    
    private var dependencyManager: VDependencyManager
    private weak var originViewController: UIViewController?
    
    init(dependencyManager: VDependencyManager, originViewController: UIViewController) {
        self.dependencyManager = dependencyManager
        self.originViewController = originViewController
    }
    
    var requiresAuthorization = false
    
    func displayContentForDeeplinkURL(url: NSURL, completion: VDeeplinkHandlerCompletionBlock?) {
        guard canDisplayContentForDeeplinkURL(url),
            let userID = Int(url.v_firstNonSlashPathComponent()),
            let originViewController = originViewController else {
                completion?(false, nil)
                return
        }
        
        ShowProfileOperation(
            originViewController: originViewController,
            dependencyManager: dependencyManager,
            userId: userID
        ).queue() { error, cancelled in
            let finished = (error == nil) && !cancelled
            completion?(finished , nil)
        }
    }
    
    func canDisplayContentForDeeplinkURL(url: NSURL) -> Bool {
        guard let userID = Int(url.v_firstNonSlashPathComponent()) else {
            return false
        }
        let isValidUserID = userID > 0
        let isHostValid = url.host == ProfileDeepLinkHandler.profileDeeplinkURLHostComponent

        return isHostValid && isValidUserID
    }
    
    class func deepLinkURL(for user: UserModel) -> NSURL {
        return NSURL(string: "vthisapp://\(profileDeeplinkURLHostComponent)/\(user.id)")!
    }

}
