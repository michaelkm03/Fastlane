//
//  GIFSearchMediaExporter.swift
//  victorious
//
//  Created by Patrick Lynch on 7/13/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

/// Helper that handles loading preview image and streaming GIF asset
/// to a file using asynchronous operations.
struct GIFSearchMediaExporter {
    
    private let operationQueue = NSOperationQueue()
    
    /// Completion closure to be called when all operations are complete.
    ///
    /// - parameter previewImage: A UIImage loaded with a still thumbnail asset
    /// - parameter mediaUrl: The URL on disk of the downloaded media file
    /// - parameter error: An NSError instance defined if there was en error, otherwise `nil`
    typealias GIFSearchMediaExporterCompletion = (previewImage: UIImage?, mediaUrl: NSURL?, error: NSError?)->()
    
    /// For the provided GIFSearchResult, downlods its video asset to disk and loads a preview image
    /// needed for subsequent steps in the publish flow.
    ///
    /// - parameter gifSearchResult: The GIFSearchResult whose assets will be loaded/downloaded
    /// - parameter completion: A completion closure called wehn all opeartions are complete
    func loadMedia( gifSearchResult: GIFSearchResult, completion: GIFSearchMediaExporterCompletion ) {
        
        if let searchResultURL = NSURL(string: gifSearchResult.mp4URL) {
            let downloadURL = self.downloadURLForRemoteURL( searchResultURL )
            if let previewImageURL = NSURL(string: gifSearchResult.thumbnailStillURL),
                let videoURL = NSURL(string: gifSearchResult.mp4URL),
                let videoOutputStream = NSOutputStream( URL: downloadURL, append: false ) {
                    
                    let videoOperation = AFURLConnectionOperation(request: NSURLRequest(URL: videoURL))
                    videoOperation.completionBlock = {
                        
                        // Load the image synchronously before we leave this thread
                        let previewImage: UIImage? = {
                            if let previewImageData = try? NSData(contentsOfURL: previewImageURL, options: []) {
                                return UIImage(data: previewImageData)
                            }
                            return nil
                        }()
                        
                        // Dispatch back to main thread for completion
                        dispatch_async( dispatch_get_main_queue() ) {
                            completion(
                                previewImage: previewImage,
                                mediaUrl: downloadURL,
                                error: nil
                            )
                        }
                    }
                    videoOperation.outputStream = videoOutputStream
                    self.operationQueue.addOperation( videoOperation )
            }
        }
    }
    
    private func downloadURLForRemoteURL( remoteURL: NSURL ) -> NSURL {
        
        if let filename = remoteURL.lastPathComponent,
           let uniqueID = remoteURL.URLByDeletingLastPathComponent?.lastPathComponent,
           let cacheDirectoryPath = NSSearchPathForDirectoriesInDomains( NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true ).first {
            
            let cacheDirectoryURL = NSURL(fileURLWithPath: cacheDirectoryPath)
            let subdirectory = cacheDirectoryURL.URLByAppendingPathComponent( "com.getvictorious.gifSearch" )
            
            var isDirectory: ObjCBool = false
            if !NSFileManager.defaultManager().fileExistsAtPath( subdirectory.path!, isDirectory: &isDirectory ) || !isDirectory {
                let _ = try? NSFileManager.defaultManager().createDirectoryAtPath( subdirectory.path!, withIntermediateDirectories: true, attributes: nil)
            }
            
            // Create a unique URL for the gif
            return subdirectory.URLByAppendingPathComponent( "\(uniqueID)-\(filename)" )
        }
        fatalError( "Unable to find file path for temporary media download." )
    }
}
