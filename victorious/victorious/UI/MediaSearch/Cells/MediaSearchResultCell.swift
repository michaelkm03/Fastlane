//
//  MediaSearchResultCell.swift
//  victorious
//
//  Created by Patrick Lynch on 7/9/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

/// Cell to represent GIF search result in a collectin of search results
class MediaSearchResultCell: UICollectionViewCell {
    
    @IBOutlet private weak var emptyView: UIView!
    @IBOutlet private weak var imageView: UIImageView!
    @IBOutlet private weak var overlayView: UIView!
    
    /// Sets the image asset URL to show in this cell
    var assetUrl: NSURL? {
        didSet {
            if let url = self.assetUrl where self.assetUrl != oldValue {
                self.loadImage( url )
            }
        }
    }
    
    private func loadImage( url: NSURL ) {
        self.imageView.alpha = 0.0
        self.imageView.sd_setImageWithURL( url, completed: { (image, error, cacheType, url) in
            if cacheType == .None {
                UIView.animateWithDuration(0.2) {
                    self.imageView.alpha = 1.0
                }
            }
            else {
                self.imageView.alpha = 1.0
            }
        })
    }
    
    override var selected: Bool {
        didSet {
            self.overlayView.alpha = self.selected ? 0.5 : 0.0
            self.overlayView.backgroundColor = self.selected ? self.tintColor : UIColor.clearColor()
        }
    }
}
