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
    let buildNumber: String
    let versionNumber: String
    private let operationQueue = NSOperationQueue()
    
    init(bundleURL: NSURL, buildNumber: String, versionNumber: String) {
        self.bundleURL = bundleURL
        self.buildNumber = buildNumber
        self.versionNumber = versionNumber
    }
    
    func downloadTemplate() {
        
        let environmentsFileURL = bundleURL.URLByAppendingPathComponent(environmentsFilename)
        let environments = environmentsFromFile(environmentsFileURL)
        let dataCache = VBundleWriterDataCache(bundleURL: bundleURL)
        
        for environment in environments {
            
            println("Downloading template and images for environment: \(environment.name)")
            
            let downloader = BasicTemplateDownloader(environment: environment)
            downloader.requestDecorator.deviceID = "c314d794-1450-4e44-9c8f-2b3aba142405"
            downloader.requestDecorator.buildNumber = buildNumber
            downloader.requestDecorator.versionNumber = versionNumber
            downloader.requestDecorator.locale = "en"
            
            let downloadOperation = VTemplateDownloadOperation(downloader: downloader, andDelegate: self)
            downloadOperation.dataCache = dataCache
            downloadOperation.templateConfigurationCacheID = environment.templateCacheIdentifier()
            downloadOperation.shouldRetry = false
            operationQueue.addOperations([downloadOperation], waitUntilFinished: true)
            
            if downloadOperation.templateConfiguration == nil {
                fputs("Unable to download template for environment: \(environment.name)\n\n", __stderrp)
                exit(1)
            }
        }
    }
    
    func environmentsFromFile(environmentsFileURL: NSURL?) -> [VEnvironment] {
        
        if let environmentsFileURL = environmentsFileURL {
            if let environments = VEnvironment.environmentsFromPlist(environmentsFileURL) as? [VEnvironment] {
                return environments
            }
            else {
                fputs("Unable to read \(environmentsFileURL)\n\n", __stderrp)
                exit(1)
            }
        }
        else {
            fputs("Unable to read from bundle at \(bundlePath)\n\n", __stderrp)
            exit(1)
        }
    }
    
    func templateDownloadOperation(downloadOperation: VTemplateDownloadOperation, needsAnOperationAddedToTheQueue operation: NSOperation) {
        operationQueue.addOperation(operation)
    }
}
