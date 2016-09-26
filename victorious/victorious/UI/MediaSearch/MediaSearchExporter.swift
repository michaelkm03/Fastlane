//
//  MediaSearchExporter.swift
//  victorious
//
//  Created by Patrick Lynch on 7/13/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

/// Helper that handles loading preview image and streaming GIF asset
/// to a file using asynchronous operations.
class MediaSearchExporter {
    
    private let mediaSearchResult: MediaSearchResult
    private let uuidString = NSUUID().UUIDString
    
    /// - parameter mediaSearchResult: The MediaSearchResult whose assets will be loaded/
    init(mediaSearchResult: MediaSearchResult) {
        self.mediaSearchResult = mediaSearchResult
    }
    
    /// Completion closure to be called when all operations are complete.
    ///
    /// - parameter previewImage: A UIImage loaded with a still thumbnail asset
    /// - parameter mediaUrl: The URL on disk of the downloaded media file
    /// - parameter error: An NSError instance defined if there was en error, otherwise `nil`
    typealias MediaSearchExporterCompletion = (previewImage: UIImage?, mediaUrl: NSURL?, error: NSError?)->()
    
    var videoDownloadTask: NSURLSessionDownloadTask?
    
    deinit {
        cleanupTempFile()
    }
    
    private(set) var cancelled: Bool = false
    
    /// For the provided MediaSearchResult, downloads its video asset to disk and loads a preview image
    /// needed for subsequent steps in the publish flow.
    ///
    /// - parameter mediaSearchResult: The MediaSearchResult whose assets will be loaded/downloaded.
    /// Calling code should be responsible for deleting the file at the mediaUrl's path.
    /// - parameter completion: A completion closure called when all opeartions are complete
    func loadMedia( completion: MediaSearchExporterCompletion ) {
        
        cleanupTempFile()
        
        guard let previewImageURL = mediaSearchResult.thumbnailImageURL,
            searchResultURL = mediaSearchResult.sourceMediaURL else {
                completion(previewImage: nil,
                    mediaUrl: nil,
                    error: NSError(domain: "MediaSearchExporter", code: -1, userInfo: nil))
                return
        }
        
        videoDownloadTask = NSURLSession.sharedSession().downloadTaskWithRequest(NSURLRequest(URL: searchResultURL)) { (location: NSURL?, response: NSURLResponse?, error: NSError?) in
            
            guard let location = location, let downloadUrl = self.downloadUrl else {
                dispatch_async(dispatch_get_main_queue()) {
                    completion(previewImage: nil, mediaUrl: nil, error: error)
                }
                return
            }
            
            do {
                try NSFileManager.defaultManager().moveItemAtURL(location, toURL: downloadUrl)
            } catch {
                // Remove temp file
                let _ = try? NSFileManager.defaultManager().removeItemAtURL(location)
                
                dispatch_async(dispatch_get_main_queue()) {
                    completion(previewImage: nil, mediaUrl: nil, error: error as NSError)
                }
                return
            }
            
            let previewImage: UIImage? = {
                
                if let response = response,
                    let mimeType = response.MIMEType where mimeType.hasPrefix("image/") {
                        if let data = NSData(contentsOfURL: downloadUrl) {
                            return UIImage(data: data)
                        }
                }
                
                if let previewImageData = try? NSData(contentsOfURL: previewImageURL, options: []) {
                    return UIImage(data: previewImageData)
                }
                return nil
            }()
            
            // Dispatch back to main thread for completion
            dispatch_async( dispatch_get_main_queue() ) {
                completion(
                    previewImage: previewImage,
                    mediaUrl: downloadUrl,
                    error: nil
                )
            }
        }
        videoDownloadTask?.resume()
    }
    
    func cancelDownload() {
        cleanupTempFile()
        cancelled = true
        videoDownloadTask?.cancel()
    }
    
    func cleanupTempFile() {
        guard let downloadURL = downloadUrl else {
            return
        }
        let _ = try? NSFileManager.defaultManager().removeItemAtURL(downloadURL)
    }
    
    lazy var downloadUrl: NSURL? = { [weak self] in
        guard let cacheDirectoryPath = NSSearchPathForDirectoriesInDomains( NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true ).first,
            let mediaSearchResult: MediaSearchResult = self?.mediaSearchResult else {
                let failureMessage = "Unable to find file path for temporary media download. Media search result -> \(self?.mediaSearchResult)"
                assertionFailure(failureMessage)
                Log.error(failureMessage)
                return nil
        }
        
        let cacheDirectoryURL = NSURL(fileURLWithPath: cacheDirectoryPath)
        guard let subdirectory = cacheDirectoryURL.URLByAppendingPathComponent("com.getvictorious.gifSearch") else {
            return nil
        }
        
        var isDirectory: ObjCBool = false
        if !NSFileManager.defaultManager().fileExistsAtPath(subdirectory.path!, isDirectory: &isDirectory ) || !isDirectory {
            let _ = try? NSFileManager.defaultManager().createDirectoryAtPath(subdirectory.path!, withIntermediateDirectories: true, attributes: nil)
        }
        
        // Create a unique URL. May cause issues if GIF has a bad extension.
        let fileExtension = mediaSearchResult.sourceMediaURL?.pathExtension == nil ? "" : ".\((mediaSearchResult.sourceMediaURL?.pathExtension)!)"
        return subdirectory.URLByAppendingPathComponent("\(self!.uuidString)\(fileExtension)")
    }()
}
