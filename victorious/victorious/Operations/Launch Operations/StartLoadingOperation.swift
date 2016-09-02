//
//  StartLoadingOperation.swift
//  victorious
//
//  Created by Vincent Ho on 4/13/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

final class StartLoadingOperation: NSObject, VTemplateDownloadOperationDelegate {
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
    
    var completion: (Void -> Void)?
    
    private lazy var templateDownloadOperation: VTemplateDownloadOperation = {
        VTemplateDownloadOperation(downloader: PersistenceTemplateDownloader(), andDelegate: self)
    }()
    
    private var dependencyManager: VDependencyManager {
        var defaultDependencyManager = VDependencyManager.dependencyManagerWithDefaultValuesForColorsAndFonts()
        if let template = template as? [NSObject: AnyObject] {
            let parentManager = VDependencyManager(
                parentManager: defaultDependencyManager,
                configuration: nil,
                dictionaryOfClassesByTemplateName: nil
            )
            
            defaultDependencyManager = VDependencyManager(
                parentManager: parentManager,
                configuration: template,
                dictionaryOfClassesByTemplateName: nil
            )
        }
        
        return defaultDependencyManager
    }
    
    private lazy var loginOperation: StoredLoginOperation = {
        return StoredLoginOperation(dependencyManager: self.dependencyManager)
    }()
    
    func execute() {
        TempDirectoryCleanupOperation().queue()
        
        if template == nil {
            templateDownloadOperation.completionBlock = {
                self.loginOperation.queue() { _ in
                    self.completion?()
                }
            }
        }
        else {
            templateDownloadOperation.after(loginOperation)
            loginOperation.queue() { _ in
                self.completion?()
            }
        }
        
        let backgroundQueue = Queue.background.operationQueue
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
