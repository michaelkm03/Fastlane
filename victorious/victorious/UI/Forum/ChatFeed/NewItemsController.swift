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

class NewItemsController: NSObject, VBackgroundContainer {
    
    let largeNumberFormatter = VLargeNumberFormatter()
    
    var depedencyManager: VDependencyManager! {
        didSet {
            depedencyManager.addBackgroundToBackgroundHost(self)
            button.titleLabel?.font = depedencyManager.font
            button.titleLabel?.textColor = depedencyManager.textColor
        }
    }
    
    private(set) var isShowing: Bool = true
    
    var count: Int = 0 {
        didSet {
            let buttonTitle = localizedButtonTitle(count: count)
            setButtonTitle(buttonTitle)
        }
    }
    
    func backgroundContainerView() -> UIView {
        return container
    }
    
    weak var delegate: NewItemsControllerDelegate?
    
    @IBOutlet private weak var button: UIButton!
    @IBOutlet private weak var container: UIView!
    
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
    
    @IBAction private func onNewItemsSelected() {
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
    
    private func setButtonTitle(title: String) {
        let attributes = [ NSFontAttributeName: button.titleLabel!.font ]
        let attributedText = NSAttributedString(string: title, attributes: attributes)
        button.setAttributedTitle( attributedText, forState: .Normal)
    }
}

private extension VDependencyManager {
    
    var textColor: UIColor {
        return colorForKey("color.newItems.text")
    }
    
    var font: UIFont {
        return fontForKey("font.newItems")
    }
}
