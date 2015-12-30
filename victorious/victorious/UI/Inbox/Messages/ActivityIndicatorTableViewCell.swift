//
//  ActivityIndicatorTableViewCell.swift
//  victorious
//
//  Created by Michael Sena on 12/3/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import UIKit

class ActivityIndicatorTableViewCell: UITableViewCell {

    @IBOutlet private var activityIndicator: UIActivityIndicatorView!
    
    func resumeAnimation() {
        activityIndicator.startAnimating()
    }
    
    class func suggestedReuseIdentifier() -> String {
        return "ActivityIndicatorTableViewCell"
    }
}
