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
    
    private let operationQueue = NSOperationQueue()
    private let mediaSearchResult: MediaSearchResult
    
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
    /// - parameter completion: A completion closure called wehn all opeartions are complete
    func loadMedia( completion: MediaSearchExporterCompletion ) {
        
        cleanupTempFile()
        
        guard let searchResultURL = mediaSearchResult.sourceMediaURL else {
            return
        }
        let downloadURL = self.downloadURLForRemoteURL( searchResultURL )
        
        guard let previewImageURL = mediaSearchResult.thumbnailImageURL,
            let videoURL = mediaSearchResult.sourceMediaURL else {
                return
        }
        
        videoDownloadTask = NSURLSession.sharedSession().downloadTaskWithRequest(NSURLRequest(URL: videoURL)) { (location: NSURL?, response: NSURLResponse?, error: NSError?) in
            
            guard let location = location else {
                dispatch_async(dispatch_get_main_queue()) {
                    completion(previewImage: nil, mediaUrl: nil, error: error)
                }
                return
            }
            
            let previewImage: UIImage? = {
                if let previewImageData = try? NSData(contentsOfURL: previewImageURL, options: []) {
                    return UIImage(data: previewImageData)
                }
                return nil
            }()
            
            // We shouldn't have to, but sometimes files are not removed from the filesystem and the 
            // move would fail if there is a file at downloadURL's path.
            let _ = try? NSFileManager.defaultManager().removeItemAtURL(downloadURL)
            
            do {
                try NSFileManager.defaultManager().moveItemAtURL(location, toURL: downloadURL)
            } catch {
                dispatch_async(dispatch_get_main_queue()) {
                    completion(previewImage: nil, mediaUrl: nil, error: error as NSError)
                }
                return
            }
            
            // Dispatch back to main thread for completion
            dispatch_async( dispatch_get_main_queue() ) {
                completion(
                    previewImage: previewImage,
                    mediaUrl: downloadURL,
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
        guard let searchResultURL = mediaSearchResult.sourceMediaURL else {
            return
        }
        let downloadURL = self.downloadURLForRemoteURL(searchResultURL)
        do {
            try NSFileManager.defaultManager().removeItemAtURL(downloadURL)
        } catch {
            
        }
    }
    
    private func downloadURLForRemoteURL( remoteURL: NSURL ) -> NSURL {
        if let cacheDirectoryPath = NSSearchPathForDirectoriesInDomains( NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true ).first {
            
            let cacheDirectoryURL = NSURL(fileURLWithPath: cacheDirectoryPath)
            let subdirectory = cacheDirectoryURL.URLByAppendingPathComponent( "com.getvictorious.gifSearch" )
            
            var isDirectory: ObjCBool = false
            if !NSFileManager.defaultManager().fileExistsAtPath( subdirectory.path!, isDirectory: &isDirectory ) || !isDirectory {
                let _ = try? NSFileManager.defaultManager().createDirectoryAtPath( subdirectory.path!, withIntermediateDirectories: true, attributes: nil)
            }
            let fileName = NSUUID().UUIDString
            // Create a unique URL for the gif
            return subdirectory.URLByAppendingPathComponent(fileName)
        }
        fatalError( "Unable to find file path for temporary media download." )
    }
}
