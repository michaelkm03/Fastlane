//
//  StageViewController.swift
//  victorious
//
//  Created by Sharif Ahmed on 3/1/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class StageViewController: UIViewController, Stage, CaptionBarViewControllerDelegate, TileCardDelegate, MediaContentViewDelegate {
    private struct Constants {
        static let contentSizeAnimationDuration: NSTimeInterval = 0.5
        static let defaultAspectRatio: CGFloat = 16 / 9
        static let titleCardDelayedShow = NSTimeInterval(1)
    }
    
    private lazy var defaultStageHeight: CGFloat = {
        return self.view.bounds.width / Constants.defaultAspectRatio
    }()

    @IBOutlet private var mediaContentView: MediaContentView! {
        didSet {
            mediaContentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapOnContent)))
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
    
    private var visible = false {
        didSet {
            updateStageHeight()
        }
    }

    private var isOnScreen: Bool {
        return self.view.window != nil
    }

    /// Shows meta data about the current item on the stage.
    private var titleCardViewController: TitleCardViewController?

    /// Holds the current aggregated information about the content and the meta data.
    private var currentStageContent: StageContent?

    private var stageDataSource: StageDataSource?
    private var enabled = true
    
    weak var delegate: StageDelegate?
    private let audioSession = AVAudioSession.sharedInstance()

    var dependencyManager: VDependencyManager! {
        didSet {
            // The data source is initialized with the dependency manager since it needs URLs in the template to operate.
            stageDataSource = setupDataSource(dependencyManager)
        }
    }

    // MARK: - UIViewController Life cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        captionBarViewController = childViewControllers.flatMap({ $0 as? CaptionBarViewController }).first
        mediaContentView.dependencyManager = dependencyManager
        mediaContentView.allowsVideoControls = false
        mediaContentView.showsBlurredBackground = false
        
        audioSession.addObserver(
            self,
            forKeyPath: "outputVolume",
            options: [.New, .Old],
            context: nil
        )
    }
    
    private func setupDataSource(dependencyManager: VDependencyManager) -> StageDataSource {
        let dataSource = StageDataSource(dependencyManager: dependencyManager)
        dataSource.delegate = self
        return dataSource
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let content = currentStageContent?.content {
            mediaContentView.content = content
            setStageEnabled(true, animated: false)
        }
    }

    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        hideStage(animated: false)
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == "outputVolume" && view.window != nil {
            VAudioManager.sharedInstance().focusedPlaybackDidBegin(muted: false)
        }
    }
    
    deinit {
        audioSession.removeObserver(self, forKeyPath: "outputVolume")
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)

        let destination = segue.destinationViewController
        if let titleCardViewController = destination as? TitleCardViewController {
            titleCardViewController.delegate = self
            self.titleCardViewController = titleCardViewController
        }
    }

    // MARK: - Stage
    
    func addCaptionContent(content: ContentModel) {
        guard let text = content.text else {
            return
        }
        captionBarViewController?.populate(content.author, caption: text)
    }

    func addStageContent(stageContent: StageContent) {
        currentStageContent = stageContent
        
        guard isOnScreen && enabled else {
            return
        }

        titleCardViewController?.populate(with: stageContent)

        mediaContentView.videoCoordinator?.pauseVideo()
        mediaContentView.content = stageContent.content
        
        updateStageHeight()

        showStage(animated: true)

        dispatch_after(Constants.titleCardDelayedShow) {
            self.titleCardViewController?.show()
        }
    }

    func removeContent() {
        hideStage()
        currentStageContent = nil
        titleCardViewController?.hide()
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
            return captionBarViewController?.view.alpha ?? 0
        }
        set {
            captionBarViewController?.view.alpha = newValue
        }
    }
    
    // MARK: - ForumEventReceiver
    
    var childEventReceivers: [ForumEventReceiver] {
        return [stageDataSource].flatMap { $0 }
    }

    // MARK: - Show/Hide Stage

    func show(animated: Bool) {

    }

    func hide(animated: Bool) {

    }

    private func hideStage(animated animated: Bool = false) {
        guard visible else {
            return
        }

        mediaContentView.hideContent(animated: animated) { [weak self] _ in
            self?.mediaContentView.pauseVideo()
        }
        visible = false
        UIView.animateWithDuration(animated ? Constants.contentSizeAnimationDuration : 0) {
            self.view.layoutIfNeeded()
        }

        titleCardViewController?.hide()
    }

    private func showStage(animated animated: Bool = false) {
        guard !visible else {
            return
        }
        
        mediaContentView.showContent(animated: animated) { [weak self] _ in
            if
                let videoDuration = self?.mediaContentView.videoCoordinator?.duration,
                let content = self?.currentStageContent?.content
            {
                if content.seekAheadTime() < videoDuration {
                    self?.mediaContentView.videoCoordinator?.playVideo(true)
                }
                else {
                    self?.hideStage(animated: true)
                }
            }
        }
        visible = true
        UIView.animateWithDuration(animated ? Constants.contentSizeAnimationDuration : 0) {
            self.view.layoutIfNeeded()
        }
    }

    // MARK: - TileCardDelegate

    func didTap(on user: UserModel) {
        let router = Router(originViewController: self, dependencyManager: dependencyManager)
        let destination = DeeplinkDestination(userID: user.id)
        router.navigate(to: destination)
    }

    // MARK: - MediaContentViewDelegate

    func didFinishLoadingContent(content: ContentModel) {
        print("didFinishLoadingContent in StageVC")
    }

    // MARK: - StageShrinkingAnimatorDelegate

    func willSwitch(to state: StageState) {
        titleCardViewController?.hide()
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
    var captionBarDependency: VDependencyManager? {
        return childDependencyForKey("captionBar")
    }
    
    var newItemButtonDependency: VDependencyManager? {
        return childDependencyForKey("newItemButton")
    }
}
