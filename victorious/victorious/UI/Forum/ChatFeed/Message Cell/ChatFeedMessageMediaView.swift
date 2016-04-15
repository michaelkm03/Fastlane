//
//  ChatFeedMessageMediaView.swift
//  victorious
//
//  Created by Patrick Lynch on 3/7/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class ChatFeedMessageMediaView: UIView, VFocusable {
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var videoView: VVideoView!
    
    var preloadedImage: UIImage? {
        return imageView.image
    }
    
    var previewURL: NSURL! {
        didSet {
            imageView.alpha = 0.0
            imageView.sd_setImageWithURL(previewURL) { image, error, cacheType, url in
                if cacheType == .None {
                    UIView.animateWithDuration(0.2) {
                        self.imageView.alpha = 1.0
                    }
                } else {
                    self.imageView.alpha = 1.0
                }
            }
        }
    }
    
    var mediaURL: NSURL? {
        didSet {
            if mediaURL == oldValue {
                return
                
            } else if let mediaURL = mediaURL {
                let videoPlayerItem = VVideoPlayerItem(URL: mediaURL)
                videoPlayerItem.loop = true
                videoPlayerItem.muted = true
                videoPlayer.setItem( videoPlayerItem )
                videoPlayer.view.hidden = false
                updateFocus()
                
            } else {
                videoPlayer.reset()
                videoPlayer.view.hidden = true
            }
        }
    }
    
    private func updateFocus() {
        switch focusType {
        case .None:
            videoPlayer.pause()
        default:
            videoPlayer.play()
        }
    }
    
    // MARK: - UIView
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imageView.frame = bounds
        videoView.frame = bounds
    }
    
    // MARK: - VFocusable
    
    var focusType: VFocusType = .None {
        didSet {
            updateFocus()
        }
    }
    
    func contentArea() -> CGRect {
        return videoView.frame
    }
    
    // MARK: - Private
    
    private var videoPlayer: VVideoPlayer {
        return videoView as VVideoPlayer
    }
}
