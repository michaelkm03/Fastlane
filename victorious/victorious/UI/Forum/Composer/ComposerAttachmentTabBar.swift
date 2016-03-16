//
//  ComposerAttachmentTabBar.swift
//  victorious
//
//  Created by Sharif Ahmed on 3/14/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class ComposerAttachmentTabBar: VFlexBar {
    
    func setupWithAttachmentTabs(attachmentTabs: [ComposerAttachmentTab]?, maxNumberOfTabs: Int) {
        
        var actionItems: [UIView] = [ActionBarFlexibleSpaceItem.flexibleSpaceItem()]
        
        guard let attachmentTabs = attachmentTabs else {
            self.actionItems = actionItems
            return
        }
        
        let tabBarButtonSize = CGSizeMake(bounds.height, bounds.height)
        for (index, attachmentTab) in attachmentTabs.enumerate() {
            if index == maxNumberOfTabs {
                break
            }
            
            let button = ComposerAttachmentTabBarButton(composerAttachmentTab: attachmentTab)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.v_addWidthConstraint(tabBarButtonSize.width)
            actionItems.append(button)
            actionItems.append(ActionBarFlexibleSpaceItem.flexibleSpaceItem())
        }
        
        while actionItems.count / 2 < maxNumberOfTabs {
            actionItems.append(VActionBarFixedWidthItem(width: tabBarButtonSize.width))
            actionItems.append(ActionBarFlexibleSpaceItem.flexibleSpaceItem())
        }
        
        self.actionItems = actionItems
    }
    
    
}
