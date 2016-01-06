//
//  UserSearchResultTableViewCell.swift
//  victorious
//
//  Created by Michael Sena on 12/14/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

class UserSearchResultTableViewCell: UITableViewCell {

    struct ViewData {
        let username: String
        let profileURL: NSURL
    }
    
    var viewData: ViewData? {
        didSet {
            if let viewData = viewData {
                profileButton.setProfileImageURL(viewData.profileURL, forState: .Normal)
                usernameLabel.text = viewData.username
            }
        }
    }
    
    var dependencyManager: VDependencyManager? {
        didSet {
            if let dependencyManager = dependencyManager {
                profileButton.dependencyManager = dependencyManager
                profileButton.tintColor = dependencyManager.colorForKey(VDependencyManagerLinkColorKey)
                usernameLabel.font = dependencyManager.fontForKey(VDependencyManagerLabel1FontKey)
            }
        }
    }
    
    @IBOutlet private var profileButton: VDefaultProfileButton!
    @IBOutlet private var usernameLabel: UILabel!
    
    class func suggestedReuseIdentifier() -> String {
        return "UserSearchResultTableViewCell"
    }
}
