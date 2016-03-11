//
//  MessageMediaView.swift
//  victorious
//
//  Created by Patrick Lynch on 3/7/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class MessageMediaView: UIView, VFocusable {
    
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var videoView: VVideoView!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imageView.frame = bounds
        videoView.frame = bounds
    }
    
    var preloadedImage: UIImage? {
        return imageView.image
    }
    
    var imageURL: NSURL! {
        didSet {
            imageView.alpha = 0.0
            imageView.sd_setImageWithURL(imageURL) { image, error, cacheType, url in
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
    
    var mediaURL: NSURL! {
        didSet {
            let videoPlayerItem = VVideoPlayerItem(URL: mediaURL)
            videoPlayerItem.loop = true
            videoPlayerItem.muted = true
            videoPlayer.setItem( videoPlayerItem )
            videoPlayer.view.hidden = false
            if focusType != .None {
                videoPlayer.playFromStart()
            }
        }
    }
    
    // MARK: - VFocusable
    
    var focusType: VFocusType = .None {
        didSet {
            switch focusType {
            case .None:
                videoPlayer.pauseAtStart()
            default:
                videoPlayer.playFromStart()
            }
        }
    }
    
    func contentArea() -> CGRect {
        return CGRect.zero
    }
    
    // MARK: - Private
    
    private var videoPlayer: VVideoPlayer {
        return videoView as VVideoPlayer
    }
}
