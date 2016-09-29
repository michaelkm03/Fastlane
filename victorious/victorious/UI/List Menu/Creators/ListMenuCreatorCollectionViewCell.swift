//
//  ListMenuCreatorCollectionViewCell.swift
//  victorious
//
//  Created by Tian Lan on 4/21/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit
import VictoriousIOSSDK

class ListMenuCreatorCollectionViewCell: UICollectionViewCell, ListMenuSectionCell {
    typealias Cell = ListMenuCreatorCollectionViewCell
    
    @IBOutlet fileprivate weak var avatarView: AvatarView!
    @IBOutlet fileprivate weak var creatorNameLabel: UILabel!
    
    override var isSelected: Bool {
        didSet {
            updateCellBackgroundColor(to: contentView, selectedColor: dependencyManager?.highlightedBackgroundColor, isSelected: selected)
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
    
    func configureCell(with user: UserModel) {
        creatorNameLabel.text = user.displayName
        avatarView.user = user
    }
    
    // MARK: - Private methods
    
    fileprivate func applyTemplateAppearance(with dependencyManager: VDependencyManager) {
        creatorNameLabel.textColor = dependencyManager.titleColor
        creatorNameLabel.font = dependencyManager.titleFont
    }
}

private extension VDependencyManager {
    var titleColor: UIColor? {
        return color(forKey: "color.text.navItem")
    }
    
    var titleFont: UIFont? {
        return font(forKey: "font.navigationItems")
    }
    
    var highlightedBackgroundColor: UIColor? {
        return color(forKey: VDependencyManagerAccentColorKey)
    }
}
