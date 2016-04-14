//
//  ListMenuHashtagCollectionViewCell.swift
//  victorious
//
//  Created by Tian Lan on 4/12/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class ListMenuHashtagCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet private weak var titleLabel: UILabel!
    
    func configureCell(with hashtag: HashtagSearchResultObject) {
        titleLabel.text = "#\(hashtag.tag)"
    }
}
