//
//  MediaSearchPreviewCell.swift
//  victorious
//
//  Created by Patrick Lynch on 7/13/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import SDWebImage
import UIKit

/// The full size cell that plays the GIF video asset when an item is selected
/// from the list of GIF search results
class MediaSearchPreviewCell: UICollectionViewCell {
    
    static let associatedNib = UINib(nibName: "MediaSearchPreviewCell", bundle: nil)
    
    var videoPlayer: VVideoPlayer?
    
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
            self.videoPlayer?.view.removeFromSuperview()
            self.videoPlayer = nil
            self.videoPlayer = VVideoView(frame: self.bounds)
            if let url = self.assetUrl, let videoPlayer = self.videoPlayer {
                
                self.addSubview( videoPlayer.view )
                self.v_addFitToParentConstraintsToSubview( videoPlayer.view )
                
                let videoPlayerItem = VVideoPlayerItem(URL: url)
                videoPlayerItem.loop = true
                videoPlayerItem.muted = true
                videoPlayerItem.useAspectFit = true
                videoPlayer.setItem( videoPlayerItem )
                videoPlayer.playFromStart()
            }
        }
    }
}
