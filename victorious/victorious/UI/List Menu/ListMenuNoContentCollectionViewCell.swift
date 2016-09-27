//
//  ListMenuNoContentCollectionViewCell.swift
//  victorious
//
//  Created by Tian Lan on 4/26/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class ListMenuNoContentCollectionViewCell: UICollectionViewCell {
    @IBOutlet fileprivate weak var noContentMessageLabel: UILabel!
    
    var dependencyManager: VDependencyManager! {
        didSet {
            noContentMessageLabel.textColor = dependencyManager.titleColor
            noContentMessageLabel.font = dependencyManager.titleFont
        }
    }
    
    func configure(withTitle title: String) {
        noContentMessageLabel.text = title
    }
}

private extension VDependencyManager {
    var titleColor: UIColor? {
        return colorForKey(VDependencyManagerContentTextColorKey)
    }
    
    var titleFont: UIFont? {
        return fontForKey(VDependencyManagerParagraphFontKey)
    }
}
