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
    @IBOutlet private var userNameLabel: UILabel!
    
    func configure(with dependencyManager: VDependencyManager, user: UserModel) {
        userNameLabel.text = user.name
        
        if let profileImageURL = user.previewImageURL(ofMinimumSize: profileButton.bounds.size) {
            profileButton?.setProfileImageURL(profileImageURL, forState: .Normal)
        }
    }
}
