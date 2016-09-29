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
    
    @IBOutlet fileprivate weak var emptyView: UIView!
    @IBOutlet fileprivate weak var imageView: UIImageView!
    @IBOutlet fileprivate weak var overlayView: UIView!
    
    /// Sets the image asset URL to show in this cell
    var assetUrl: URL? {
        didSet {
            if let url = self.assetUrl, self.assetUrl != oldValue {
                loadImage(url)
            }
        }
    }
    
    fileprivate func loadImage(_ url: URL) {
        self.imageView.alpha = 0.0
        self.imageView.sd_setImage(with: url, completed: { image, error, cacheType, url in
            if cacheType == .none {
                UIView.animate(withDuration: 0.2) {
                    self.imageView.alpha = 1.0
                }
            }
            else {
                self.imageView.alpha = 1.0
            }
        })
    }
    
    override var isSelected: Bool {
        didSet {
            self.overlayView.alpha = self.isSelected ? 0.5 : 0.0
            self.overlayView.backgroundColor = self.isSelected ? self.tintColor : UIColor.clear
        }
    }
}
