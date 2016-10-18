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
        
        static let openAnimationDuration: Double = 0.75
        static let closeAnimationDuration: Double = 0.2
    }
    
    let largeNumberFormatter = VLargeNumberFormatter()
    
    var dependencyManager: VDependencyManager! {
        didSet {
            newItemIndicator.dependencyManager = dependencyManager?.newItemButtonDependency
            newItemIndicator.contentEdgeInsets = Constants.pillInsets
            newItemIndicator.roundingType = .pill
            newItemIndicator.addTarget(self, action: #selector(onNewItemsSelected), for: .touchUpInside)
        }
    }
    
    private(set) var isShowing: Bool = true
    
    var count: Int = 0 {
        didSet {
            if oldValue != count {
                let title = localizedButtonTitle(count: count)
                newItemIndicator?.setTitle(title, for: UIControlState())
            }
            if count == 0 {
                hide()
            }
        }
    }
    
    weak var delegate: NewItemsControllerDelegate?
    
    @IBOutlet private weak var container: VPassthroughContainerView!
    @IBOutlet private weak var newItemIndicator: TextOnColorButton!
    
    func show(animated: Bool = true) {
        guard !isShowing else {
            return
        }
        isShowing = true
        let animations = {
            self.newItemIndicator.transform = CGAffineTransform(scaleX: 1, y: 1)
        }
        if animated {
            UIView.animate(withDuration: Constants.openAnimationDuration,
                delay: 0.0,
                usingSpringWithDamping: 0.5,
                initialSpringVelocity: 0.5,
                options: [.layoutSubviews],
                animations: animations,
                completion: nil
            )
        } else {
            animations()
        }
    }
    
    func hide(animated: Bool = true) {
        guard isShowing else {
            return
        }
        let animations = {
            self.newItemIndicator.transform = CGAffineTransform(scaleX: 0, y: 0)
        }
        let completion = { (_: Bool) in
            self.count = 0
            self.isShowing = false
        }
        if animated {
            UIView.animate(withDuration: Constants.closeAnimationDuration,
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
        newItemIndicator.dependencyManager?.track(.tap)
        delegate?.onNewItemsSelected()
        hide()
    }
    
    private func localizedButtonTitle(count: Int) -> String {
        let formattedMessageCount: String = largeNumberFormatter.string(for: count)
        let title: String
        if count == 1 {
            let localizedFormat = NSLocalizedString("NewMessagesFormatSingular", comment: "")
            title = NSString(format: localizedFormat as NSString, formattedMessageCount) as String
        } else {
            let localizedFormat = NSLocalizedString("NewMessagesFormatPlural", comment: "")
            title = NSString(format: localizedFormat as NSString, formattedMessageCount) as String
        }
        return title
    }
}

private extension VDependencyManager {
    var newItemButtonDependency: VDependencyManager? {
        return childDependency(forKey: "newItemButton")
    }
}
