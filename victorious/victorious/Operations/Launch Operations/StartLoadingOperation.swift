//
//  StartLoadingOperation.swift
//  victorious
//
//  Created by Vincent Ho on 4/13/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

final class StartLoadingOperation: SyncOperation<Void>, VTemplateDownloadOperationDelegate {

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
    
    override var executionQueue: Queue {
        return .background
    }
    
    override func execute() -> OperationResult<Void> {
        var cachedTemplate = VDependencyManager.dependencyManagerWithDefaultValuesForColorsAndFonts()
        if let template = template as? [NSObject: AnyObject] {
            let parentManager = VDependencyManager(
                parentManager: cachedTemplate,
                configuration: nil,
                dictionaryOfClassesByTemplateName: nil
            )
            
            cachedTemplate = VDependencyManager(
                parentManager: parentManager,
                configuration: template,
                dictionaryOfClassesByTemplateName: nil
            )
        }
        
        TempDirectoryCleanupOperation().queue()
        
        let loginOperation = StoredLoginOperation(dependencyManager: cachedTemplate)
        
        loginOperation.rechainAfter(self)
        if template == nil {
            templateDownloadOperation.rechainAfter(loginOperation)
        } else {
            templateDownloadOperation.after(loginOperation)
        }
        
        loginOperation.queue()
        let backgroundQueue = NSOperationQueue.v_globalBackgroundQueue
        backgroundQueue.addOperation(templateDownloadOperation)
        
        return .success()
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
