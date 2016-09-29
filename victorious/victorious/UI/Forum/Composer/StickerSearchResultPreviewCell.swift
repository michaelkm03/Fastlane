//
//  StickerSearchResultPreviewCell.swift
//  victorious
//
//  Created by Sharif Ahmed on 9/28/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class StickerSearchResultPreviewCell: UICollectionViewCell {
    static let associatedNib = UINib(nibName: "StickerSearchResultPreviewCell", bundle: nil)
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var lockImageView: UIImageView!
}
