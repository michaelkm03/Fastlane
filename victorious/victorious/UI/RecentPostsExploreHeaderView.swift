//
//  RecentPostsExploreHeaderView.swift
//  victorious
//
//  Created by Sharif Ahmed on 9/2/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

/// A header view that displays a stylized title based on the provided dependency manager
class RecentPostsExploreHeaderView: UICollectionReusableView {
    
    static let kTitleKey = "stream.title"
    
    private struct Constants {
        static let baseHeight: CGFloat = 24
    }
    
    var dependencyManager: VDependencyManager? {
        didSet {
            if let dependencyManager = dependencyManager {
                titleLabel.font = dependencyManager.labelTextFont()
                titleLabel.textColor = dependencyManager.labelTextColor()
                if let text = dependencyManager.labelText() {
                    titleLabel.text = String(text)
                }
            }
        }
    }
    let titleLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(titleLabel)
        v_addFitToParentConstraintsToSubview(titleLabel, leading: 11, trailing: 0, top: 0, bottom: 0)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    class func suggestedReuseIdentifier() -> String {
        return StringFromClass(RecentPostsExploreHeaderView)
    }
    
    class func desiredHeight(dependencyManager: VDependencyManager) -> CGFloat {
        var height = Constants.baseHeight
        if let font = dependencyManager.labelTextFont(), text = dependencyManager.labelText() {
            return text.frameSizeForWidth(CGFloat.max, andAttributes: [ NSFontAttributeName : font ]).height
        }
        return height
    }
}

extension VDependencyManager {
    
    func labelTextFont() -> UIFont? {
        return fontForKey(VDependencyManagerHeading2FontKey)
    }
    
    func labelTextColor() -> UIColor? {
        return colorForKey(VDependencyManagerMainTextColorKey)
    }
    
    func labelText() -> NSString? {
        return stringForKey(RecentPostsExploreHeaderView.kTitleKey)
    }
}
