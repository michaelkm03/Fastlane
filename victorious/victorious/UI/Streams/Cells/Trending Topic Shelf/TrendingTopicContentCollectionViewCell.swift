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
        static let desiredSize = CGSizeMake(90, 90)
    }
    
    private var imageView = UIImageView()
    private var screenView = UIView()
    private var gradient = TrendingTopicGradientView()
    private var label = UILabel()
    private var blurredImageView = UIImageView()
    
    // A cache to check for the dominant color in the preview image
    var colorCache: NSCache?
    var renderedTextPostCache: NSCache?
    
    private lazy var blurMask: TrendingTopicGradientView = {
        let blurMask = TrendingTopicGradientView()
        blurMask.primaryColor = UIColor.blackColor()
        blurMask.gradientAlphas = (0, 1, 0)
        return blurMask
    }()
    
    var streamItem: VStreamItem? {
        didSet {
            self.label.text = VHashTags.stringWithPrependedHashmarkFromString(streamItem?.name) ?? ""
            guard let item = streamItemForDisplay else {
                return;
            }
            if let previewImageURL = (item.previewImagesObject as? String),
                let url = NSURL(string: previewImageURL)  {
                    // Download preview image
                    updateImageView(url: url)
            }
            else if item.itemSubType == VStreamItemSubTypeText {
                updateTextPreviewView()
            }
        }
    }
    
    private var streamItemForDisplay: VStreamItem? {
        if let previewImageURL = (streamItem?.previewImagesObject as? String) {
                if previewImageURL != "" {
                    return streamItem
                }
        }
        else if let stream = streamItem as? VStream,
                 let item = stream.streamItems.array.first as? VStreamItem {
                    return item
        }
        return nil
    }
    
    /// The dependency manager whose colors and fonts will be used to style this cell.
    var dependencyManager: VDependencyManager? {
        didSet {
            if let dependencyManager = dependencyManager {
                dependencyManager.addLoadingBackgroundToBackgroundHost(self)
                label.font = dependencyManager.labelFont
                if streamItemForDisplay?.itemSubType == VStreamItemSubTypeText {
                    updateTextPreviewView()
                }
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
    
    private func updateTextPreviewView()
    {
        guard let streamItem = streamItemForDisplay,
            let dependencyManager = dependencyManager else {
                return
        }
        
        if let cachedImage = renderedTextPostCache?.objectForKey(streamItem.remoteId) as? UIImage {
            imageView.image = cachedImage
            updateWithImage(cachedImage, cacheKey: streamItem.remoteId, animated: false)
        }
        else {
            // Need to render the text post anew
            let textPostPreviewView = VTextSequencePreviewView()
            textPostPreviewView.displaySize = TrendingTopicContentCollectionViewCell.desiredSize()
            textPostPreviewView.dependencyManager = dependencyManager
            textPostPreviewView.onlyShowPreview = true
            textPostPreviewView.updateToStreamItem(streamItem)
            textPostPreviewView.displayReadyBlock = { [weak self] streamItemPreviewView in
                textPostPreviewView.renderTextPostPreviewImageWithCompletion({ image in
                    guard let strongSelf = self else {
                        return
                    }
                    let cacheKey = streamItem.remoteId
                    strongSelf.renderedTextPostCache?.setObject(image, forKey: cacheKey)
                    strongSelf.imageView.image = image
                    strongSelf.updateWithImage(image, cacheKey: cacheKey, animated: true)
                })
            };
        }
    }
    
    private func updateImageView(url url: NSURL) {
        imageView.sd_setImageWithURL(url, placeholderImage: nil, completed: { [weak self] image, error, cacheType, url in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                guard let strongSelf = self else {
                    return
                }
                strongSelf.updateWithImage(image, cacheKey: url?.absoluteString, animated: cacheType != .Memory)
            })
        })
    }
    
    private func updateWithImage(image: UIImage?, cacheKey: String?, animated: Bool) {
        
        guard let image = image, cacheKey = cacheKey else {
            return
        }
        
        let colorCacheKey = cacheKey
        
        if let colorCache = colorCache, cachedColor = colorCache.objectForKey(colorCacheKey) as? UIColor {
            gradient.primaryColor = cachedColor
        }
        else if let color = image.dominantColors(accuracy: .Low).first {
            gradient.primaryColor = color
            colorCache?.setObject(color, forKey: colorCacheKey)
        }
        
        let finish = { (blurredImage: UIImage) -> Void in
            dispatch_async(dispatch_get_main_queue()) {
                self.blurredImageView.image = blurredImage
                self.blurredImageView.layer.mask = self.blurMask.layer
                self.updateToReadyState(animated)
            }
        }
        
        let cacheIdentifier = cacheKey.stringByAppendingString(Constants.blurCacheString)
        
        if let cachedImage = SDWebImageManager.sharedManager().imageCache.imageFromMemoryCacheForKey(cacheIdentifier) {
            finish(cachedImage)
        }
        
        // Blur the preview image
        self.blurredImageView.blurImage(image, withTintColor: nil) { img in
            SDWebImageManager.sharedManager().imageCache.storeImage(img, forKey: cacheIdentifier)
            finish(img)
        }
    }
    
    private func updateToInitialState() {
        screenView.alpha = 0
        blurredImageView.alpha = 0
        gradient.alpha = 0
        blurMask.alpha = 0
    }
    
    private func updateToReadyState(animated: Bool) {
        UIView.animateWithDuration(animated ? 0.3 : 0, animations: { () -> Void in
            self.screenView.alpha = 1
            self.blurredImageView.alpha = 1
            self.gradient.alpha = 1
            self.blurMask.alpha = 1
        })
    }
    
    override func prepareForReuse() {
        updateToInitialState()
    }
    
    class func reuseIdentifier() -> String {
        return NSStringFromClass(TrendingTopicContentCollectionViewCell.self)
    }
    
    //The ideal size of this cell
    class func desiredSize() -> CGSize {
        return Constants.desiredSize
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
