//
//  StageViewController.swift
//  victorious
//
//  Created by Sharif Ahmed on 3/1/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class StageViewController: UIViewController, Stage, AttributionBarDelegate, CaptionBarViewControllerDelegate {
    private struct Constants {
        static let contentSizeAnimationDuration: NSTimeInterval = 0.5
        static let defaultAspectRatio: CGFloat = 16 / 9
        
        static let pillInsets = UIEdgeInsetsMake(10, 10, 10, 10)
        static let pillHeight: CGFloat = 30
        static let pillBottomMargin: CGFloat = 20
    }
    
    private lazy var defaultStageHeight: CGFloat = {
        return self.view.bounds.width / Constants.defaultAspectRatio
    }()

    @IBOutlet private var mediaContentView: MediaContentView! {
        didSet {
            mediaContentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapOnContent)))
        }
    }
    @IBOutlet private var attributionBar: AttributionBar! {
        didSet {
            attributionBar.hidden = true
            attributionBar.delegate = self
            updateAttributionBarAppearance(with: dependencyManager)
        }
    }
    @IBOutlet private var captionBarHeightConstraint: NSLayoutConstraint! {
        didSet {
            captionBarHeightConstraint.constant = 0
        }
    }
    private var captionBarViewController: CaptionBarViewController? {
        didSet {
            let captionBarDependency = dependencyManager.captionBarDependency
            let hasCaptionBar = captionBarDependency != nil
            captionBarViewController?.delegate = hasCaptionBar ? self : nil
            captionBarViewController?.dependencyManager = captionBarDependency
        }
    }
    
    private var visible = true {
        didSet {
            updateStageHeight()
        }
    }
    
    private lazy var newItemPill: TextOnColorButton? = { [weak self] in
        guard let pillDependency = self?.dependencyManager.newItemButtonDependency else {
            return nil
        }
        let pill = TextOnColorButton()
        pill.dependencyManager = pillDependency
        pill.contentEdgeInsets = Constants.pillInsets
        pill.sizeToFit()
        pill.clipsToBounds = true
        pill.hidden = true
        pill.roundingType = .pill
        
        if let strongSelf = self {
            pill.addTarget(strongSelf, action: #selector(onPillSelect), forControlEvents: .TouchUpInside)
        }
        
        return pill
    }()
    
    private var hasShownStage: Bool = false
    private var queuedContent: ContentModel?
    private var stageDataSource: StageDataSource?
    
    weak var delegate: StageDelegate?
    var dependencyManager: VDependencyManager! {
        didSet {
            // The data source is initialized with the dependency manager since it needs URLs in the template to operate.
            stageDataSource = setupDataSource(dependencyManager)
        }
    }
    
    var canHandleCaptionContent: Bool {
        return dependencyManager.captionBarDependency != nil
    }
    
    // MARK: - Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        captionBarViewController = childViewControllers.flatMap({ $0 as? CaptionBarViewController }).first
        
        guard let newItemPill = newItemPill else {
            return
        }
        
        view.addSubview(newItemPill)
        view.v_addPinToBottomToSubview(newItemPill, bottomMargin: Constants.pillBottomMargin)
        view.v_addCenterHorizontallyConstraintsToSubview(newItemPill)
        newItemPill.v_addHeightConstraint(Constants.pillHeight)
        mediaContentView.dependencyManager = dependencyManager
    }
    
    private func setupDataSource(dependencyManager: VDependencyManager) -> StageDataSource {
        let dataSource = StageDataSource(dependencyManager: dependencyManager)
        dataSource.delegate = self
        return dataSource
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        mediaContentView.allowsVideoControls = false
        showStage(animated)
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        hideStage(animated)
    }
    
    @objc private func didTapOnContent() {
        guard let targetContent = mediaContentView.content else {
            return
        }
        
        let router = Router(originViewController: self, dependencyManager: dependencyManager)
        let destination = DeeplinkDestination(content: targetContent)
        router.navigate(to: destination)
    }
    
    // MARK: - Stage
    
    func addCaptionContent(content: ContentModel) {
        guard let text = content.text else {
            return
        }
        captionBarViewController?.populate(content.author, caption: text)
    }
    
    func addContent(stageContent: ContentModel) {
        queuedContent = stageContent
        if
            !hasShownStage ||
            mediaContentView.content?.type != .video ||
            newItemPill == nil
        {
            // If the stage was not shown, 
            // or if the current content was one that is not time based (video for now),
            // or if we don't have a pill (for VIP stage)
            // we will immediately move to the next content.
            hasShownStage = true
            updateStageHeight()
            nextContent()
        }
        else {
            showPill()
        }
    }
    
    func nextContent() {
        hidePill()
        guard let stageContent = queuedContent else {
            return
        }
        
        mediaContentView.videoCoordinator?.pauseVideo()
        mediaContentView.content = stageContent
        
        attributionBar.configure(with: stageContent.author)
        
        updateStageHeight()
        queuedContent = nil
    }
    
    func onPillSelect() {
        nextContent()
        hidePill()
    }

    func removeContent() {
        hidePill()
        hideStage()
        hasShownStage = false
        queuedContent = nil
    }
    
    func interpolateAlongSideShrinking(percentage: CGFloat) {
        captionBarViewController?.view.alpha = 1 - percentage
        attributionBar.alpha = 1 - percentage
        newItemPill?.alpha = 1 - percentage
    }
    
    private func hidePill() {
        guard
            let newItemPill = newItemPill
            where newItemPill.hidden == false
        else {
            return
        }
        
        UIView.animateWithDuration(0.5, animations: {
            newItemPill.alpha = 0.0
        }) { _ in
            newItemPill.hidden = true
        }
    }
    
    private func showPill() {
        guard
            let newItemPill = newItemPill
            where newItemPill.hidden == true
        else {
            return
        }
        
        newItemPill.alpha = 0.0
        newItemPill.hidden = false
        UIView.animateWithDuration(0.5, animations: {
            newItemPill.alpha = 1.0
        })
    }

    // MARK: - ForumEventReceiver
    
    var childEventReceivers: [ForumEventReceiver] {
        return [stageDataSource].flatMap { $0 }
    }

    // MARK: - Show/Hide Stage
    
    private func hideStage(animated: Bool = false) {
        mediaContentView.hideContent(animated: animated)
        visible = false
        UIView.animateWithDuration(animated ? Constants.contentSizeAnimationDuration : 0) {
            self.view.layoutIfNeeded()
        }
    }
    
    private func showStage(animated: Bool = false) {
        mediaContentView.showContent(animated: animated)
        visible = true
        UIView.animateWithDuration(animated ? Constants.contentSizeAnimationDuration : 0) {
            self.view.layoutIfNeeded()
        }
    }
    
    // MARK: - Attribution Bar
    
    private func updateAttributionBarAppearance(with dependencyManager: VDependencyManager?) {
        let attributionBarDependency = dependencyManager?.attributionBarDependency
        attributionBar.hidden = attributionBarDependency == nil
        attributionBar.dependencyManager = attributionBarDependency
    }
    
    func didTapOnUser(user: UserModel) {
        let router = Router(originViewController: self, dependencyManager: dependencyManager)
        let destination = DeeplinkDestination(userID: user.id)
        router.navigate(to: destination)
    }
    
    // MARK: - CaptionBarViewControllerDelegate
    
    func captionBarViewController(captionBarViewController: CaptionBarViewController, didTapOnUser user: UserModel) {
        ShowProfileOperation(originViewController: self, dependencyManager: dependencyManager, userId: user.id).queue()
    }
    
    func captionBarViewController(captionBarViewController: CaptionBarViewController, wantsUpdateToContentHeight height: CGFloat) {
        captionBarHeightConstraint.constant = height
        updateStageHeight()
    }
    
    // MARK: - View updating
    
    private func updateStageHeight() {
        var height = captionBarHeightConstraint.constant
        if visible {
            height += defaultStageHeight
        }
        delegate?.stage(self, wantsUpdateToContentHeight: height)
    }
}

private extension VDependencyManager {
    var attributionBarDependency: VDependencyManager? {
        return childDependencyForKey("attributionBar")
    }
    
    var captionBarDependency: VDependencyManager? {
        return childDependencyForKey("captionBar")
    }
    
    var newItemButtonDependency: VDependencyManager? {
        return childDependencyForKey("newItemButton")
    }
}
