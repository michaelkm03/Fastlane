//
//  DismissButton.swift
//  victorious
//
//  Created by Tian Lan on 11/18/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import UIKit
import Foundation

@objc (VDismissButton)
class DismissButton: UIButton {
    override init(frame: CGRect) {
        super.init(frame: frame)
        sharedInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        sharedInit()
    }
    
    private struct LayoutConstants {
        static let buttonSize: CGFloat = 44.0
        static let marginFromBorder: CGFloat = 8.0
    }
    
    private func sharedInit() {
        backgroundColor = UIColor.lightGrayColor()
        setImage(UIImage(named: "textClear"), forState: UIControlState.Normal)
        v_addWidthConstraint(LayoutConstants.buttonSize)
        v_addHeightConstraint(LayoutConstants.buttonSize)
    }
}
