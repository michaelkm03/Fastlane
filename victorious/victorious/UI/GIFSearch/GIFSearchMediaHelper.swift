//
//  GIFSearchMediaHelper.swift
//  victorious
//
//  Created by Patrick Lynch on 7/13/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

/// Helper that handles loading preview image and streaming GIF asset
/// to a file using asynchronous operations
struct GIFSearchMediaHelper {
    
    private let operationQueue = NSOperationQueue()
    
    /// Completion closure to be called when all operations are complete
    /// parameter `previewImage`: A UIImage loaded with a still thumbnail asset
    /// parameter `mediaUrl`: The URL on disk of the downloaded media file
    /// parameter `error`: An NSError instance defined if there was en error, otherwise `nil`
    typealias GIFSearchMediaHelperCompletion = (previewImage: UIImage?, mediaUrl: NSURL?, error: NSError?)->()
    
    /// For the provided GIFSearchResult, downlods its video asset to disk and loads a preview image
    /// needed for subsequent steps in the publish flow
    /// parameter `gifSearchResult`: The GIFSearchResult whose assets will be loaded/downloaded
    /// parameter `completion`: A completion closure called wehn all opeartions are complete
    func loadMedia( gifSearchResult: GIFSearchResult, completion: GIFSearchMediaHelperCompletion ) {
        
        let downloadPath = self.downloadPathForRemotePath( gifSearchResult.mp4Url )
        if let previewImageURL = NSURL(string: gifSearchResult.thumbnailStillUrl),
            let videoURL = NSURL(string: gifSearchResult.mp4Url ),
            let videoOutputStream = NSOutputStream(toFileAtPath: downloadPath, append: false ) {
                
                let imageOperation = LoadImageOperation(remoteURL: previewImageURL)
                let videoOperation = AFURLConnectionOperation(request: NSURLRequest(URL: videoURL))
                videoOperation.completionBlock = {
                    dispatch_async(dispatch_get_main_queue()) {
                        completion(
                            previewImage: imageOperation.image,
                            mediaUrl: NSURL(fileURLWithPath: downloadPath),
                            error: nil
                        )
                    }
                }
                videoOperation.outputStream = videoOutputStream
                videoOperation.addDependency( imageOperation )
                self.operationQueue.addOperation( imageOperation )
                self.operationQueue.addOperation( videoOperation )
        }
    }
    
    private func downloadPathForRemotePath( remotePath: String ) -> String {
        
        let filename = remotePath.lastPathComponent
        let paths = NSSearchPathForDirectoriesInDomains( NSSearchPathDirectory.CachesDirectory, NSSearchPathDomainMask.UserDomainMask, true )
        if var path = paths.first as? String {
            path = path.stringByAppendingPathComponent( "com.getvictorious.gifSearch" )
            
            var isDirectory: ObjCBool = false
            if !NSFileManager.defaultManager().fileExistsAtPath( path, isDirectory: &isDirectory ) || isDirectory {
                NSFileManager.defaultManager().createDirectoryAtPath( path, withIntermediateDirectories: true, attributes: nil, error: nil)
            }
            
            path = path.stringByAppendingPathComponent( filename )
            return path
        }
        fatalError( "Unable to find file path for temporary media download." )
    }
}
