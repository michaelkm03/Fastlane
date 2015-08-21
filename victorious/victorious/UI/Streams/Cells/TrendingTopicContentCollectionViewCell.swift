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
//                    let color = image.dominantColors().first
                    self.gradient.primaryColor = UIColor.blackColor()
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
        
        imageView.image = UIImage(named: "jennim")
        imageView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.contentView.addSubview(imageView)
        self.contentView.v_addFitToParentConstraintsToSubview(imageView)
        
        screenView.backgroundColor = UIColor.blackColor().colorWithAlpha(0.2)
        screenView.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.contentView.addSubview(screenView)
        self.contentView.v_addFitToParentConstraintsToSubview(screenView)
        
        gradient.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.contentView.addSubview(gradient)
        self.contentView.v_addFitToParentConstraintsToSubview(gradient)
        
        label.textColor = UIColor.whiteColor()
        label.textAlignment = .Center
        label.setTranslatesAutoresizingMaskIntoConstraints(false)
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

