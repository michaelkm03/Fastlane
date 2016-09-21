//
//  TrayLoadingCollectionViewCell.swift
//  victorious
//
//  Created by Sharif Ahmed on 9/20/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

// A cell with an animating activity indicator in it's center
class TrayLoadingCollectionViewCell: UICollectionViewCell {
    lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(activityIndicatorStyle: .White)
        self.contentView.addSubview(indicator)
        indicator.startAnimating()
        return indicator
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        activityIndicator.center = contentView.center
    }
}
