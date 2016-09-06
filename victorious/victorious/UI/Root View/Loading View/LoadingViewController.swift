//
//  LoadingViewController.swift
//  victorious
//
//  Created by Tian Lan on 8/18/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import MBProgressHUD

extension VLoadingViewController {
    func startLoading() {
        guard !isLoading else {
            return
        }
        isLoading = true
        
        let loadingHelper = LoadingHelper()
        loadingHelper.completion = { [weak self] in
            self?.isLoading = false
            self?.progressHUD.taskInProgress = false
            self?.progressHUD.hide(true)
            guard let template = loadingHelper.template else {
                return
            }
            self?.onDoneLoadingWithTemplateConfiguration(template as [NSObject: AnyObject])
        }
        loadingHelper.execute()
        
        progressHUD = MBProgressHUD.showHUDAddedTo(view, animated: true)
        progressHUD.mode = .Indeterminate
        progressHUD.graceTime = 2.0
        progressHUD.taskInProgress = true
    }
}

private class LoadingHelper: NSObject {
    var completion: (() -> Void)?
    var template: NSDictionary? {
        if let templateConfiguration = self.templateDownloadOperation.templateConfiguration {
            return templateConfiguration
        }
        else {
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
        VTemplateDownloadOperation(downloader: PersistenceTemplateDownloader())
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
            templateDownloadOperation.completionBlock = { [weak self] in
                self?.loginOperation.queue() { _ in
                    self?.completion?()
                }
            }
        }
        else {
            templateDownloadOperation.after(loginOperation)
            loginOperation.queue() { [weak self] _ in
                self?.completion?()
            }
        }
        
        let backgroundQueue = Queue.background.operationQueue
        backgroundQueue.addOperation(templateDownloadOperation)
    }
}
