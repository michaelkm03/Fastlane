//
//  VTrendingTopicContentCollectionViewCell.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 8/20/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit
import SDWebImage

class TrendingTopicContentCollectionViewCell: VBaseCollectionViewCell, VStreamCellComponentSpecialization {
    
    private struct Constants {
        static let labelInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        static let blurCacheString = "_blurred"
    }
    
    private var imageView = UIImageView()
    private var screenView = UIView()
    private var gradient = TrendingTopicGradientView()
    private var label = UILabel()
    private var blurredImageView = UIImageView()
    
    private lazy var blurMask: TrendingTopicGradientView = {
        let blurMask = TrendingTopicGradientView()
        blurMask.primaryColor = UIColor.blackColor()
        blurMask.gradientAlphas = (0, 1, 0)
        return blurMask
    }()
    
    var streamItem: VStreamItem? {
        didSet {
            self.label.text = streamItem?.name ?? ""
            if let previewImageURL = (streamItem?.previewImagesObject as? String),
                url = NSURL(string: previewImageURL)  {
                    
                // Download preview image
                imageView.sd_setImageWithURL(url, placeholderImage: nil, completed: {[weak self] (image, error, cacheType, url) -> Void in
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        if let strongSelf = self {
                            strongSelf.updateWithImage(image, url: url, animated: cacheType != .Memory)
                        }
                    })
                })
            }
        }
    }
    
    /// The dependency manager whose colors and fonts will be used to style this cell.
    var dependencyManager: VDependencyManager? {
        didSet {
            if let dependencyManager = dependencyManager {
                dependencyManager.addLoadingBackgroundToBackgroundHost(self)
                label.font = dependencyManager.labelFont
            }
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    required override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    private func setup() {
        
        imageView.contentMode = UIViewContentMode.ScaleAspectFill
        imageView.clipsToBounds = true
        self.contentView.addSubview(imageView)
        self.contentView.v_addFitToParentConstraintsToSubview(imageView)
        
        self.contentView.addSubview(blurredImageView)
        self.contentView.v_addFitToParentConstraintsToSubview(blurredImageView)
        
        screenView.backgroundColor = UIColor.blackColor().colorWithAlpha(0.2)
        self.contentView.addSubview(screenView)
        self.contentView.v_addFitToParentConstraintsToSubview(screenView)
        
        self.contentView.addSubview(blurMask)
        self.contentView.v_addFitToParentConstraintsToSubview(blurMask)
        
        self.contentView.addSubview(gradient)
        self.contentView.v_addFitToParentConstraintsToSubview(gradient)
        
        label.textColor = UIColor.whiteColor()
        label.textAlignment = .Center
        self.contentView.addSubview(label)
        self.contentView.v_addPinToLeadingTrailingToSubview(label, leading: Constants.labelInsets.left, trailing: Constants.labelInsets.right)
        self.contentView.v_addPintoTopBottomToSubview(label, top: 0, bottom: 0)
        
        initialState()
    }
    
    func updateWithImage(image: UIImage?, url: NSURL?, animated: Bool) {
        if let image = image, url = url {
            
            if let color = image.dominantColors().first {
                self.gradient.primaryColor =  color
            }
            
            var finish = { (blurredImage: UIImage) -> Void in
                self.blurredImageView.image = blurredImage
                self.blurredImageView.layer.mask = self.blurMask.layer
                self.readyState(animated)
            }
            
            let cacheIdentifier: String? = url.absoluteString?.stringByAppendingString(Constants.blurCacheString)
            
            if let cacheIdentifier = cacheIdentifier, cachedImage = SDWebImageManager.sharedManager().imageCache.imageFromMemoryCacheForKey(cacheIdentifier) {
                finish(cachedImage)
            }
            
            // Blur the preview image
            self.blurredImageView.blurImage(image, withTintColor: nil, toCallbackBlock: { (img) -> Void in
                if let cacheIdentifier = cacheIdentifier {
                    SDWebImageManager.sharedManager().imageCache.storeImage(img, forKey: cacheIdentifier)
                }
                finish(img)
            })
        }
    }
    
    private func initialState() {
        imageView.alpha = 0
        blurredImageView.alpha = 0
        gradient.alpha = 0
        blurMask.alpha = 0
        imageView.image = nil
    }
    
    private func readyState(animated: Bool) {
        UIView.animateWithDuration(animated ? 0.1 : 0, animations: { () -> Void in
            self.imageView.alpha = 1
            self.blurredImageView.alpha = 1
            self.gradient.alpha = 1
            self.blurMask.alpha = 1
        })
    }
    
    override func prepareForReuse() {
        imageView.cancelImageRequestOperation()
        initialState()
    }
}

extension TrendingTopicContentCollectionViewCell: VBackgroundContainer {
    
    func loadingBackgroundContainerView() -> UIView! {
        return contentView
    }
}

private extension VDependencyManager {
    
    var labelFont: UIFont {
        return fontForKey(VDependencyManagerLabel2FontKey)
    }
}

extension TrendingTopicContentCollectionViewCell: VStreamCellComponentSpecialization {
    
    class func reuseIdentifierForStreamItem(streamItem: VStreamItem, baseIdentifier: String?, dependencyManager: VDependencyManager?) -> String {
        return NSStringFromClass(self)
    }
}

