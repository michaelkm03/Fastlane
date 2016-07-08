//
//  AvatarLevelBadgeView.swift
//  victorious
//
//  Created by Sharif Ahmed on 9/9/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

/// Objects conforming to this protocol should return an image
/// from it's set based on various critieria.
private protocol BadgeImageSet {
    
    /// Returns an image based on the desired level badge image type.
    func image(type type: VLevelBadgeImageType) -> UIImage
}

class AvatarLevelBadgeView: UIView, VHasManagedDependencies {
    
    private static let kFontName = "OpenSans-Bold"
    private static let kLabelInsets = UIEdgeInsetsMake(0, 3, 1, 3);
    
    // MARK: Private structs
    
    private struct UserBadgeImages: BadgeImageSet {
        
        private static let smallImage = UIImage(named: "level_badge_small")!
        private static let mediumImage = UIImage(named: "level_badge_medium")!
        private static let largeImage = UIImage(named: "level_badge_large")!
        
        func image(type type: VLevelBadgeImageType) -> UIImage {
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
        
        func font(type type: VLevelBadgeImageType) -> UIFont? {
            switch type {
            case .Small:
                return UIFont(name: kFontName, size: 10)
            case .Medium:
                return UIFont(name: kFontName, size: 37)
            case .Large:
                return UIFont(name: kFontName, size: 60)
            }
        }
    }
    
    private struct CreatorBadgeImages: BadgeImageSet {
        
        private static let smallImage = UIImage(named: "level_badge_creator_small")!
        private static let mediumImage = UIImage(named: "level_badge_creator_medium")!
        private static let largeImage = UIImage(named: "level_badge_creator_large")!
        
        func image(type type: VLevelBadgeImageType) -> UIImage {
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
    private var text: String? {
        didSet {
            updateBadgeText()
        }
    }
    
    private var verified: Bool {
        return avatarBadgeType == .Verified
    }

    // MARK: Readonly variables
    
    /// Returns the optimium size for this badge view based on this badge view's current state.
    var desiredSize: CGSize {
        var size = image(verified, withImageType: levelBadgeImageType).size
        if let text = text where !verified {
            let textWidth = text.boundingRectWithSize(CGSizeMake(CGFloat.max, size.height), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [ NSFontAttributeName : badgeLabel.font ], context: nil).width + ( AvatarLevelBadgeView.kLabelInsets.left + AvatarLevelBadgeView.kLabelInsets.right )
            size.width = max(size.width, textWidth)
        }
        
        return size
    }
    
    // MARK: Exposed variables
    
    /// The dependency manager used to style this view. Setting will
    /// update all other appearance properties.
    var badgeDependencyManager: VDependencyManager? {
        didSet {
            updateAppearance()
        }
    }
    
    /// The level being represented by this badge view. Defaults to 0.
    var level: Int = 0 {
        didSet {
            text = numberFormatter.stringForInteger(level)
        }
    }
    
    /// The color of the text displayed atop the badge image.
    var textColor: UIColor? {
        didSet {
            badgeLabel.textColor = textColor
        }
    }
    
    var avatarBadgeType: AvatarBadgeType = .None {
        didSet {
            if avatarBadgeType != oldValue {
                updateBadgeIcon()
                updateBadgeText()
            }
        }
    }
    
    /// The desired level badge image type. Defaults to Small.
    var levelBadgeImageType = VLevelBadgeImageType.Small {
        didSet {
            if levelBadgeImageType != oldValue {
                updateBadgeIcon()
            }
        }
    }
    
    /// Used to update the tint color of the badge background image.
    var badgeTintColor: UIColor? {
        didSet {
            if ( !backgroundImageView.tintColor.isEqual(badgeTintColor) ) {
                backgroundImageView.tintColor = badgeTintColor
            }
        }
    }
    
    // MARK: Initialization
    
    /// Convenience initializer
    required init(dependencyManager: VDependencyManager) {
        let insets = AvatarLevelBadgeView.kLabelInsets
        let minimumRect = CGRectMake(0, 0, insets.left + insets.right, insets.top + insets.bottom)
        super.init(frame: minimumRect)
        sharedSetup()
        self.badgeDependencyManager = dependencyManager
        updateAppearance()
    }

    required init?(coder aDecoder: NSCoder) {
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
        backgroundImageView.contentMode = .ScaleAspectFill
        
        addSubview(backgroundImageView)
        v_addFitToParentConstraintsToSubview(backgroundImageView)
        addSubview(badgeLabel)
        let insets = AvatarLevelBadgeView.kLabelInsets
        v_addFitToParentConstraintsToSubview(badgeLabel, leading: insets.left, trailing: insets.right, top: insets.top, bottom: insets.bottom)
        
        updateBadgeIcon()
    }
    
    private func updateAppearance() {
        if let badgeDependencyManager = badgeDependencyManager {
            badgeTintColor = badgeDependencyManager.colorForKey(VDependencyManagerLinkColorKey)
            textColor = badgeDependencyManager.colorForKey(VDependencyManagerMainTextColorKey)
        }
    }
    
    private func badgeImageSet(forCreator: Bool) -> BadgeImageSet {
        return forCreator ? creatorBadgeImages : userBadgeImages
    }
    
    private func image(forCreator: Bool, withImageType imageType: VLevelBadgeImageType) -> UIImage {
        let imageSet: BadgeImageSet = badgeImageSet(forCreator)
        let image = imageSet.image(type: imageType)
        let renderingMode = forCreator ? UIImageRenderingMode.AlwaysOriginal : UIImageRenderingMode.AlwaysTemplate
        return image.imageWithRenderingMode(renderingMode)
    }
    
    private func updateBadgeIcon() {
        let desiredImage = image(verified, withImageType: levelBadgeImageType)
        if let currentImage = backgroundImageView.image where currentImage.isEqual(desiredImage) { }
        else {
            backgroundImageView.image = desiredImage
            if let imageSet = badgeImageSet(verified) as? UserBadgeImages {
                badgeLabel.font = imageSet.font(type: levelBadgeImageType)
            }
        }
    }
    
    private func updateBadgeText() {
        badgeLabel.text = verified ? nil : text
    }

    /// Updates the badge view's visibility and level based on the passed in user.
    func updateBadge(forUser user: VUser?) {
        guard let userLevel = user?.level?.integerValue else {
            hidden = true
            return
        }
        hidden = (userLevel < badgeDependencyManager?.minimumLevel() || userLevel == 0) && !verified
        
        level = userLevel
    }
}

private extension VDependencyManager {
    func minimumLevel() -> Int {
        return numberForKey("minLevel").integerValue
    }
}
