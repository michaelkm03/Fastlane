//
//  NewListMenuSectionCell.swift
//  victorious
//
//  Created by Alex Tamoykin on 9/23/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

class NewListMenuSectionCell: UICollectionViewCell {

    // MARK: - Outlets

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var avatarView: AvatarView!
    @IBOutlet weak var titleLabelToAvatarViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleLabelToViewLeadingConstraint: NSLayoutConstraint!

    var avatarViewHidden = true {
        didSet {
            if avatarViewHidden == true {
                avatarView.hidden = true
                titleLabelToAvatarViewLeadingConstraint.active = false
                titleLabelToViewLeadingConstraint.active = true
            }
            else {
                avatarView.hidden = false
                titleLabelToAvatarViewLeadingConstraint.active = true
                titleLabelToViewLeadingConstraint.active = false
            }
        }
    }

    // MARK: - Cell Configuration

    /// Preferred height of the type of cell according to design spec
    static var preferredHeight: CGFloat = 38

    var dependencyManager: VDependencyManager? {
        didSet {
            if let dependencyManager = dependencyManager {
                applyTemplateAppearance(with: dependencyManager)
            }
        }
    }

    var titleColorKey = "color.text.navItem"
    var itemFontKey = VDependencyManagerParagraphFontKey
    var selectedBackgroundKey = VDependencyManagerAccentColorKey

    override var selected: Bool {
        didSet {
            updateCellBackgroundColor(to: contentView, selectedColor: dependencyManager?.selectedBackgroundColor, isSelected: selected)
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
        titleLabel.textColor = dependencyManager.titleColor
        titleLabel.font = dependencyManager.itemFont
    }
}

private extension VDependencyManager {
    var itemFont: UIFont? {
        return fontForKey(VDependencyManagerParagraphFontKey)
    }

    var selectedBackgroundColor: UIColor? {
        return colorForKey(VDependencyManagerAccentColorKey)
    }

    var titleColor: UIColor? {
        return colorForKey("color.text.navItem")
    }
}
