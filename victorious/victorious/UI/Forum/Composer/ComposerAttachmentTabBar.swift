//
//  ComposerAttachmentTabBar.swift
//  victorious
//
//  Created by Sharif Ahmed on 3/14/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class ComposerAttachmentTabBar: VFlexBar {
    
    private let buttonSideLength: CGFloat = 22
    
    weak var delegate: ComposerAttachmentTabBarDelegate?
    
    private var navigationMenuItems: [VNavigationMenuItem]?
    
    private var maxNumberOfMenuItems: Int = 0
    
    var tabItemTintColor: UIColor? = nil {
        didSet {
            updateTintColorOfButtons()
        }
    }
    
    func setupWithAttachmentMenuItems(navigationMenuItems: [VNavigationMenuItem]?, maxNumberOfMenuItems: Int) {
        
        self.navigationMenuItems = navigationMenuItems
        self.maxNumberOfMenuItems = maxNumberOfMenuItems
        
        updateActionItems()
    }
    
    private func updateActionItems() {
        
        var actionItems: [UIView] = [UIView]()
        
        guard let navigationMenuItems = navigationMenuItems where maxNumberOfMenuItems != 0 else {
            self.actionItems = actionItems
            return
        }
        
        for (index, navigationMenuItem) in navigationMenuItems.enumerate() {
            if index == maxNumberOfMenuItems {
                break
            }
            
            let button = ComposerAttachmentTabBarButton(navigationMenuItem: navigationMenuItem)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.v_addWidthConstraint(buttonSideLength)
            button.v_addHeightConstraint(bounds.height)
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
        
        self.actionItems = actionItems
        
        updateTintColorOfButtons()
    }
    
    private func updateTintColorOfButtons() {
        var buttons = [UIButton]()
        for view in actionItems {
            if let button = view as? UIButton {
                buttons.append(button)
            }
        }
        
        guard !buttons.isEmpty else {
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
    
    @objc private func buttonPressed(button: ComposerAttachmentTabBarButton) {
        delegate?.composerAttachmentTabBar(self, selectedNavigationItem: button.navigationMenuItem)
    }
}
