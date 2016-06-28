//
//  CaptionBarPopulator.swift
//  victorious
//
//  Created by Sharif Ahmed on 6/28/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

struct CaptionBarPopulator {
    static func populate(captionBar: CaptionBar, withUser user: UserModel, andCaption caption: String) {
        let imageURL = user.previewImageURL(ofMinimumWidth: captionBar.bounds.width) ?? NSURL()
        captionBar.avatarImageView.fadeInImageAtURL(imageURL)
        captionBar.captionLabel.text = caption
    }
    
    static func toggle(captionBar: CaptionBar, toCollapsed collapsed: Bool) -> CGFloat {
        captionBar.captionLabel.numberOfLines = collapsed ? 2 : 5
        captionBar.layoutIfNeeded()
        let maxSize = CGSize(width: captionBar.bounds.width, height: CGFloat.max)
        return captionBar.sizeThatFits(maxSize).height
    }
}
