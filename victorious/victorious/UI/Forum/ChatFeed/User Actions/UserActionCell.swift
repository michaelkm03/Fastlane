//
//  UserActionCell.swift
//  victorious
//
//  Created by Patrick Lynch on 3/7/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class UserActionCell: UICollectionViewCell {

    @IBOutlet weak private var button: UIButton!
    
    struct ViewData {
        let action: String
    }
    var viewData: ViewData! {
        didSet {
            button.setTitle(viewData.action, forState: .Normal)
        }
    }
}
