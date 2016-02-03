//
//  ActivityIndicatorCollectionCell.swift
//  victorious
//
//  Created by Patrick Lynch on 2/2/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class ActivityIndicatorCollectionCell: UICollectionViewCell {
    
    @IBOutlet weak private var activityIndicator: UIActivityIndicatorView!
    
    var color: UIColor! {
        didSet {
            activityIndicator.color = color
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        activityIndicator.startAnimating()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        color = activityIndicator.color
    }
}
