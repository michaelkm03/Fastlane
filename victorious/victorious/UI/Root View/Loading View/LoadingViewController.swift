//
//  LoadingViewController.swift
//  victorious
//
//  Created by Tian Lan on 8/18/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import MBProgressHUD
import VictoriousIOSSDK
import VictoriousCommon

extension VLoadingViewController {
    func startLoading() {
        guard !isLoading else {
            return
        }
        isLoading = true
        
        let loadingHelper = LoadingHelper()
        loadingHelper.completion = { [weak self] in
            self?.isLoading = false
            self?.progressHUD.hide(animated: true)
            guard let template = loadingHelper.template as? [AnyHashable: Any] else {
                return
            }
            self?.onDoneLoading(withTemplateConfiguration: template)
        }
        loadingHelper.execute()
        
        progressHUD = MBProgressHUD.showAdded(to: view, animated: true)
        progressHUD.mode = .indeterminate
        progressHUD.graceTime = 2.0
    }
}

private class LoadingHelper: NSObject {
    var completion: (() -> Void)?
    var template: NSDictionary? {
        // If the new template has been downloaded use that, otherwise we pull the template out of the cache
        if let templateConfiguration = self.templateDownloadOperation.templateConfiguration {
            return templateConfiguration as NSDictionary
        }
        else {
            let environmentManager = VEnvironmentManager.sharedInstance()
            
            guard let buildNumber = Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String else {
                return nil
            }
            
            let templateCache = TemplateCache(
                dataCache: VDataCache(),
                environment: environmentManager.currentEnvironment,
                buildNumber: buildNumber
            )
            
            self.templateDownloadOperation.templateCache = templateCache
            
            guard let cachedTemplateData = templateCache.cachedTemplateData() else {
                return nil
            }
            
            return VTemplateSerialization.templateConfigurationDictionary(with: cachedTemplateData) as NSDictionary
        }
    }
    
    fileprivate lazy var templateDownloadOperation: VTemplateDownloadOperation = {
        VTemplateDownloadOperation(downloader: PersistenceTemplateDownloader())
    }()
    
    fileprivate var dependencyManager: VDependencyManager {
        var defaultDependencyManager = VDependencyManager.withDefaultValuesForColorsAndFonts()!
        if let template = template as? [AnyHashable: Any] {
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
    
    fileprivate lazy var loginOperation: StoredLoginOperation = {
        return StoredLoginOperation(dependencyManager: self.dependencyManager)
    }()
    
    func execute() {
        TempDirectoryCleanupOperation().queue()
        
        // If the downloaded template does not exist (which will be the case when we switch build numbers),
        // We will wait for the template download operation to finish before attempting login.
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
