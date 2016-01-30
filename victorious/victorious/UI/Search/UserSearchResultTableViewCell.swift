//
//  UserSearchResultTableViewCell.swift
//  victorious
//
//  Created by Michael Sena on 12/14/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import Foundation

class UserSearchResultTableViewCell: UITableViewCell {
    
    @IBOutlet weak var followControl: VFollowControl?

    struct ViewData {
        let username: String
        let profileURL: NSURL
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        profileButton.levelBadgeView.hidden = true
    }
    
    var viewData: ViewData? {
        didSet {
            if let viewData = viewData {
                profileButton.setProfileImageURL(viewData.profileURL, forState: .Normal)
                usernameLabel.text = viewData.username
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if AgeGate.isAnonymousUser() {
            self.followControl?.removeFromSuperview()
            self.followControl = nil
        }
    }
    
    var dependencyManager: VDependencyManager? {
        didSet {
            if let dependencyManager = dependencyManager {
                profileButton.dependencyManager = dependencyManager
                profileButton.tintColor = dependencyManager.colorForKey(VDependencyManagerLinkColorKey)
                usernameLabel.font = dependencyManager.fontForKey(VDependencyManagerLabel1FontKey)
                followControl?.dependencyManager = dependencyManager
            }
        }
    }
    
    @IBOutlet private var profileButton: VDefaultProfileButton!
    @IBOutlet private var usernameLabel: UILabel!
    
    class func suggestedReuseIdentifier() -> String {
        return StringFromClass(UserSearchResultTableViewCell.self)
    }
}
