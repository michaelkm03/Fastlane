//
//  ComposerAttachmentTabBar.swift
//  victorious
//
//  Created by Sharif Ahmed on 3/14/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class ComposerAttachmentTabBar: VFlexBar {
    
    fileprivate struct Constants {
        static let buttonSideLength: CGFloat = 22
        static let expandedHeight: CGFloat = 53
    }
    
    weak var delegate: ComposerAttachmentTabBarDelegate?
    
    var buttonsEnabled: Bool = true {
        didSet {
            let buttonItems = buttons()
            for button in buttonItems {
                button.isEnabled = buttonsEnabled
            }
        }
    }
    
    var tabItemDeselectedTintColor: UIColor? = nil {
        didSet {
            updateTintColorOfButtons()
        }
    }
    
    var tabItemSelectedTintColor: UIColor? = nil {
        didSet {
            updateTintColorOfButtons()
        }
    }
    
    func setupWithAttachmentMenuItems(_ navigationMenuItems: [VNavigationMenuItem]?, maxNumberOfMenuItems: Int) {
        
        var actionItems = [UIView]()
        
        guard let navigationMenuItems = navigationMenuItems else {
            self.actionItems = actionItems
            return
        }
        
        for (index, navigationMenuItem) in navigationMenuItems.enumerated() {
            if index == maxNumberOfMenuItems {
                break
            }
            
            let button = ComposerAttachmentTabBarButton(navigationMenuItem: navigationMenuItem)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.v_addWidthConstraint(Constants.buttonSideLength)
            button.v_addHeightConstraint(Constants.expandedHeight)
            button.addTarget(self, action: #selector(buttonPressed(_: )), for: .touchUpInside)
            actionItems.append(button)
            actionItems.append(ActionBarFlexibleSpaceItem.flexibleSpaceItem())
        }
        
        // Since every action item has an accompanying space item, we should have twice as
        // many action items as the max number of menu items to be properly laid out.
        while actionItems.count / 2 < maxNumberOfMenuItems {
            actionItems.append(VActionBarFixedWidthItem(width: Constants.buttonSideLength))
            actionItems.append(ActionBarFlexibleSpaceItem.flexibleSpaceItem())
        }
        
        self.actionItems = actionItems
        
        updateTintColorOfButtons()
    }
    
    fileprivate func updateTintColorOfButtons() {
        let buttonItems = buttons()
        let renderingMode: UIImageRenderingMode = tabItemDeselectedTintColor != nil ? .alwaysTemplate : .alwaysOriginal
        for button in buttonItems {
            let updatedImage = button.image(for: .normal)?.withRenderingMode(renderingMode)
            button.setImage(updatedImage, for: .normal)
            if let tabItemTintColor = tabItemDeselectedTintColor {
                button.tintColor = tabItemTintColor
            }
        }
    }
    
    func setButtonEnabled(_ enabled: Bool, forIdentifier identifier: String) {
        for button in buttons() {
            if (button.navigationMenuItem.identifier == identifier) {
                button.isEnabled = enabled
            }
        }
    }
    
    @objc fileprivate func buttonPressed(_ button: ComposerAttachmentTabBarButton) {
        delegate?.composerAttachmentTabBar(self, didSelectNavigationItem: button.navigationMenuItem, fromButton: button)
        button.navigationMenuItem.dependencyManager.trackButtonEvent(.tap)
    }
    
    fileprivate func buttons() -> [ComposerAttachmentTabBarButton] {
        let buttons = actionItems.filter { (item: AnyObject) -> Bool in
            type(of: item) == ComposerAttachmentTabBarButton.self
        }
        return buttons as? [ComposerAttachmentTabBarButton] ?? []
    }
}
