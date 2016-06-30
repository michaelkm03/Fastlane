//
//  CaptionBarViewController.swift
//  victorious
//
//  Created by Sharif Ahmed on 6/27/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

protocol CaptionBarViewControllerDelegate: class {
    func captionBarViewController(captionBarViewController: CaptionBarViewController, didTapOnUser user: UserModel)
    func captionBarViewController(captionBarViewController: CaptionBarViewController, wantsUpdateToContentHeight height: CGFloat)
}

class CaptionBarViewController: UIViewController {
    
    @IBOutlet private weak var captionBar: CaptionBar!
    private var displayingUser: UserModel?
    private var isShowingCaption: Bool {
        return displayingUser != nil
    }
    private let fadeDuration = NSTimeInterval(0.75)
    weak var delegate: CaptionBarViewControllerDelegate?
    
    private var captionBarDecorator: CaptionBarDecorator? {
        didSet {
            guard isViewLoaded() else {
                return
            }
            captionBarDecorator?.decorate(captionBar)
        }
    }
    
    private var captionIsExpanded = false {
        didSet {
            var desiredHeight: CGFloat = 0
            let captionVisible = isViewLoaded() && isShowingCaption
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
    }
    
    // MARK: - Public
    
    func populate(user: UserModel, caption: String) {
        displayingUser = user
        CaptionBarPopulator.populate(captionBar, withUser: user, andCaption: caption)
        captionIsExpanded = false
    }
    
    func reset() {
        displayingUser = nil
        captionIsExpanded = false
    }
    
    // MARK: - Actions
    
    @IBAction private func pressedToggleButton() {
        captionIsExpanded = !captionIsExpanded
    }
}
