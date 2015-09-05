//
//  LevelUpIconCollectionViewCell.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 9/4/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

class LevelUpIconCollectionViewCell: UICollectionViewCell {
    
    let imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        imageView.image = UIImage(named: "rocket")
        imageView.setTranslatesAutoresizingMaskIntoConstraints(false)
        contentView.addSubview(imageView)
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-5-[imgView]-5-|", options: nil, metrics: nil, views: ["imgView" : imageView]))
        contentView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-5-[imgView]-5-|", options: nil, metrics: nil, views: ["imgView" : imageView]))
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
