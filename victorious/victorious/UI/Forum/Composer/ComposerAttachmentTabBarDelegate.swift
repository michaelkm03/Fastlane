//
//  ComposerAttachmentTabBarDelegate.swift
//  victorious
//
//  Created by Sharif Ahmed on 3/16/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

protocol ComposerAttachmentTabBarDelegate: class {
    func composerAttachmentTabBar(_ composerAttachmentTabBar: ComposerAttachmentTabBar, didSelectNavigationItem navigationItem: VNavigationMenuItem, fromButton button: UIButton)
}
