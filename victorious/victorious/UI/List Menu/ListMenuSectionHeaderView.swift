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
        static let subscribeButtonXMargin = CGFloat(12.0)
    }
    
    @IBOutlet private var titleLabel: UILabel?
    
    static var preferredHeight: CGFloat {
        return 18
    }
    
    var dependencyManager: VDependencyManager! {
        didSet {
            applyTemplateAppearance(with: dependencyManager)
            addSubscribeButtonIfNeeded(with: dependencyManager)
        }
    }
    
    private func applyTemplateAppearance(with dependencyManager: VDependencyManager) {
        clipsToBounds = false
        titleLabel?.text = dependencyManager.titleText
        titleLabel?.textColor = dependencyManager.titleColor
        titleLabel?.font = dependencyManager.titleFont
    }
    
    // MARK: - Subscribe Button
    
    var isSubscribeButtonHidden: Bool = true {
        didSet {
            subscribeButton?.hidden = isSubscribeButtonHidden
        }
    }
    
    private(set) var subscribeButton: SubscribeButton?

    private func addSubscribeButtonIfNeeded(with dependencyManager: VDependencyManager) {
        if subscribeButton == nil {
            let subscribeButton = SubscribeButton(dependencyManager: dependencyManager)
            addSubview(subscribeButton)
            subscribeButton.translatesAutoresizingMaskIntoConstraints = false
            centerYAnchor.constraintEqualToAnchor(subscribeButton.centerYAnchor).active = true
            trailingAnchor.constraintEqualToAnchor(subscribeButton.trailingAnchor, constant: Constants.subscribeButtonXMargin).active = true
            
            self.subscribeButton = subscribeButton
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
