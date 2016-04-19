//
//  ListMenuHashtagCollectionViewCell.swift
//  victorious
//
//  Created by Tian Lan on 4/12/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class ListMenuHashtagCollectionViewCell: UICollectionViewCell, ListMenuSectionCell {
    
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var titleBackgroundView: UIView! {
        didSet {
            titleBackgroundView.layer.cornerRadius = 6
        }
    }
    
    var dependencyManager: VDependencyManager! {
        didSet {
            applyTemplateAppearance(with: dependencyManager)
        }
    }
    
    func configureCell(with hashtag: HashtagSearchResultObject) {
        titleLabel.text = "#\(hashtag.tag)"
    }
    
    private func applyTemplateAppearance(with dependencyManager: VDependencyManager) {
        titleBackgroundView.backgroundColor = dependencyManager.hashtagBackgroundColor
        titleLabel.font = dependencyManager.hashtagItemFont
    }
    
    override var selected: Bool {
        didSet {
            if selected {
                contentView.backgroundColor = dependencyManager.hashtagBackgroundColor
                titleBackgroundView.backgroundColor = nil
            } else {
                contentView.backgroundColor = nil
                titleBackgroundView.backgroundColor = dependencyManager.hashtagBackgroundColor
            }
        }
    }
    
    // MARK: - List Menu Section Cell
    
    static var preferredHeight: CGFloat {
        return 36
    }
}

private extension VDependencyManager {
    var hashtagBackgroundColor: UIColor? {
        return colorForKey(VDependencyManagerLinkColorKey)
    }
    
    var hashtagItemFont: UIFont? {
        return fontForKey(VDependencyManagerParagraphFontKey)
    }
}
