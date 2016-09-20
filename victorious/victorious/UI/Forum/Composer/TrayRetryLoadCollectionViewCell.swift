//
//  TrayRetryLoadCollectionViewCell.swift
//  victorious
//
//  Created by Sharif Ahmed on 9/20/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class TrayRetryLoadCollectionViewCell: UICollectionViewCell {
    lazy var retryImageView: UIImageView = {
        let image = UIImage(named: "uploadRetryButton")?.imageWithRenderingMode(.AlwaysTemplate)
        let imageView = UIImageView(image: image)
        imageView.tintColor = .whiteColor()
        self.contentView.addSubview(imageView)
        return imageView
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        retryImageView.center = contentView.center
    }
}
