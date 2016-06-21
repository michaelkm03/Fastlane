//
//  AttributionBar.swift
//  victorious
//
//  Created by Tian Lan on 6/20/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class AttributionBar: UIView {
    @IBOutlet private var profileButton: VDefaultProfileButton!
    @IBOutlet private var userNameLabel: UILabel! {
        didSet {
            userNameLabel.textColor = dependencyManager?.userNameLabelTextColor
            userNameLabel.font = dependencyManager?.userNameLabelFont
        }
    }
    
    var dependencyManager: VDependencyManager?
    
    func configure(with user: UserModel) {
        userNameLabel.text = user.name

        if let profileImageURL = user.previewImageURL(ofMinimumSize: profileButton.bounds.size) {
            profileButton?.setProfileImageURL(profileImageURL, forState: .Normal)
        }
    }
}

private extension VDependencyManager {
    var userNameLabelFont: UIFont {
        return fontForKey("font.username") ?? UIFont.systemFontOfSize(16)
    }
    
    var userNameLabelTextColor: UIColor {
        return colorForKey("color.username") ?? UIColor.whiteColor()
    }
}
