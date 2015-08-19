//
//  GIFSearchPreviewCell.swift
//  victorious
//
//  Created by Patrick Lynch on 7/13/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import SDWebImage
import UIKit

/// The full size cell that plays the GIF video asset when an item is selected
/// from the list of GIF search results
class GIFSearchPreviewCell: UICollectionViewCell {
    
    static let ReuseIdentifier = "GIFSearchPreviewCell"
    
    var videoView: VVideoView?
    
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet private weak var imageView: UIImageView!
    
    var previewAssetUrl: NSURL? {
        didSet {
            self.imageView.sd_setImageWithURL( self.previewAssetUrl )
        }
    }
    
    /// Sets the video asset URL to play in this cell and automatically beings playing it.
    var assetUrl: NSURL? {
        didSet {
            self.videoView?.removeFromSuperview()
            self.videoView = nil
            if let url = self.assetUrl {
                let videoView = VVideoView(frame: self.bounds)
                self.videoView = videoView
                self.addSubview( videoView )
                self.v_addFitToParentConstraintsToSubview(videoView)
                videoView.useAspectFit = true
                videoView.setItemURL(url, loop: true, audioMuted: true)
                videoView.playFromStart()
            }
        }
    }
    
    /// Animates in the asset and removes activity indicator
    func transitionIn() {
        UIView.animateWithDuration( 0.3, animations: {
            self.activityIndicator.hidden = true
            self.videoView?.hidden = false
        }, completion: nil );
    }
}

extension GIFSearchPreviewCell : VVideoViewDelegate {
    
    func videoViewPlayerDidBecomeReady(videoView: VVideoView) {
        self.transitionIn()
    }
}