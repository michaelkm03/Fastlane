//
//  VTrendingTopicContentCollectionViewCell.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 8/20/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

class TrendingTopicContentCollectionViewCell: VShelfContentCollectionViewCell {
    
    private var screenView = UIView()
    private var gradient = TrendingTopicGradientView()
    private var label = UILabel()
    private var imageView = UIImageView()
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
    
    var image: UIImage? {
        didSet {
            if let image = self.image {
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.imageView.image = image
                    
                    let colors = self.colorCube.extractColorsFromImage(image, flags: CCOrderByBrightness.value)
                    if let color = colors.first as? UIColor {
                        self.gradient.primaryColor =  color
                    }
                    
                    self.gradient.primaryColor = UIColor.redColor()
                    
                    self.blurredImageView.blurImage(image, withTintColor: nil, toCallbackBlock: { (img) -> Void in
                        self.blurredImageView.image = img
                        self.blurredImageView.layer.mask = self.blurMask.layer
                    })
                });
            }
        }
    }
    
    var url: NSURL? {
        didSet {
            if let url = self.url {
            }
        }
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    required  init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    private func setup() {
        
        self.image = UIImage(named: "jennim")
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
        label.text = "#outfits"
        self.contentView.addSubview(label)
        self.contentView.v_addFitToParentConstraintsToSubview(label)
    }
}

extension TrendingTopicContentCollectionViewCell: VStreamCellComponentSpecialization {
    
    override class func reuseIdentifierForStreamItem(streamItem: VStreamItem, baseIdentifier: String?, dependencyManager: VDependencyManager?) -> String {
        let updatedIdentifier = self.identifier(baseIdentifier, className: NSStringFromClass(self))
        return super.reuseIdentifierForStreamItem(streamItem, baseIdentifier: updatedIdentifier, dependencyManager: dependencyManager)
    }
}

