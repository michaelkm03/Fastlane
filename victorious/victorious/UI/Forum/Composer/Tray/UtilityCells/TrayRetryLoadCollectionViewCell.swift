//
//  TrayRetryLoadCollectionViewCell.swift
//  victorious
//
//  Created by Sharif Ahmed on 9/20/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

// A cell with a "retry" indicator in it's center
class TrayRetryLoadCollectionViewCell: UICollectionViewCell {
    lazy var imageView: UIImageView = {
        let image = UIImage(named: "uploadRetryButton")?.withRenderingMode(.alwaysTemplate)
        let imageView = UIImageView(image: image)
        imageView.tintColor = .white
        self.contentView.addSubview(imageView)
        return imageView
    }()
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.center = contentView.center
    }
}
