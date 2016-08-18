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
        static let defaultAspectRatio: CGFloat = 16 / 9
        static let titleCardDelayedShow = NSTimeInterval(1)
        static let mediaContentViewAnimationDurationMultiplier = 1.25
        static let audioSessionOutputVolumeKeyPath = "outputVolume"
    }
    
    @IBOutlet private weak var captionBarContainerView: UIView!
    @IBOutlet private var captionBarHeightConstraint: NSLayoutConstraint! {
        didSet {
            captionBarHeightConstraint.constant = 0
        }
    }

    @IBOutlet private weak var loadingIndicator: UIActivityIndicatorView!

    private lazy var stageHeight: CGFloat = {
        return self.view.bounds.width / Constants.defaultAspectRatio
    }()

    private var mediaContentView: MediaContentView?

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
        return view.window != nil
    }

    /// An internal state to the Stage, where it can enable and disable itself depending on where in the feed the user is.
    /// This is needed so the Stage will not appear if a new content arrives when the user is inside a filtered feed.
    private var enabled: Bool = true {
        didSet {
            if enabled && mediaContentView?.seekableWithinBounds == true {
                show(animated: true)
            } else {
                hide(animated: true)
            }
        }
    }

    /// Shows meta data about the current item on the stage.
    private var titleCardViewController: TitleCardViewController?

    /// Holds the current aggregated information about the content and the meta data.
    private var currentStageContent: StageContent?

    private var stageDataSource: StageDataSource?

    private let audioSession = AVAudioSession.sharedInstance()

    weak var delegate: StageDelegate?

    var dependencyManager: VDependencyManager! {
        didSet {
            // The data source is initialized with the dependency manager since it needs URLs in the template to operate.
            stageDataSource = setupDataSource(dependencyManager)
        }
    }

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        if mediaContentView?.seekableWithinBounds == true {
            show(animated: false)
        }
        else {
            hide(animated: false)
        }
    }

    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)

        hide(animated: false)
    }
    
    deinit {
        audioSession.removeObserver(self, forKeyPath: Constants.audioSessionOutputVolumeKeyPath)
    }
    
    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = .blackColor()
        loadingIndicator.stopAnimating()
        captionBarViewController = childViewControllers.flatMap({ $0 as? CaptionBarViewController }).first

        audioSession.addObserver(
            self,
            forKeyPath: Constants.audioSessionOutputVolumeKeyPath,
            options: [.New, .Old],
            context: nil
        )
    }

    private func setupDataSource(dependencyManager: VDependencyManager) -> StageDataSource {
        let dataSource = StageDataSource(dependencyManager: dependencyManager)
        dataSource.delegate = self
        return dataSource
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        // Change the audio session category if the volume changes.
        if keyPath == Constants.audioSessionOutputVolumeKeyPath && isOnScreen {
            VAudioManager.sharedInstance().focusedPlaybackDidBegin(muted: false)
        }
    }

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)

        let destination = segue.destinationViewController
        if let titleCardViewController = destination as? TitleCardViewController {
            titleCardViewController.delegate = self
            self.titleCardViewController = titleCardViewController
        }
    }

    // MARK: MediaContentView

    func setupMediaContentView(for content: ContentModel) -> MediaContentView {
        let mediaContentView = MediaContentView(
            content: content,
            dependencyManager: dependencyManager,
            fillMode: (content.type == .text ? .fill : .fit),
            allowsVideoControls: false,
            shouldSyncOnReappearance: true
        )

        mediaContentView.delegate = self
        mediaContentView.alpha = 0
        mediaContentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapOnContent)))

        return mediaContentView
    }

    /// Every piece of content has it's own instance of MediaContentView, it is destroyed and recreated for each one.
    private func tearDownMediaContentView(mediaContentView: MediaContentView) {
        hideMediaContentView(mediaContentView, animated: true) { (completed) in
            mediaContentView.removeFromSuperview()
        }
    }

    private func newMediaContentView(for content: ContentModel) -> MediaContentView {
        let mediaContentView = setupMediaContentView(for: content)
        view.insertSubview(mediaContentView, aboveSubview: loadingIndicator)
        mediaContentView.translatesAutoresizingMaskIntoConstraints = false
        view.leadingAnchor.constraintEqualToAnchor(mediaContentView.leadingAnchor).active = true
        view.trailingAnchor.constraintEqualToAnchor(mediaContentView.trailingAnchor).active = true
        view.topAnchor.constraintEqualToAnchor(mediaContentView.topAnchor).active = true
        mediaContentView.bottomAnchor.constraintEqualToAnchor(captionBarContainerView.topAnchor).active = true
        return mediaContentView
    }

    private func showMediaContentView(mediaContentView: MediaContentView, animated: Bool, completion: ((Bool) -> Void)? = nil) {
        mediaContentView.willBePresented()

        let animations = {
            mediaContentView.alpha = 1
        }
        UIView.animateWithDuration((animated ? MediaContentView.AnimationConstants.mediaContentViewAnimationDuration : 0), animations: animations, completion: completion)
    }

    private func hideMediaContentView(mediaContentView: MediaContentView, animated: Bool, completion: ((Bool) -> Void)? = nil) {
        mediaContentView.willBeDismissed()
        loadingIndicator.startAnimating()
        
        let animations = {
            mediaContentView.alpha = 0
        }
        let duration = MediaContentView.AnimationConstants.mediaContentViewAnimationDuration * Constants.mediaContentViewAnimationDurationMultiplier
        UIView.animateWithDuration((animated ? duration : 0), animations: animations, completion: completion)
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
        
        if let mediaContentView = mediaContentView {
            tearDownMediaContentView(mediaContentView)
        }

        loadingIndicator.startAnimating()

        mediaContentView = newMediaContentView(for: stageContent.content)
        mediaContentView?.loadContent()
        
        titleCardViewController?.populate(with: stageContent)

        updateStageHeight()
    }

    func removeContent() {
        hide(animated: true)
        currentStageContent = nil
        titleCardViewController?.hide()
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

    func receive(event: ForumEvent) {
        switch event {
            case .filterContent(let path):
                let isMainFeed = path == nil
                enabled = isMainFeed
            default: break
        }
    }

    var childEventReceivers: [ForumEventReceiver] {
        return [stageDataSource].flatMap { $0 }
    }

    // MARK: - Show/Hide Stage

    private func show(animated animated: Bool) {
        guard enabled else {
            return
        }

        if let mediaContentView = mediaContentView {
            showMediaContentView(mediaContentView, animated: animated)
        }

        dispatch_after(Constants.titleCardDelayedShow) {
            self.titleCardViewController?.show()
        }

        guard !visible else {
            return
        }

        visible = true
    }

    private func hide(animated animated: Bool) {
        guard visible else {
            return
        }

        if let mediaContentView = mediaContentView {
            hideMediaContentView(mediaContentView, animated: true)
        }

        visible = false

        titleCardViewController?.hide()
    }

    // MARK: - TileCardDelegate

    func didTap(on user: UserModel) {
        let router = Router(originViewController: self, dependencyManager: dependencyManager)
        let destination = DeeplinkDestination(userID: user.id)
        router.navigate(to: destination)
    }

    // MARK: - MediaContentViewDelegate

    func mediaContentView(mediaContentView: MediaContentView, didFinishLoadingContent content: ContentModel) {
        guard isOnScreen else {
            return
        }

        /// Instead of seeking past the end of the video we hide the stage.
        guard mediaContentView.seekableWithinBounds else {
            hide(animated: true)
            return
        }
        
        show(animated: true)

        loadingIndicator.stopAnimating()
    }

    func mediaContentView(mediaContentView: MediaContentView, didFinishPlaybackOfContent content: ContentModel) {
        // When the playback of a video is done we want to hide the MCV.
        if content.type == .video {
            hideMediaContentView(mediaContentView, animated: true)
        }
    }

    // MARK: - StageShrinkingAnimatorDelegate

    func willSwitch(to state: StageState) {
        titleCardViewController?.hide()
    }

    // MARK: - Deep linking content

    @objc private func didTapOnContent() {
        guard let content = currentStageContent?.content else {
            return
        }
        
        let router = Router(originViewController: self, dependencyManager: dependencyManager)
        let destination = DeeplinkDestination(content: content, forceFetch: false)
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
            height += stageHeight
        }
        delegate?.stage(self, wantsUpdateToContentHeight: height)
    }
}

private extension VDependencyManager {
    var captionBarDependency: VDependencyManager? {
        return childDependencyForKey("captionBar")
    }
}
