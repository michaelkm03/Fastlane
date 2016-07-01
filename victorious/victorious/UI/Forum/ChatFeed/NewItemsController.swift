//
//  NewItemsController.swift
//  victorious
//
//  Created by Patrick Lynch on 2/24/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

@objc protocol NewItemsControllerDelegate {
    func onNewItemsSelected()
}

class NewItemsController: NSObject {
    private struct Constants {
        static let pillInsets = UIEdgeInsetsMake(10, 10, 10, 10)
        static let pillHeight: CGFloat = 30
        static let pillBottomMargin: CGFloat = 20
    }
    
    let largeNumberFormatter = VLargeNumberFormatter()
    
    var dependencyManager: VDependencyManager! {
        didSet {
            newItemIndicator.dependencyManager = dependencyManager?.newItemButtonDependency
            newItemIndicator.contentEdgeInsets = Constants.pillInsets
            newItemIndicator.roundingType = .pill
            newItemIndicator.addTarget(self, action: #selector(onNewItemsSelected), forControlEvents: .TouchUpInside)
        }
    }
    
    private(set) var isShowing: Bool = true
    
    var count: Int = 0 {
        didSet {
            if oldValue != count {
                let title = localizedButtonTitle(count: count)
                newItemIndicator?.setTitle(title, forState: .Normal)
            }
            if count == 0 {
                hide()
            }
        }
    }
    
    weak var delegate: NewItemsControllerDelegate?
    
    @IBOutlet private weak var container: UIView!
    @IBOutlet private weak var newItemIndicator: TextOnColorButton!
    
    private var containerHeightFromStoryboard: CGFloat?
    @IBOutlet private weak var containerHeight: NSLayoutConstraint! {
        didSet {
            containerHeightFromStoryboard = containerHeight.constant
        }
    }
    
    func show(animated animated: Bool = true) {
        guard !isShowing else {
            return
        }
        isShowing = true
        let animations = {
            guard let bottomConstant = self.containerHeightFromStoryboard else {
                assertionFailure("`containerHeightFromStoryboard` must be set as soon as this class is instantiated from a storyboard.")
                return
            }
            self.containerHeight.constant = bottomConstant
            self.container.superview?.layoutIfNeeded()
        }
        if animated {
            UIView.animateWithDuration(0.75,
                delay: 0.0,
                usingSpringWithDamping: 0.5,
                initialSpringVelocity: 0.5,
                options: [.LayoutSubviews],
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
            self.containerHeight.constant = 0.0
            self.container.superview?.layoutIfNeeded()
        }
        let completion = { (_: Bool) in
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
    
    // MARK: - Private
    
    @objc private func onNewItemsSelected() {
        delegate?.onNewItemsSelected()
        hide()
    }
    
    private func localizedButtonTitle(count count: Int) -> String {
        let formattedMessageCount: String = largeNumberFormatter.stringForInteger(count)
        let title: String
        if count == 1 {
            let localizedFormat = NSLocalizedString("NewMessagesFormatSingular", comment: "")
            title = NSString(format: localizedFormat, formattedMessageCount) as String
        } else {
            let localizedFormat = NSLocalizedString("NewMessagesFormatPlural", comment: "")
            title = NSString(format: localizedFormat, formattedMessageCount) as String
        }
        return title
    }
}

private extension VDependencyManager {
    var newItemButtonDependency: VDependencyManager? {
        return childDependencyForKey("newItemButton")
    }
}
