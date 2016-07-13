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

    private var currentContent: ContentModel?
    private var currentStageMetaData: StageMetaData?

    private var stageDataSource: StageDataSource?
    private var enabled = true
    
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
    

    // MARK: - UIViewController Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        captionBarViewController = childViewControllers.flatMap({ $0 as? CaptionBarViewController }).first
        mediaContentView.dependencyManager = dependencyManager
        mediaContentView.allowsVideoControls = false
    }
    
    private func setupDataSource(dependencyManager: VDependencyManager) -> StageDataSource {
        let dataSource = StageDataSource(dependencyManager: dependencyManager)
        dataSource.delegate = self
        return dataSource
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        mediaContentView.videoCoordinator?.playVideo()
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        mediaContentView.videoCoordinator?.pauseVideo()
    }

    // MARK: - Stage
    
    func addCaptionContent(content: ContentModel) {
        guard let text = content.text else {
            return
        }
        captionBarViewController?.populate(content.author, caption: text)
    }
    
    func addContent(stageContent: ContentModel, stageMetaData: StageMetaData? = nil) {
        guard enabled else {
            return
        }
        currentContent = stageContent
        currentStageMetaData = stageMetaData

        attributionBar.configure(with: stageContent.author)

        mediaContentView.videoCoordinator?.pauseVideo()
        mediaContentView.content = stageContent

        updateStageHeight()

        showStage(animated: true)
    }
    
    func removeContent() {
        hideStage()
        currentContent = nil
        currentStageMetaData = nil
    }
    
    func setStageEnabled(enabled: Bool, animated: Bool) {
        self.enabled = enabled
        
        if enabled {
            showStage(animated: animated)
        }
        else {
            hideStage(animated: animated)
        }
    }
    
    var overlayUIAlpha: CGFloat {
        get {
            return attributionBar.alpha
        }
        set {
            captionBarViewController?.view.alpha = newValue
            attributionBar.alpha = newValue
        }
    }
    
    // MARK: - ForumEventReceiver
    
    var childEventReceivers: [ForumEventReceiver] {
        return [stageDataSource].flatMap { $0 }
    }

    // MARK: - Show/Hide Stage

    private func hideStage(animated animated: Bool = false) {
        mediaContentView.hideContent(animated: animated) { [weak self] _ in
            self?.mediaContentView.pauseVideo()
        }
        visible = false
        UIView.animateWithDuration(animated ? Constants.contentSizeAnimationDuration : 0) {
            self.view.layoutIfNeeded()
        }
    }

    private func showStage(animated animated: Bool = false) {
        mediaContentView.showContent(animated: animated) { [weak self] _ in
            self?.mediaContentView.playVideo()
        }
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

    // MARK: - Deep linking content

    @objc private func didTapOnContent() {
        guard let targetContent = mediaContentView.content else {
            return
        }

        let router = Router(originViewController: self, dependencyManager: dependencyManager)
        let destination = DeeplinkDestination(content: targetContent)
        router.navigate(to: destination)
    }

    // MARK: - CaptionBarViewControllerDelegate
    
    func captionBarViewController(captionBarViewController: CaptionBarViewController, didTapOnUser user: UserModel) {
        let router = Router(originViewController: self, dependencyManager: dependencyManager)
        let destination = DeeplinkDestination(userID: user.id)
        router.navigate(to: destination)
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
