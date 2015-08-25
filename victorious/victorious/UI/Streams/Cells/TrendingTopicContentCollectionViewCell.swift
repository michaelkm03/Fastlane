//
//  VTrendingTopicContentCollectionViewCell.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 8/20/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

class TrendingTopicContentCollectionViewCell: VBaseCollectionViewCell, VStreamCellComponentSpecialization {
    
    private var imageView = UIImageView()
    private var screenView = UIView()
    private var gradient = TrendingTopicGradientView()
    private var label = UILabel()
    private var blurredImageView = UIImageView()
    private let colorCube = CCColorCube()
    
    private lazy var blurMask: TrendingTopicGradientView = {
        let blurMask = TrendingTopicGradientView()
        blurMask.primaryColor = UIColor.blackColor()
        blurMask.gradientAlphas = (0, 1, 0)
        return blurMask
    }()
    
    var color: UIColor? {
        didSet {
            gradient.primaryColor = color
        }
    }
    
    var streamItem: VStreamItem? {
        didSet {
            self.label.text = streamItem?.name ?? ""
            if let previewImageURL = (streamItem?.previewImagesObject as? String),
                url = NSURL(string: previewImageURL)  {
                imageView.sd_setImageWithURL(url, placeholderImage: nil, completed: { (image, error, cacheType, url) -> Void in
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        self.image = image
                    })
                })
            }
        }
    }
    
    var image: UIImage? {
        didSet {
            if let image = self.image {
                
                let colors = self.colorCube.extractColorsFromImage(image, flags: CCOrderByBrightness.value)
                if let color = colors.first as? UIColor {
                    self.gradient.primaryColor =  color
                }
                
                self.blurredImageView.blurImage(image, withTintColor: nil, toCallbackBlock: { (img) -> Void in
                    self.blurredImageView.image = img
                    self.blurredImageView.layer.mask = self.blurMask.layer
                })
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
        label.font = UIFont.boldSystemFontOfSize(12)
        self.contentView.addSubview(label)
        self.contentView.v_addPinToLeadingTrailingToSubview(label, leading: 10, trailing: 10)
        self.contentView.v_addPintoTopBottomToSubview(label, top: 0, bottom: 0)
    }
}

extension TrendingTopicContentCollectionViewCell: VStreamCellComponentSpecialization {
    
    class func reuseIdentifierForStreamItem(streamItem: VStreamItem, baseIdentifier: String?, dependencyManager: VDependencyManager?) -> String {
        return "trendingContentCell"
    }
}

