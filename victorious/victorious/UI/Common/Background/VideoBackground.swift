//
//  VideoBackground.swift
//  victorious
//
//  Created by Jarod Long on 8/8/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class VideoBackground: VBackground, VVideoPlayerDelegate {
    // MARK: - Initializing
    
    required init(dependencyManager: VDependencyManager) {
        super.init(dependencyManager: dependencyManager)
        videoView.backgroundColor = .blackColor()
        videoView.delegate = self
        fetchVideo(from: dependencyManager)
    }
    
    // MARK: - Fetching the video
    
    fileprivate func fetchVideo(from dependencyManager: VDependencyManager) {
        guard let sequenceURL = dependencyManager.sequenceURL else {
            return
        }
        
        RequestOperation(request: VideoBackgroundFetchRequest(sequenceURL: sequenceURL)).queue { [weak self] result in
            guard let item = result.output else {
                return
            }
            
            item.muted = true
            item.loop = true
            self?.videoView.setItem(item)
        }
    }
    
    // MARK: - Views
    
    /// The view that displays background video.
    fileprivate let videoView = VVideoView()
    
    // MARK: - VBackground
    
    override func viewForBackground() -> UIView! {
        return videoView
    }
    
    // MARK: - VVideoPlayerDelegate
    
    func videoPlayerDidBecomeReady(_ videoPlayer: VVideoPlayer) {
        videoView.playFromStart()
    }
}

// The following is a legacy request, converted from the old sequence fetch operation, since we use legacy
// sequence endpoints for video backgrounds. This should eventually be refactored and removed.

private struct VideoBackgroundFetchRequest: RequestType {
    let urlRequest: URLRequest
    
    init(sequenceURL: URL) {
        self.urlRequest = URLRequest(url: sequenceURL)
    }
    
    func parseResponse(_ response: NSURLResponse, toRequest request: NSURLRequest, responseData: NSData, responseJSON: JSON) throws -> VVideoPlayerItem {
        guard let payload = responseJSON["payload"].arrayValue.first, let url = url(from: payload) else {
            throw ResponseParsingError()
        }
        
        return VVideoPlayerItem(URL: url)
    }
    
    func url(from payload: JSON) -> URL? {
        for nodeJSON in payload["nodes"].arrayValue {
            for assetJSON in nodeJSON["assets"].arrayValue {
                guard let url = assetJSON["data"].URL , url.pathExtension == "m3u8" else {
                    continue
                }
                
                return url
            }
        }
        
        return nil
    }
}

private extension VDependencyManager {
    var sequenceURL: NSURL? {
        guard let urlString = stringForKey("sequenceURL") else {
            return nil
        }
        
        return NSURL(string: urlString)
    }
}
