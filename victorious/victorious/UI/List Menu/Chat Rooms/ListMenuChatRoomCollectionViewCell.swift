//
//  ListMenuChatRoomCollectionViewCell.swift
//  victorious
//
//  Created by Alex Tamoykin on 9/15/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

final class ListMenuChatRoomCollectionViewCell: UICollectionViewCell, ListMenuSectionCell {

    // MARK: - Outlets

    @IBOutlet private weak var titleLabel: UILabel!

    // MARK: - UICollectionViewCell

    override var selected: Bool {
        didSet {
            updateCellBackgroundColor(to: contentView, selectedColor: dependencyManager?.selectedBackgroundColor, isSelected: selected)
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

    private func applyTemplateAppearance(with dependencyManager: VDependencyManager) {
        titleLabel.textColor = dependencyManager.titleColor
        titleLabel.font = dependencyManager.chatRoomItemFont
    }
}


private extension VDependencyManager {
    var chatRoomItemFont: UIFont? {
        return fontForKey(VDependencyManagerParagraphFontKey)
    }

    var selectedBackgroundColor: UIColor? {
        return colorForKey(VDependencyManagerAccentColorKey)
    }

    var titleColor: UIColor? {
        return colorForKey("color.text.navItem")
    }
}
