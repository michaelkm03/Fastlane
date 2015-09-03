//
//  TemplateDownloadCLI.swift
//  victorious
//
//  Created by Josh Hinman on 7/24/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Cocoa
import VictoriousCommon

/// Provides a command-line interface to instantiating and running an instance of VTemplateDownloader
class TemplateDownloadCLI: NSObject, VTemplateDownloadOperationDelegate {
    
    /// A URL to an application bundle where the template will be cached
    let bundleURL: NSURL
    
    private let operationQueue = NSOperationQueue()
    private let deviceID = "c314d794-1450-4e44-9c8f-2b3aba142405"
    
    init(bundleURL: NSURL) {
        self.bundleURL = bundleURL
    }
    
    /// Downloads templates for one or more environments
    ///
    /// :param: environmentName The name of the environment for which to download a template, or `nil` to download templates for all environments specified in the application bundle
    func downloadTemplate(environmentName: String? = nil) {
        
        let environmentsFileURL = bundleURL.URLByAppendingPathComponent(environmentsFilename)
        let environments = environmentsFromFile(environmentsFileURL)
        let bundleInfo = getInfoFromBundle()
        let dataCache = VBundleWriterDataCache(bundleURL: bundleURL)
        
        for environment in environments {
            
            if let environmentName = environmentName where environment.name != environmentName {
                continue
            }
            println("Downloading template and images for environment: \(environment.name)")
            
            let downloader = BasicTemplateDownloader(environment: environment, deviceID: deviceID, buildNumber: bundleInfo.buildNumber, versionNumber: bundleInfo.versionNumber)
            
            let downloadOperation = VTemplateDownloadOperation(downloader: downloader, andDelegate: self)
            downloadOperation.dataCache = dataCache
            downloadOperation.templateConfigurationCacheID = environment.templateCacheIdentifier()
            downloadOperation.shouldRetry = false
            operationQueue.addOperations([downloadOperation], waitUntilFinished: true)
            
            if !downloadOperation.completedSuccessfully {
                println("Unable to download template for environment: \(environment.name)\n")
                exit(1)
            }
        }
        println("Done!\n")
    }
    
    private func environmentsFromFile(environmentsFileURL: NSURL?) -> [VEnvironment] {
        
        if let environmentsFileURL = environmentsFileURL {
            if let environments = VEnvironment.environmentsFromPlist(environmentsFileURL) as? [VEnvironment] {
                return environments
            }
            else {
                println("Unable to read \(environmentsFileURL.path!)\n")
                exit(1)
            }
        }
        else {
            println("Unable to read from bundle at \(bundlePath)\n")
            exit(1)
        }
    }
    
    private struct BundleInfo {
        let buildNumber: String
        let versionNumber: String
    }
    
    private func getInfoFromBundle() -> BundleInfo {
        
        var returnValue: BundleInfo? = nil
        let infoPlistURL = bundleURL.URLByAppendingPathComponent("Info.plist", isDirectory: false)
        if let fileStream = NSInputStream(URL: infoPlistURL) {
            fileStream.open()
            if let infoPlistDictionary = NSPropertyListSerialization.propertyListWithStream(fileStream, options: 0, format:nil, error:nil) as? [String:AnyObject],
               let buildNumber = infoPlistDictionary[String(kCFBundleVersionKey)] as? String,
               let versionNumber = infoPlistDictionary["CFBundleShortVersionString"] as? String {
                returnValue = BundleInfo(buildNumber: buildNumber, versionNumber: versionNumber)
            }
            fileStream.close()
        }
        
        if let returnValue = returnValue {
            return returnValue
        }
        else {
            println("Unable to read from: \(infoPlistURL.path!)")
            exit(1)
        }
    }
}
