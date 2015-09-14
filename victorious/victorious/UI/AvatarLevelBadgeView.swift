//
//  AvatarLevelBadgeView.swift
//  victorious
//
//  Created by Sharif Ahmed on 9/9/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

private protocol BadgeImageSet {
    
    func image(#type: VBadgeImageType) -> UIImage
}

class AvatarLevelBadgeView: UIView {
    
    static let kLabelSideInset: CGFloat = 3
    
    // MARK: Private structs
    private struct UserBadgeImages: BadgeImageSet {
        
        static let smallImage = UIImage(named: "level_badge_small")!
        static let mediumImage = UIImage(named: "level_badge_medium")!
        static let largeImage = UIImage(named: "level_badge_large")!
        
        func image(#type: VBadgeImageType) -> UIImage {
            var image: UIImage
            switch type {
            case .Small:
                image = UserBadgeImages.smallImage
            case .Medium:
                image = UserBadgeImages.mediumImage
            case .Large:
                image = UserBadgeImages.largeImage
            }
            let sideInset = image.size.width / 2
            return image.resizableImageWithCapInsets(UIEdgeInsetsMake(0, sideInset, 0, sideInset))
        }
        
        func font(#type: VBadgeImageType) -> UIFont? {
            switch type {
                // WARNING: Get these numbers from design
            case .Small:
                return UIFont(name: "OpenSans-Bold", size: 10)
            case .Medium:
                return UIFont(name: "OpenSans-Bold", size: 40)
            case .Large:
                return UIFont(name: "OpenSans-Bold", size: 60)
            }
        }
    }
    
    private struct CreatorBadgeImages: BadgeImageSet {
        
        static let smallImage = UIImage(named: "level_badge_creator_small")!
        static let mediumImage = UIImage(named: "level_badge_creator_medium")!
        static let largeImage = UIImage(named: "level_badge_creator_large")!
        
        func image(#type: VBadgeImageType) -> UIImage {
            var image: UIImage
            switch type {
            case .Small:
                image = CreatorBadgeImages.smallImage
            case .Medium:
                image = CreatorBadgeImages.mediumImage
            case .Large:
                image = CreatorBadgeImages.largeImage
            }
            return image
        }
    }
    
    // MARK: Private properties
    private let creatorBadgeImages = CreatorBadgeImages()
    private let userBadgeImages = UserBadgeImages()
    private let backgroundImageView = UIImageView()
    private let badgeLabel = UILabel()
    private let numberFormatter = VLargeNumberFormatter()

    // MARK: Readonly variables
    var desiredSize: CGSize {
        var size = image(isCreator, withImageType: badgeImageType).size
        if let text = text where !isCreator
        {
            let textWidth = text.boundingRectWithSize(CGSizeMake(CGFloat.max, size.height), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [ NSFontAttributeName : badgeLabel.font ], context: nil).width + ( AvatarLevelBadgeView.kLabelSideInset * 2 )
            size.width = max(size.width, textWidth)
        }
        
        return size
    }
    
    // MARK: Exposed variables
    var level: Int = 0 {
        didSet {
            text = numberFormatter.stringForInteger(level)
        }
    }
    var text: String? {
        didSet {
            updateBadgeText()
        }
    }
    var badgeBackgroundColor: UIColor? {
        didSet {
            if ( !backgroundImageView.tintColor.isEqual(badgeBackgroundColor) ) {
                backgroundImageView.tintColor = badgeBackgroundColor
            }
        }
    }
    var textColor: UIColor? {
        didSet {
            badgeLabel.textColor = textColor
        }
    }
    var isCreator = false {
        didSet {
            if isCreator != oldValue {
                updateBadgeIcon()
                updateBadgeText()
            }
        }
    }
    var badgeImageType = VBadgeImageType.Small {
        didSet {
            if badgeImageType != oldValue {
                updateBadgeIcon()
            }
        }
    }
    override var bounds: CGRect {
        didSet {
            updateBadgeIcon()
        }
    }
    
    // MARK: Initialization
    func new() -> AvatarLevelBadgeView {
        return AvatarLevelBadgeView(frame: CGRect.zeroRect)
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedSetup()
    }
    
    required override init(frame: CGRect) {
        super.init(frame: frame)
        sharedSetup()
    }
    
    // MARK: Private functions
    private func sharedSetup() {
        badgeLabel.adjustsFontSizeToFitWidth = true
        badgeLabel.textAlignment = NSTextAlignment.Center
        
        addSubview(backgroundImageView)
        v_addFitToParentConstraintsToSubview(backgroundImageView)
        addSubview(badgeLabel)
        v_addFitToParentConstraintsToSubview(badgeLabel, leading: AvatarLevelBadgeView.kLabelSideInset, trailing: AvatarLevelBadgeView.kLabelSideInset, top: 0, bottom: 0)
        
        updateBadgeIcon()
    }
    
    private func badgeImageSet(forCreator: Bool) -> BadgeImageSet {
        return forCreator ? creatorBadgeImages : userBadgeImages
    }
    
    private func image(forCreator: Bool, withImageType imageType: VBadgeImageType) -> UIImage {
        let size = bounds.size
        let imageSet: BadgeImageSet = badgeImageSet(forCreator)
        let image = imageSet.image(type: imageType)
        let renderingMode = forCreator ? UIImageRenderingMode.AlwaysOriginal : UIImageRenderingMode.AlwaysTemplate
        return image.imageWithRenderingMode(renderingMode)
    }
    
    private func updateBadgeIcon() {
        let desiredImage = image(isCreator, withImageType: badgeImageType)
        if let currentImage = backgroundImageView.image where currentImage.isEqual(desiredImage) { }
        else {
            backgroundImageView.image = desiredImage
            if let imageSet = badgeImageSet(isCreator) as? UserBadgeImages {
                badgeLabel.font = imageSet.font(type: badgeImageType)
            }
        }
    }
    
    private func updateBadgeText() {
        badgeLabel.text = isCreator ? nil : text
    }
}
