//
//  ListMenuSectionHeaderView.swift
//  victorious
//
//  Created by Tian Lan on 4/20/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class ListMenuSectionHeaderView: UICollectionReusableView {
    private struct Constants {
        static let accessoryButtonXMargin = CGFloat(12.0)
    }
    
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
                accessoryButton.translatesAutoresizingMaskIntoConstraints = false
                centerYAnchor.constraintEqualToAnchor(accessoryButton.centerYAnchor).active = true
                trailingAnchor.constraintEqualToAnchor(accessoryButton.trailingAnchor, constant: Constants.accessoryButtonXMargin).active = true
            }
        }
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
