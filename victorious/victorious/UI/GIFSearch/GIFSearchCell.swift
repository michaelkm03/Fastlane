//
//  GIFSearchCell.swift
//  victorious
//
//  Created by Patrick Lynch on 7/9/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

/// Cell to represent GIF search result in a collectin of search results
class GIFSearchCell: UICollectionViewCell {
    
    @IBOutlet private weak var imageView: UIImageView!
    
    static var suggestedReuseIdentifier: String {
        return NSStringFromClass(self).pathExtension
    }
    
    var assetUrl: NSURL? {
        didSet {
            if let url = self.assetUrl {
                self.imageView.alpha = self.imageView.image == nil ? 0.0 : 1.0
                self.imageView.sd_setImageWithURL( url, completed: { (image, error, cacheType, url) -> Void in
                    UIView.animateWithDuration( 0.5, animations: {
                        self.imageView.alpha = 1.0
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

class GIFSearchCellFullsize: GIFSearchCell {
    
}