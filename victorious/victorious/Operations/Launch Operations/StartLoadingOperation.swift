//
//  StartLoadingOperation.swift
//  victorious
//
//  Created by Vincent Ho on 4/13/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class StartLoadingOperation: BackgroundOperation, VTemplateDownloadOperationDelegate {
    
    var template: NSDictionary? {
        if let templateConfiguration = self.templateDownloadOperation.templateConfiguration {
            return templateConfiguration
        } else {
            let environmentManager = VEnvironmentManager.sharedInstance()
            guard let buildNumber = NSBundle.mainBundle().objectForInfoDictionaryKey(kCFBundleVersionKey as String) as? String else {
                return nil
            }
            let templateCache = TemplateCache(dataCache: VDataCache(),
                                              environment: environmentManager.currentEnvironment,
                                              buildNumber: buildNumber)
            self.templateDownloadOperation.templateCache = templateCache
            
            guard let cachedTemplateData = templateCache.cachedTemplateData() else {
                return nil
            }
            let cachedTemplate = VTemplateSerialization.templateConfigurationDictionaryWithData(cachedTemplateData)
            
            return cachedTemplate
        }
    }
    
    private lazy var templateDownloadOperation: VTemplateDownloadOperation = {
        VTemplateDownloadOperation(downloader: PersistenceTemplateDownloader(), andDelegate: self)
    }()
    
    override func start() {
        super.start()
        
        defer {
            self.finishedExecuting()
        }
        
        let loginOperation = AgeGate.isAnonymousUser() ? AnonymousLoginOperation() : StoredLoginOperation()
        
        loginOperation.rechainAfter(self)
        if template == nil {
            templateDownloadOperation.rechainAfter(loginOperation)
        } else {
            templateDownloadOperation.after(loginOperation)
        }
        
        loginOperation.queue()
        let backgroundQueue = NSOperationQueue.v_globalBackgroundQueue
        backgroundQueue.addOperation(templateDownloadOperation)
    }
    
    // MARK: - VTemplateDownloadOperationDelegate methods
    
    func templateDownloadOperationFailed(downloadOperation: VTemplateDownloadOperation) {
        dispatch_async(dispatch_get_main_queue(), {
            /// If the template download failed and we're using a user environment, then we should switch back to the default
            let currentEnvironment = VEnvironmentManager.sharedInstance().currentEnvironment
            if currentEnvironment.isUserEnvironment {
                downloadOperation.cancel()
                VEnvironmentManager.sharedInstance().revertToPreviousEnvironment()
                let userInfo = [
                    VEnvironmentDidFailToLoad: true
                ]
                NSNotificationCenter.defaultCenter().postNotificationName(VSessionTimerNewSessionShouldStart,
                    object: self,
                    userInfo: userInfo)
            }
        })
    }
    
}
