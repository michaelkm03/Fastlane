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
    
    var viewData: ViewData? {
        didSet {
            if let viewData = viewData {
                usernameLabel.text = viewData.username
            }
        }
    }
    
    var preferredPictureSize: CGSize {
        return profileButton.frame.size
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
                profileButton.tintColor = dependencyManager.colorForKey(VDependencyManagerLinkColorKey)
                usernameLabel.font = dependencyManager.fontForKey(VDependencyManagerLabel1FontKey)
                followControl?.dependencyManager = dependencyManager
            }
        }
    }
    
    @IBOutlet private var profileButton: UIButton!
    @IBOutlet private var usernameLabel: UILabel!
}
