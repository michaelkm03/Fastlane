//
//  GIFSearchResultCell.swift
//  victorious
//
//  Created by Patrick Lynch on 7/9/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

extension UICollectionViewCell {
    
    static var suggestedReuseIdentifier: String {
        return NSStringFromClass(self).pathExtension
    }
}

/// Cell to represent GIF search result in a collectin of search results
class GIFSearchResultCell: UICollectionViewCell {
    
    @IBOutlet private weak var imageView: UIImageView!
    
    var assetUrl: NSURL? {
        didSet {
            if let url = self.assetUrl {
                let shouldAnimate = self.assetUrl != oldValue
                self.imageView.hidden = shouldAnimate ? true : false
                self.imageView.sd_setImageWithURL( url, completed: { (image, error, cacheType, url) in
                    UIView.animateWithDuration( shouldAnimate ? 0.5 : 0.0, animations: {
                        self.imageView.hidden = false
                    })
                })
            }
        }
    }
    
    override var selected: Bool {
        didSet {
            self.imageView.alpha = self.selected ? 0.5 : 1.0
            self.backgroundColor = self.selected ? self.tintColor : UIColor.clearColor()
        }
    }
}