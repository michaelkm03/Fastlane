//
//  LevelUpIconCollectionViewCell.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 9/4/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

class LevelUpIconCollectionViewCell: UICollectionViewCell {
    
    var iconURL: NSURL? {
        didSet {
            if let iconURL = iconURL {
                imageView.sd_setImageWithURL(iconURL)
            }
        }
    }
    
    private let imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
    
    private func sharedInit() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(imageView)
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-5-[imgView]-5-|", options: [], metrics: nil, views: ["imgView": imageView]))
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-5-[imgView]-5-|", options: [], metrics: nil, views: ["imgView": imageView]))
    }
}
