//
//  TrophyCaseDeepLinkHandler.swift
//  victorious
//
//  Created by Tian Lan on 4/7/16.
//  Copyright © 2016 Victorious. All rights reserved.
//


// TODO: Remove this file
import Foundation

/// A conformer to VDeeplinkHandler that is in charge of showing the trophy case from deep links
//class TrophyCaseDeepLinkHandler: NSObject, VDeeplinkHandler {
//    
//    static let deeplinkURL = NSURL(string: "vthisapp://profile/trophyCase/")!
//    
//    private let dependencyManager: VDependencyManager
//    
//    var requiresAuthorization: Bool {
//        return false
//    }
//    
//    init(withDependencyManager dependencyManager: VDependencyManager) {
//        self.dependencyManager = dependencyManager
//    }
//    
//    // MARK: - VDeeplinkHandler
//    
//    func displayContentForDeeplinkURL(url: NSURL, completion: VDeeplinkHandlerCompletionBlock?) {
//        guard let trophyCaseViewController = dependencyManager.trophyCaseViewController() else {
//            completion?(false, nil)
//            return
//        }
//        
//        completion?(true, trophyCaseViewController)
//    }
//    
//    func canDisplayContentForDeeplinkURL(url: NSURL) -> Bool {
//        return url == TrophyCaseDeepLinkHandler.deeplinkURL
//    }
//}
