//
//  ListMenuSectionHeaderView.swift
//  victorious
//
//  Created by Tian Lan on 4/20/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class ListMenuSectionHeaderView: UICollectionReusableView {
    
    @IBOutlet private weak var titleLabel: UILabel!
    
    var dependencyManager: VDependencyManager! {
        didSet {
            applyTemplateAppearance(with: dependencyManager)
        }
    }
    
    private func applyTemplateAppearance(with dependencyManager: VDependencyManager) {
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
                v_addPinToTrailingEdgeToSubview(accessoryButton)
                v_addPinToTopBottomToSubview(accessoryButton)
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
