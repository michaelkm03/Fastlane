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
    
    override var selected: Bool {
        didSet {
            updateCellBackgroundColor(to: contentView, selectedColor: dependencyManager?.selectedBackgroundColor, isSelected: selected)
        }
    }
    
    // MARK: - List Menu Section Cell
    
    var dependencyManager: VDependencyManager? {
        didSet {
            if let dependencyManager = dependencyManager {
                applyTemplateAppearance(with: dependencyManager)
            }
        }
    }

    func configureCell(with hashtag: HashtagSearchResultObject) {
        titleLabel.text = "#\(hashtag.tag)"
    }
    
    func updateCellBackgroundColor(to backgroundContainer: UIView, selectedColor color: UIColor?, isSelected: Bool) {
        if isSelected {
            backgroundContainer.backgroundColor = color
            titleBackgroundView.backgroundColor = nil
        } else {
            backgroundContainer.backgroundColor = nil
            titleBackgroundView.backgroundColor = dependencyManager?.hashtagBackgroundColor
        }
    }
    
    // MARK: - Private methods
    
    private func applyTemplateAppearance(with dependencyManager: VDependencyManager) {
        titleBackgroundView.backgroundColor = dependencyManager.hashtagBackgroundColor
        titleLabel.font = dependencyManager.hashtagItemFont
    }
}

private extension VDependencyManager {
    
    var hashtagBackgroundColor: UIColor? {
        return colorForKey(VDependencyManagerLinkColorKey)
    }
    
    var hashtagItemFont: UIFont? {
        return fontForKey(VDependencyManagerParagraphFontKey)
    }
    
    var selectedBackgroundColor: UIColor? {
        return colorForKey(VDependencyManagerAccentColorKey)
    }
}
