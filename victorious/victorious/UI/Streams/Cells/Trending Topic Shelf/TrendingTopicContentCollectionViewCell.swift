//
//  VTrendingTopicContentCollectionViewCell.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 8/20/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit
import SDWebImage

class TrendingTopicContentCollectionViewCell: VBaseCollectionViewCell {
    
    private struct Constants {
        static let labelInsets = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5)
        static let blurCacheString = "_blurred"
    }
    
    //Warning: NOT DONE HERE
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
            self.label.text = VHashTags.stringWithPrependedHashmarkFromString(streamItem?.name) ?? ""
            if let previewImageURL = (streamItem?.previewImagesObject as? String),
                url = NSURL(string: previewImageURL)  {
                    
                // Download preview image
                updateImageView(url: url)
            }
            else if let stream = streamItem as? VStream,
                     let item = stream.streamItems.array.first as? VStreamItem {
                        if let previewUrlString = item.previewImagesObject as? String,
                            let url = NSURL(string: previewUrlString) {
                                
                                updateImageView(url: url)
                        } else if item.itemSubType == VStreamItemSubTypeText {

                        }
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
    
    required init?(coder aDecoder: NSCoder) {
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
        
        screenView.backgroundColor = UIColor.blackColor().colorWithAlphaComponent(0.2)
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
        
        updateToInitialState()
    }
    
    private func updateImageView(url url: NSURL) {
        imageView.sd_setImageWithURL(url, placeholderImage: nil, completed: { [weak self] (image, error, cacheType, url) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if let strongSelf = self {
                    strongSelf.updateWithImage(image, url: url, animated: cacheType != .Memory)
                }
            })
        })
    }
    
    private func updateWithImage(image: UIImage?, url: NSURL?, animated: Bool) {
        if let image = image, url = url {
            
            if let color = image.dominantColors().first {
                self.gradient.primaryColor = color
            }
            
            let finish = { (blurredImage: UIImage) -> Void in
                self.blurredImageView.image = blurredImage
                self.blurredImageView.layer.mask = self.blurMask.layer
                self.updateToReadyState(animated)
            }
            
            let cacheIdentifier = url.absoluteString.stringByAppendingString(Constants.blurCacheString)
            
            if let cachedImage = SDWebImageManager.sharedManager().imageCache.imageFromMemoryCacheForKey(cacheIdentifier) {
                finish(cachedImage)
            }
            
            // Blur the preview image
            self.blurredImageView.blurImage(image, withTintColor: nil, toCallbackBlock: { (img) -> Void in
                SDWebImageManager.sharedManager().imageCache.storeImage(img, forKey: cacheIdentifier)
                finish(img)
            })
        }
    }
    
    private func updateToInitialState() {
        screenView.alpha = 0
        blurredImageView.alpha = 0
        gradient.alpha = 0
        blurMask.alpha = 0
    }
    
    private func updateToReadyState(animated: Bool) {
        self.screenView.alpha = 1
        self.blurredImageView.alpha = 1
        self.gradient.alpha = 1
        self.blurMask.alpha = 1
    }
    
    override func prepareForReuse() {
        updateToInitialState()
    }
    
    class func reuseIdentifier() -> String {
        return NSStringFromClass(TrendingTopicContentCollectionViewCell.self)
    }
}

extension TrendingTopicContentCollectionViewCell: VBackgroundContainer {
    
    func loadingBackgroundContainerView() -> UIView {
        return contentView
    }
}

private extension VDependencyManager {
    
    var labelFont: UIFont {
        return fontForKey(VDependencyManagerLabel2FontKey)
    }
}
