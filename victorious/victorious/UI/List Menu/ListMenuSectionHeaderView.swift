//
//  ListMenuSectionHeaderView.swift
//  victorious
//
//  Created by Tian Lan on 4/20/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class ListMenuSectionHeaderView: UICollectionReusableView {
    fileprivate struct Constants {
        static let accessoryButtonXMargin = CGFloat(12.0)
    }
    
    @IBOutlet fileprivate weak var titleLabel: UILabel!
    
    var dependencyManager: VDependencyManager! {
        didSet {
            applyTemplateAppearance(with: dependencyManager)
        }
    }
    
    fileprivate func applyTemplateAppearance(with dependencyManager: VDependencyManager) {
        clipsToBounds = false
        titleLabel.text = dependencyManager.titleText
        titleLabel.textColor = dependencyManager.titleColor
        titleLabel.font = dependencyManager.titleFont
    }
    
    static var preferredHeight: CGFloat {
        return 18
    }
    
    var accessoryView: UIView? {
        didSet {
            guard accessoryView !== oldValue else {
                return
            }
            
            oldValue?.removeFromSuperview()
            
            if let accessoryButton = accessoryView {
                addSubview(accessoryButton)
                accessoryButton.translatesAutoresizingMaskIntoConstraints = false
                centerYAnchor.constraint(equalTo: accessoryButton.centerYAnchor).isActive = true
                trailingAnchor.constraint(equalTo: accessoryButton.trailingAnchor, constant: Constants.accessoryButtonXMargin).isActive = true
            }
        }
    }
}

private extension VDependencyManager {
    var titleColor: UIColor? {
        return color(forKey: VDependencyManagerMainTextColorKey)
    }
    
    var titleFont: UIFont? {
        return font(forKey: VDependencyManagerHeaderFontKey)
    }
    
    var titleText: String {
        return string(forKey: "title") ?? ""
    }
}
