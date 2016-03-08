//
//  UserActionsHeaderCell.swift
//  victorious
//
//  Created by Patrick Lynch on 3/7/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class UserActionsHeaderCell: UICollectionViewCell {
    
    @IBOutlet private weak var textView: UITextView!
    @IBOutlet private weak var avatarView: UIImageView!
    
    struct ViewData {
        let username: String
        let avatarImageURL: NSURL
    }
    
    var viewData: ViewData! {
        didSet {
            textView.text = viewData.username
            avatarView.sd_setImageWithURL(viewData.avatarImageURL)
        }
    }
}
