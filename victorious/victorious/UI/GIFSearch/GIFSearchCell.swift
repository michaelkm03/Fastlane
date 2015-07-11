//
//  GIFSearchCell.swift
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
class GIFSearchCell: UICollectionViewCell {
    
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

class GIFSearchCellNoContent: UICollectionViewCell {
    
    @IBOutlet private weak var label: UILabel!
    
    var text: String = "" {
        didSet {
            self.label.text = text
        }
    }
    
    func clear() {
        self.text = ""
    }
    
    var loading: Bool = true {
        didSet {
            self.clear()
        }
    }
}

class GIFSearchCellFullsize: UICollectionViewCell {
    
    @IBOutlet private weak var videoView: VVideoView!
    @IBOutlet private weak var activityIndicator: UIActivityIndicatorView!
    
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
    
    func resetTransitionIn() {
        self.videoView.hidden = true
        
        UIView.animateWithDuration(0.3, delay: 0.5, options: nil, animations: {
            self.activityIndicator.hidden = false
        }, completion: nil)
    }
    
    func transitionIn() {
        UIView.animateWithDuration( 0.3, animations: {
            self.activityIndicator.hidden = true
            self.videoView.hidden = false
        }, completion: nil );
    }
}

extension GIFSearchCellFullsize : VVideoViewDelegtae {
    func videoViewPlayerDidBecomeReady(videoView: VVideoView) {
        self.transitionIn()
    }
}