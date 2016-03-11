//
//  MoreContentController.swift
//  victorious
//
//  Created by Patrick Lynch on 2/24/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

@objc protocol MoreContentControllerDelegate: class {
    func onMoreContentSelected()
}

class MoreContentController: NSObject {
    
    let largeNumberFormatter = VLargeNumberFormatter()
    
    var depedencyManager: VDependencyManager! {
        didSet {
            button.backgroundColor = depedencyManager.colorForKey(VDependencyManagerAccentColorKey)
        }
    }
    
    private(set) var isShowing: Bool = true
    
    var count: Int = 0 {
        didSet {
            let formattedMessageCount = largeNumberFormatter.stringForInteger(count)
            let title = "\(formattedMessageCount) New Messages"
            UIView.setAnimationsEnabled(false)
            self.button.setTitle(title, forState: .Normal)
            UIView.setAnimationsEnabled(true)
            
            let attributes = [ NSFontAttributeName : button.titleLabel!.font ]
            buttonWidthConstraint.constant = (title as NSString).sizeWithAttributes( attributes ).width
            button.layoutIfNeeded()
        }
    }
    @IBOutlet weak var delegate: MoreContentControllerDelegate?
    
    @IBOutlet weak var buttonWidthConstraint: NSLayoutConstraint!
    
    @IBOutlet private weak var button: UIButton! {
        didSet {
            button.layer.shadowColor = UIColor.blackColor().CGColor
            button.layer.shadowRadius = 4.0
            button.layer.shadowOpacity = 1.0
            button.layer.shadowOffset = CGSize(width:0, height:2)
        }
    }
    @IBOutlet private weak var buttonToBottomConstraint: NSLayoutConstraint! {
        didSet {
            moreContentnButtonToBottomStoryboardValue = buttonToBottomConstraint.constant
        }
    }
    
    private var moreContentnButtonToBottomStoryboardValue: CGFloat!
    
    func show(animated animated: Bool = true) {
        guard !isShowing else {
            return
        }
        isShowing = true
        let animations = {
            self.buttonToBottomConstraint.constant = self.moreContentnButtonToBottomStoryboardValue
            self.button.layoutIfNeeded()
        }
        if animated {
            UIView.animateWithDuration(0.4,
                delay: 0.0,
                usingSpringWithDamping: 0.5,
                initialSpringVelocity: 0.5,
                options: [],
                animations: animations,
                completion: nil
            )
        } else {
            animations()
        }
    }
    
    func hide(animated animated: Bool = true) {
        guard isShowing else {
            return
        }
        let animations = {
            self.buttonToBottomConstraint.constant = -self.button.bounds.height
            self.button.layoutIfNeeded()
        }
        let completion = { (_:Bool) in
            self.count = 0
            self.isShowing = false
        }
        if animated {
            UIView.animateWithDuration(0.2,
                delay: 0.0,
                usingSpringWithDamping: 1.0,
                initialSpringVelocity: 0.0,
                options: [],
                animations: animations,
                completion: completion
            )
        } else {
            animations()
            completion(true)
        }
    }
    
    @IBAction private func onMoreContentSelected() {
        delegate?.onMoreContentSelected()
        hide()
    }
}