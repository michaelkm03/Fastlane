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
        
        var actionItems: [UIView] = [VActionBarFlexibleSpaceItem.flexibleSpaceItem()]
        
        guard let attachmentTabs = attachmentTabs else {
            self.actionItems = actionItems
            return
        }
        
        let tabBarButtonSize = CGSizeMake(bounds.height, bounds.height)
        for (index, attachmentTab) in attachmentTabs.enumerate() {
            if index == maxNumberOfTabs {
                break
            }
            
            actionItems.append(ComposerAttachmentTabBarButton(composerAttachmentTab: attachmentTab, size: tabBarButtonSize))
            actionItems.append(VActionBarFlexibleSpaceItem.flexibleSpaceItem())
        }
        
        while actionItems.count < maxNumberOfTabs {
            actionItems.append(VActionBarFixedWidthItem(width: tabBarButtonSize.width))
            actionItems.append(VActionBarFlexibleSpaceItem.flexibleSpaceItem())
        }
        
        self.actionItems = actionItems
    }
    
    
}
