//
//  ListMenuSectionHeaderView.swift
//  victorious
//
//  Created by Tian Lan on 4/20/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class ListMenuSectionHeaderView: UICollectionReusableView {
    
    private static let accessoryButtonHeight = CGFloat(30.0)
    private static let accessoryButtonXPadding = CGFloat(24.0)
    private static let accessoryButtonXMargin = CGFloat(12.0)
    
    @IBOutlet private weak var titleLabel: UILabel!
    
    var dependencyManager: VDependencyManager! {
        didSet {
            applyTemplateAppearance(with: dependencyManager)
        }
    }
    
    private func applyTemplateAppearance(with dependencyManager: VDependencyManager) {
        clipsToBounds = false
        titleLabel.text = dependencyManager.titleText
        titleLabel.textColor = dependencyManager.titleColor
        titleLabel.font = dependencyManager.titleFont
    }
    
    static var preferredHeight: CGFloat {
        return 18
    }
    
    var accessoryButton: UIButton? {
        willSet {
            if newValue == nil {
                accessoryButton?.removeFromSuperview()
            }
        }
        didSet {
            if let accessoryButton = accessoryButton {
                addSubview(accessoryButton)
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        guard let accessoryButton = accessoryButton else {
            return
        }
        
        let buttonSize = CGSize(
            width: accessoryButton.sizeThatFits(bounds.size).width + ListMenuSectionHeaderView.accessoryButtonXPadding,
            height: ListMenuSectionHeaderView.accessoryButtonHeight
        )
        
        accessoryButton.frame = CGRect(
            origin: CGPoint(
                x: bounds.width - buttonSize.width - ListMenuSectionHeaderView.accessoryButtonXMargin,
                y: (bounds.height - buttonSize.height) / 2.0
            ),
            size: buttonSize
        )
    }
}

private extension VDependencyManager {
    
    var titleColor: UIColor? {
        return colorForKey(VDependencyManagerMainTextColorKey)
    }
    
    var titleFont: UIFont? {
        return fontForKey(VDependencyManagerHeaderFontKey)
    }
    
    var titleText: String {
        return stringForKey("title") ?? ""
    }
}
