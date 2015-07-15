//
//  GIFSearchPreviewCell.swift
//  victorious
//
//  Created by Patrick Lynch on 7/13/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

/// The full size cell that plays the GIF video asset when an item is selected
/// from the list of GIF search results
class GIFSearchPreviewCell: UICollectionViewCell {
    
    @IBOutlet private weak var videoView: VVideoView!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
    /// Sets the video asset URL to play in this cell and automatically beings playing it.
    var assetUrl: NSURL? {
        didSet {
            if let url = self.assetUrl {
                if self.assetUrl != oldValue {
                    self.videoView.reset()
                    self.videoView.setItemURL(url, loop: true, audioMuted: true)
                    self.resetTransitionIn()
                }
                else {
                    self.activityIndicator.hidden = true
                    self.videoView.hidden = false
                }
                self.videoView.playFromStart()
            }
        }
    }
    
    
    /// Resets the animation state to prepare for another transition
    /// animation with `resetTransitionIn`
    func resetTransitionIn() {
        self.videoView.hidden = true
        
        UIView.animateWithDuration(0.3, delay: 0.5, options: nil, animations: {
            self.activityIndicator.hidden = false
            }, completion: nil)
    }
    
    /// Animates in the asset and removes activity indicator
    func transitionIn() {
        UIView.animateWithDuration( 0.3, animations: {
            self.activityIndicator.hidden = true
            self.videoView.hidden = false
        }, completion: nil );
    }
}

extension GIFSearchPreviewCell : VVideoViewDelegtae {
    
    func videoViewPlayerDidBecomeReady(videoView: VVideoView) {
        self.transitionIn()
    }
}