//
//  CaptionBarViewController.swift
//  victorious
//
//  Created by Sharif Ahmed on 6/27/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

protocol CaptionBarViewControllerDelegate: class {
    func didTapOnUser(user: UserModel)
    func wantsUpdateToContentHeight(height: CGFloat)
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
            guard isViewLoaded() && isShowingCaption else {
                delegate?.wantsUpdateToContentHeight(0)
                return
            }
            
            let desiredHeight = CaptionBarPopulator.toggle(captionBar, toCollapsed: !captionIsExpanded)
            delegate?.wantsUpdateToContentHeight(desiredHeight)
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
    
    func populate(user: UserModel, caption: String) {
        displayingUser = user
        CaptionBarPopulator.populate(captionBar, withUser: user, andCaption: caption)
        captionIsExpanded = false
    }
    
    func reset() {
        displayingUser = nil
        captionIsExpanded = false
    }
}
