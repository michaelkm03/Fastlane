//
//  StickerSearchResultPreviewCellPopulator.swift
//  victorious
//
//  Created by Sharif Ahmed on 9/28/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import SDWebImage
import UIKit

struct StickerSearchResultPreviewCellPopulator {
    static func populate(stickerCell: StickerSearchResultPreviewCell, withSearchResultObject searchResultObject: StickerSearchResultObject) {
        stickerCell.imageView.sd_cancelCurrentImageLoad()
        stickerCell.activityIndicator.startAnimating()
        stickerCell.imageView.sd_setImageWithURL(searchResultObject.thumbnailImageURL) { _ in
            stickerCell.activityIndicator.stopAnimating()
            stickerCell.lockImageView.hidden = !searchResultObject.isVIP
        }
    }
}
