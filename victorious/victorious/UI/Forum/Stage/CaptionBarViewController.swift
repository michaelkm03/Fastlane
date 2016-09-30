//
//  CaptionBarViewController.swift
//  victorious
//
//  Created by Sharif Ahmed on 6/27/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

protocol CaptionBarViewControllerDelegate: class {
    func captionBarViewController(_ captionBarViewController: CaptionBarViewController, didTapOnUser user: UserModel)
    func captionBarViewController(_ captionBarViewController: CaptionBarViewController, wantsUpdateToContentHeight height: CGFloat)
}

/// Shows and manages the display of a bar showing a user's avatar, text they've posted, and,
/// when appropriate, an expansion button to allow all of the text to be scrolled through.
class CaptionBarViewController: UIViewController {
    @IBOutlet fileprivate weak var captionBar: CaptionBar!
    fileprivate var displayingUser: UserModel?
    fileprivate var isShowingCaption: Bool {
        return displayingUser != nil
    }
    fileprivate let fadeDuration = TimeInterval(0.75)
    weak var delegate: CaptionBarViewControllerDelegate?
    
    fileprivate var captionBarDecorator: CaptionBarDecorator? {
        didSet {
            guard isViewLoaded else {
                return
            }
            captionBarDecorator?.decorate(captionBar)
        }
    }
    
    fileprivate var captionIsExpanded = false {
        didSet {
            var desiredHeight: CGFloat = 0
            let captionVisible = isViewLoaded && isShowingCaption
            if captionVisible {
                desiredHeight = CaptionBarPopulator.toggle(captionBar, toCollapsed: !captionIsExpanded)
            }
            delegate?.captionBarViewController(self, wantsUpdateToContentHeight: desiredHeight)
        }
    }
    
    var dependencyManager: VDependencyManager? {
        didSet {
            guard let dependencyManager = dependencyManager else {
                captionBarDecorator = nil
                return
            }
            captionBarDecorator = CaptionBarDecorator(dependencyManager: dependencyManager)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        captionBarDecorator?.decorate(captionBar)
        
        captionBar.captionTextView.alpha = 0
        captionBar.captionLabel.alpha = 0
    }
    
    // MARK: - Public
    
    func populate(_ user: UserModel, caption: String) {
        displayingUser = user
        CaptionBarPopulator.populate(captionBar, withUser: user, andCaption: caption) { [weak self] in
            self?.captionIsExpanded = false
        }
    }
    
    // MARK: - Actions
    
    @IBAction fileprivate func pressedToggleButton() {
        captionIsExpanded = !captionIsExpanded
    }
    
    @IBAction fileprivate func pressedAvatarButton() {
        guard let displayingUser = displayingUser else {
            return
        }
        delegate?.captionBarViewController(self, didTapOnUser: displayingUser)
    }
}
