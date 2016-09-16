//
//  LikeView.swift
//  victorious
//
//  Created by Mariana Lenetis on 9/16/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class LikeView: UIView {
    let imageView = UIImageView()
    let countLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(imageView)
        addSubview(countLabel)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        imageView.sizeToFit()
        imageView.frame = CGRect(
            center: bounds.center,
            size: imageView.frame.size
        )

        let horizontalPadding = CGFloat(3.0)
        let verticalPadding = CGFloat(8.0)
        countLabel.sizeToFit()
        countLabel.frame = CGRect(
            x: CGRectGetMaxX(imageView.frame) - horizontalPadding,
            y: CGRectGetMaxY(imageView.frame) - verticalPadding,
            width: CGRectGetWidth(countLabel.frame),
            height: CGRectGetHeight(countLabel.frame)
        )
    }
}
