//
//  ComposerAttachmentTabBar.swift
//  victorious
//
//  Created by Sharif Ahmed on 3/14/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class ComposerAttachmentTabBar: VFlexBar {
    
    weak var delegate: ComposerAttachmentTabBarDelegate?
    
    var tabItemTintColor: UIColor? = nil {
        didSet {
            
            var buttons = [UIButton]()
            for view in actionItems {
                if let button = view as? UIButton {
                    buttons.append(button)
                }
            }
            
            guard buttons.count > 0 else {
                return
            }
            
            let renderingMode: UIImageRenderingMode = tabItemTintColor != nil ? .AlwaysTemplate : .AlwaysOriginal
            for button in buttons {
                let updatedImage = button.imageForState(.Normal)?.imageWithRenderingMode(renderingMode)
                button.setImage(updatedImage, forState: .Normal)
                if let tabItemTintColor = tabItemTintColor {
                    button.tintColor = tabItemTintColor
                }
            }
        }
    }
    
    func setupWithAttachmentMenuItems(navigationMenuItems: [VNavigationMenuItem]?, maxNumberOfMenuItems: Int) {
        
        var actionItems = [UIView]()
        
        guard let navigationMenuItems = navigationMenuItems else {
            self.actionItems = actionItems
            return
        }
        
        let buttonSideLength = bounds.height
        for (index, navigationMenuItem) in navigationMenuItems.enumerate() {
            if index == maxNumberOfMenuItems {
                break
            }
            
            let button = ComposerAttachmentTabBarButton(navigationMenuItem: navigationMenuItem)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.v_addWidthConstraint(buttonSideLength)
            button.v_addHeightConstraint(buttonSideLength)
            button.addTarget(self, action: Selector("buttonPressed:"), forControlEvents: .TouchUpInside)
            actionItems.append(button)
            actionItems.append(ActionBarFlexibleSpaceItem.flexibleSpaceItem())
        }
        
        // Since every action item has an accompanying space item, we should have twice as
        // many action items as the max number of menu items to be properly laid out.
        while actionItems.count / 2 < maxNumberOfMenuItems {
            actionItems.append(VActionBarFixedWidthItem(width: buttonSideLength))
            actionItems.append(ActionBarFlexibleSpaceItem.flexibleSpaceItem())
        }
        actionItems.removeLast()
        
        self.actionItems = actionItems
    }
    
    @objc private func buttonPressed(button: ComposerAttachmentTabBarButton) {
        delegate?.composerAttachmentTabBar(self, selectedNavigationItem: button.navigationMenuItem)
    }
}
