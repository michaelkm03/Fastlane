//
//  TemplateDownloadCLI.swift
//  victorious
//
//  Created by Josh Hinman on 7/24/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Cocoa

class TemplateDownloadCLI: NSObject, VTemplateDownloadOperationDelegate {
    
    let bundleURL: NSURL
    private let operationQueue = NSOperationQueue()
    
    init(bundleURL: NSURL) {
        self.bundleURL = bundleURL
    }
    
    func downloadTemplate() {
        
        let environmentsFileURL = bundleURL.URLByAppendingPathComponent(environmentsFilename)
        let environments = environmentsFromFile(environmentsFileURL)
        let bundleInfo = getInfoFromBundle()
        let dataCache = VBundleWriterDataCache(bundleURL: bundleURL)
        
        for environment in environments {
            
            println("Downloading template and images for environment: \(environment.name)")
            
            let downloader = BasicTemplateDownloader(environment: environment)
            downloader.requestDecorator.deviceID = "c314d794-1450-4e44-9c8f-2b3aba142405"
            downloader.requestDecorator.buildNumber = bundleInfo.buildNumber
            downloader.requestDecorator.versionNumber = bundleInfo.versionNumber
            downloader.requestDecorator.locale = "en"
            
            let downloadOperation = VTemplateDownloadOperation(downloader: downloader, andDelegate: self)
            downloadOperation.dataCache = dataCache
            downloadOperation.templateConfigurationCacheID = environment.templateCacheIdentifier()
            downloadOperation.shouldRetry = false
            operationQueue.addOperations([downloadOperation], waitUntilFinished: true)
            
            if !downloadOperation.completedSuccessfully {
                fputs("Unable to download template for environment: \(environment.name)\n\n", __stderrp)
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
                fputs("Unable to read \(environmentsFileURL.path!)\n\n", __stderrp)
                exit(1)
            }
        }
        else {
            fputs("Unable to read from bundle at \(bundlePath)\n\n", __stderrp)
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
            fputs("Unable to read from: \(infoPlistURL.path!)", __stderrp)
            exit(1)
        }
    }
}
