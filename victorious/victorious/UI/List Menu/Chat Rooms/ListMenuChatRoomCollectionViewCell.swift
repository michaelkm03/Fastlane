//
//  ListMenuChatRoomCollectionViewCell.swift
//  victorious
//
//  Created by Alex Tamoykin on 9/15/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import VictoriousIOSSDK

final class ListMenuChatRoomCollectionViewCell: UICollectionViewCell, ListMenuSectionCell {

    // MARK: - Outlets

    @IBOutlet fileprivate weak var titleLabel: UILabel!

    // MARK: - UICollectionViewCell

    override var isSelected: Bool {
        didSet {
            updateCellBackgroundColor(to: contentView, selectedColor: dependencyManager?.selectedBackgroundColor, isSelected: isSelected)
        }
    }

    // MARK: - ListMenuSectionCell

    var dependencyManager: VDependencyManager? {
        didSet {
            if let dependencyManager = dependencyManager {
                applyTemplateAppearance(with: dependencyManager)
            }
        }
    }

    func configureCell(with chatRoom: ChatRoom) {
        titleLabel.text = chatRoom.name
    }

    // MARK: - Private methods

    fileprivate func applyTemplateAppearance(with dependencyManager: VDependencyManager) {
        titleLabel.textColor = dependencyManager.titleColor
        titleLabel.font = dependencyManager.chatRoomItemFont
    }
}


private extension VDependencyManager {
    var chatRoomItemFont: UIFont? {
        return font(forKey: VDependencyManagerParagraphFontKey)
    }

    var selectedBackgroundColor: UIColor? {
        return color(forKey: VDependencyManagerAccentColorKey)
    }

    var titleColor: UIColor? {
        return color(forKey: "color.text.navItem")
    }
}
