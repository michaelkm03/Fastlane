//
//  ListMenuHashtagCollectionViewCell.swift
//  victorious
//
//  Created by Tian Lan on 4/12/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

final class ListMenuHashtagCollectionViewCell: UICollectionViewCell, ListMenuSectionCell {
    
    @IBOutlet fileprivate weak var titleLabel: UILabel!
    
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

    func configureCell(with hashtag: Hashtag) {
        titleLabel.text = "#\(hashtag.tag)"
    }
    
    // MARK: - Private methods
    
    fileprivate func applyTemplateAppearance(with dependencyManager: VDependencyManager) {
        titleLabel.textColor = dependencyManager.titleColor
        titleLabel.font = dependencyManager.hashtagItemFont
    }
}

private extension VDependencyManager {
    var titleColor: UIColor? {
        return color(forKey: "color.text.navItem")
    }

    var hashtagItemFont: UIFont? {
        return font(forKey: VDependencyManagerParagraphFontKey)
    }
    
    var selectedBackgroundColor: UIColor? {
        return color(forKey: VDependencyManagerAccentColorKey)
    }
}
