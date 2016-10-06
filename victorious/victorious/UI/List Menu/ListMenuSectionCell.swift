//
//  ListMenuSectionCell.swift
//  victorious
//
//  Created by Alex Tamoykin on 9/23/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

class ListMenuSectionCell: UICollectionViewCell {

    // MARK: - Outlets

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var avatarView: AvatarView!
    @IBOutlet weak var titleLabelToAvatarViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var titleLabelToViewLeadingConstraint: NSLayoutConstraint!

    var avatarViewHidden = true {
        didSet {
            avatarView.isHidden = avatarViewHidden
            titleLabelToAvatarViewLeadingConstraint.isActive = !avatarViewHidden
            titleLabelToViewLeadingConstraint.isActive = avatarViewHidden
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

    override var isSelected: Bool {
        didSet {
            updateCellBackgroundColor(to: contentView, selectedColor: dependencyManager?.selectedBackgroundColor, isSelected: isSelected)
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
        return font(forKey: VDependencyManagerParagraphFontKey)
    }

    var selectedBackgroundColor: UIColor? {
        return color(forKey: VDependencyManagerAccentColorKey)
    }

    var titleColor: UIColor? {
        return color(forKey: "color.text.navItem")
    }
}
