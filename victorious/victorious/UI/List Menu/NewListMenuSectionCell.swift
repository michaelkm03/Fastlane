//
//  NewListMenuSectionCell.swift
//  victorious
//
//  Created by Alex Tamoykin on 9/23/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

class NewListMenuSectionCell: UICollectionViewCell {
    // MARK: - Outlets

    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var avatarView: AvatarView!

    // Cell Configuration

    /// Preferred height of the type of cell according to design spec
    static var preferredHight: CGFloat = 38

    var dependencyManager: VDependencyManager? {
        didSet {
            if let dependencyManager = dependencyManager {
                applyTemplateAppearance(with: dependencyManager)
            }
        }
    }

    var titleColorKey = VDependencyManagerAccentColorKey
    var itemFontKey = VDependencyManagerParagraphFontKey
    var selectedBackgroundKey = VDependencyManagerAccentColorKey

    override var selected: Bool {
        didSet {
            updateCellBackgroundColor(to: contentView, selectedColor: dependencyManager?.colorForKey(selectedBackgroundKey), isSelected: selected)
        }
    }

    /// Update background color regarding to the cell being selected or not
    func updateCellBackgroundColor(to backgroundContainer: UIView, selectedColor color: UIColor?, isSelected: Bool) {
        if isSelected {
            backgroundContainer.backgroundColor = color
        } else {
            backgroundContainer.backgroundColor = nil
        }
    }

    // MARK: - Private methods

    private func applyTemplateAppearance(with dependencyManager: VDependencyManager) {
        titleLabel.textColor = dependencyManager.colorForKey(titleColorKey)
        titleLabel.font = dependencyManager.fontForKey(itemFontKey)
    }
}
