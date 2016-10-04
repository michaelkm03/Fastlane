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
    
    fileprivate let mediaSearchResult: MediaSearchResult
    fileprivate let uuidString = UUID().uuidString
    
    /// - parameter mediaSearchResult: The MediaSearchResult whose assets will be loaded/
    init(mediaSearchResult: MediaSearchResult) {
        self.mediaSearchResult = mediaSearchResult
    }
    
    /// Completion closure to be called when all operations are complete.
    ///
    /// - parameter previewImage: A UIImage loaded with a still thumbnail asset
    /// - parameter mediaUrl: The URL on disk of the downloaded media file
    /// - parameter error: An NSError instance defined if there was en error, otherwise `nil`
    typealias MediaSearchExporterCompletion = (_ previewImage: UIImage?, _ mediaUrl: URL?, _ error: NSError?)->()
    
    var videoDownloadTask: URLSessionDownloadTask?
    
    deinit {
        cleanupTempFile()
    }
    
    fileprivate(set) var cancelled: Bool = false
    
    /// For the provided MediaSearchResult, downloads its video asset to disk and loads a preview image
    /// needed for subsequent steps in the publish flow.
    ///
    /// - parameter mediaSearchResult: The MediaSearchResult whose assets will be loaded/downloaded.
    /// Calling code should be responsible for deleting the file at the mediaUrl's path.
    /// - parameter completion: A completion closure called when all opeartions are complete
    func loadMedia(_ completion: @escaping MediaSearchExporterCompletion) {
        
        cleanupTempFile()
        
        guard
            let previewImageURL = mediaSearchResult.thumbnailImageURL,
            let searchResultURL = mediaSearchResult.sourceMediaURL
        else {
            completion(nil, nil, NSError(domain: "MediaSearchExporter", code: -1, userInfo: nil))
            return
        }
        videoDownloadTask = URLSession.shared.downloadTask(with: URLRequest(url: searchResultURL as URL)) { location, response, error in
            guard let location = location, let downloadUrl = self.downloadUrl else {
                DispatchQueue.main.async {
                    completion(nil, nil, error as NSError?)
                }
                return
            }
            
            do {
                try FileManager.default.moveItem(at: location, to: downloadUrl)
            } catch {
                // Remove temp file
                let _ = try? FileManager.default.removeItem(at: location)
                
                DispatchQueue.main.async {
                    completion(nil, nil, error as NSError)
                }
                return
            }
            
            let previewImage: UIImage? = {
                if
                    let response = response,
                    let mimeType = response.mimeType,
                    mimeType.hasPrefix("image/"),
                    let data = try? Data(contentsOf: downloadUrl)
                {
                    return UIImage(data: data)
                }
                
                if let previewImageData = try? Data(contentsOf: previewImageURL, options: []) {
                    return UIImage(data: previewImageData)
                }
                return nil
            }()
            
            // Dispatch back to main thread for completion
            DispatchQueue.main.async {
                completion(previewImage, downloadUrl, nil)
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
        let _ = try? FileManager.default.removeItem(at: downloadURL)
    }
    
    lazy var downloadUrl: URL? = { [weak self] in
        guard
            let cacheDirectoryPath = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.cachesDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first,
            let mediaSearchResult: MediaSearchResult = self?.mediaSearchResult
        else {
            let failureMessage = "Unable to find file path for temporary media download. Media search result -> \(self?.mediaSearchResult)"
            assertionFailure(failureMessage)
            Log.error(failureMessage)
            return nil
        }
        
        let cacheDirectoryURL = URL(fileURLWithPath: cacheDirectoryPath)
        let subdirectory = cacheDirectoryURL.appendingPathComponent("com.getvictorious.gifSearch")
        
        var isDirectory: ObjCBool = false
        if !FileManager.default.fileExists(atPath: subdirectory.path, isDirectory: &isDirectory) || !isDirectory.boolValue {
            let _ = try? FileManager.default.createDirectory(atPath: subdirectory.path, withIntermediateDirectories: true, attributes: nil)
        }
        
        // Create a unique URL. May cause issues if GIF has a bad extension.
        let fileExtension = mediaSearchResult.sourceMediaURL?.pathExtension == nil ? "" : ".\((mediaSearchResult.sourceMediaURL?.pathExtension)!)"
        return subdirectory.appendingPathComponent("\(self!.uuidString)\(fileExtension)")
    }()
}
