//
//  StageViewController.swift
//  victorious
//
//  Created by Sharif Ahmed on 3/1/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit
import VictoriousIOSSDK

class StageViewController: UIViewController, Stage, CaptionBarViewControllerDelegate, TileCardDelegate, MediaContentViewDelegate, ContentCellTracker {
    private struct Constants {
        static let defaultAspectRatio: CGFloat = 16 / 9
        static let titleCardDelayedShow = TimeInterval(1)
        static let mediaContentViewAnimationDurationMultiplier = 1.25
        static let audioSessionOutputVolumeKeyPath = "outputVolume"
    }
    
    @IBOutlet private var captionBarContainerView: UIView!
    @IBOutlet private var captionBarHeightConstraint: NSLayoutConstraint! {
        didSet {
            captionBarHeightConstraint.constant = 0
        }
    }
    
    private var stayTunedImageView: UIImageView?
    
    @IBOutlet private var titleCardContainerView: UIView!
    @IBOutlet private var loadingIndicator: UIActivityIndicatorView!
    
    private let stagePreparer = StagePreparer()

    private lazy var stageHeight: CGFloat = {
        return self.view.bounds.width / Constants.defaultAspectRatio
    }()

    private var stageContext: DeeplinkContext {
        return DeeplinkContext(value: dependencyManager.context)
    }

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
    
    var isOnScreen: Bool {
        return view.window != nil
    }

    /// An internal state to the Stage, where it can enable and disable itself depending on where in the feed the user is.
    /// This is needed so the Stage will not appear if a new content arrives when the user is inside a filtered feed.
    private var enabled: Bool = true {
        didSet {
            if enabled && mediaContentView?.hasValidMedia == true {
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        stagePreparer.stage(self, didBecomeVisible: true)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stagePreparer.stage(self, didBecomeVisible: false)
        
        if let mediaContentView = mediaContentView {
            hideMediaContentView(mediaContentView, animated: true)
        }
    }
    
    deinit {
        audioSession.removeObserver(self, forKeyPath: Constants.audioSessionOutputVolumeKeyPath)
    }
    
    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = .black
        loadingIndicator.stopAnimating()
        captionBarViewController = childViewControllers.flatMap({ $0 as? CaptionBarViewController }).first

        audioSession.addObserver(
            self,
            forKeyPath: Constants.audioSessionOutputVolumeKeyPath,
            options: [.new, .old],
            context: nil
        )
        
        setupStayTunedImageViewIfNecessary()
    }
    
    private func setupStayTunedImageViewIfNecessary() {
        if let image = dependencyManager.backgroundImage {
            let imageView = UIImageView(image: image)
            imageView.contentMode = .scaleAspectFill
            view.insertSubview(imageView, belowSubview: titleCardContainerView)
            view.v_addFitToParentConstraints(toSubview: imageView)
            self.stayTunedImageView = imageView
            show(animated: false)
        }
    }

    private func setupDataSource(_ dependencyManager: VDependencyManager) -> StageDataSource {
        let dataSource = StageDataSource(dependencyManager: dependencyManager)
        dataSource.delegate = self
        return dataSource
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        // Change the audio session category if the volume changes.
        if keyPath == Constants.audioSessionOutputVolumeKeyPath && isOnScreen {
            VAudioManager.sharedInstance().focusedPlaybackDidBegin(muted: false)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)

        let destination = segue.destination
        if let titleCardViewController = destination as? TitleCardViewController {
            titleCardViewController.delegate = self
            self.titleCardViewController = titleCardViewController
        }
    }

    // MARK: MediaContentView

    func setupMediaContentView(for content: Content) -> MediaContentView {
        let mediaContentView = MediaContentView(
            content: content,
            dependencyManager: dependencyManager,
            fillMode: (content.type == .text ? .fill : .fit),
            allowsVideoControls: false,
            shouldSyncOnReappearance: true
        )

        mediaContentView.delegate = self
        mediaContentView.alpha = 0
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTapOnContent))
        tapRecognizer.cancelsTouchesInView = false
        mediaContentView.addGestureRecognizer(tapRecognizer)

        return mediaContentView
    }

    /// Every piece of content has it's own instance of MediaContentView, it is destroyed and recreated for each one.
    private func tearDownMediaContentView(_ mediaContentView: MediaContentView) {
        hideMediaContentView(mediaContentView, animated: true) { (completed) in
            mediaContentView.removeFromSuperview()
        }
    }

    private func newMediaContentView(for content: Content) -> MediaContentView {
        let mediaContentView = setupMediaContentView(for: content)
        view.insertSubview(mediaContentView, belowSubview: titleCardContainerView)
        mediaContentView.translatesAutoresizingMaskIntoConstraints = false
        view.leadingAnchor.constraint(equalTo: mediaContentView.leadingAnchor).isActive = true
        view.trailingAnchor.constraint(equalTo: mediaContentView.trailingAnchor).isActive = true
        view.topAnchor.constraint(equalTo: mediaContentView.topAnchor).isActive = true
        mediaContentView.bottomAnchor.constraint(equalTo: captionBarContainerView.topAnchor).isActive = true
        return mediaContentView
    }

    private func showMediaContentView(_ mediaContentView: MediaContentView, animated: Bool, completion: ((Bool) -> Void)? = nil) {
        mediaContentView.didPresent()
        
        let animations = {
            self.stayTunedImageView?.alpha = 0
            mediaContentView.alpha = 1
        }
        UIView.animate(withDuration: (animated ? MediaContentView.AnimationConstants.mediaContentViewAnimationDuration : 0), animations: animations, completion: completion)
    }

    private func hideMediaContentView(_ mediaContentView: MediaContentView, animated: Bool, completion: ((Bool) -> Void)? = nil) {
        mediaContentView.willBeDismissed()
        
        // FUTURE: Show loading thumbnail
        loadingIndicator.startAnimating()
        
        let animations = {
            self.stayTunedImageView?.alpha = 1
            mediaContentView.alpha = 0
        }
        let duration = MediaContentView.AnimationConstants.mediaContentViewAnimationDuration * Constants.mediaContentViewAnimationDurationMultiplier
        UIView.animate(withDuration: (animated ? duration : 0), animations: animations, completion: completion)
    }

    // MARK: - Stage
    
    func addCaptionContent(_ content: Content) {
        guard let text = content.text, let author = content.author else {
            return
        }
        captionBarViewController?.populate(author, caption: text)
    }

    func addStageContent(_ stageContent: StageContent) {
        stagePreparer.prepareNextContent(stageContent, for: self)
    }
    
    private func updateStageContent(stageContent content: StageContent) {
        currentStageContent = content
        
        if let mediaContentView = mediaContentView {
            tearDownMediaContentView(mediaContentView)
        }

        mediaContentView = newMediaContentView(for: content.content)
        mediaContentView?.loadContent()
        
        titleCardViewController?.populate(with: content)

        updateStageHeight()
    }

    func removeContent() {
        hide(animated: true)
        currentStageContent = nil
        titleCardViewController?.hide()
    }
    
    // MARK: - ForumEventReceiver

    func receive(_ event: ForumEvent) {
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

    private func show(animated: Bool) {
        guard enabled else {
            return
        }

        if let mediaContentView = mediaContentView {
            showMediaContentView(mediaContentView, animated: animated)
        }
        
        if (currentStageContent?.metaData != nil) {
            dispatch_after(Constants.titleCardDelayedShow) {
                self.titleCardViewController?.show()
            }
        }
        
        if let content = currentStageContent?.content {
            trackView(.cellView, showingContent: content, parameters: [:])
        }
        
        guard !visible else {
            return
        }

        visible = true
    }

    private func hide(animated: Bool) {
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
        router.navigate(to: destination, from: stageContext)
    }

    // MARK: - MediaContentViewDelegate

    func mediaContentView(_ mediaContentView: MediaContentView, didFinishLoadingContent content: Content) {
        guard isOnScreen else {
            return
        }

        /// Instead of seeking past the end of the video we hide the stage.
        guard mediaContentView.hasValidMedia else {
            return
        }
        
        DispatchQueue.main.async {
            self.show(animated: true)
            self.loadingIndicator.stopAnimating()
        }
    }

    func mediaContentView(_ mediaContentView: MediaContentView, didFinishPlaybackOfContent content: Content) {
        // When the playback of a video is done we want to hide the MCV.
        if content.type == .video {
            hideMediaContentView(mediaContentView, animated: true)
        }
    }
    
    func mediaContentView(_ mediaContentView: MediaContentView, didSelectLinkURL url: URL) {
        Router(originViewController: self, dependencyManager: dependencyManager).navigate(
            to: DeeplinkDestination(url: url),
            from: stageContext
        )
    }

    // MARK: - StageShrinkingAnimatorDelegate

    func willSwitch(to state: StageState) {
        titleCardViewController?.hide()
    }
    
    func shouldSwitch(to state: StageState) -> Bool {
        switch state {
            case .enlarged: return true
            case .shrunken: return visible
        }
    }

    // MARK: - Deep linking content

    @objc private func didTapOnContent() {
        guard let content = currentStageContent?.content else {
            return
        }
        
        let router = Router(originViewController: self, dependencyManager: dependencyManager)
        let destination = DeeplinkDestination(content: content, forceFetch: false)
        router.navigate(to: destination, from: stageContext)
    }

    // MARK: - CaptionBarViewControllerDelegate
    
    func captionBarViewController(_ captionBarViewController: CaptionBarViewController, didTapOnUser user: UserModel) {
        let router = Router(originViewController: self, dependencyManager: dependencyManager)
        let destination = DeeplinkDestination(userID: user.id)
        router.navigate(to: destination, from: stageContext)
    }
    
    func captionBarViewController(_ captionBarViewController: CaptionBarViewController, wantsUpdateToContentHeight height: CGFloat) {
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
    
    // MARK: - Content Cell Tracker 
    
    var sessionParameters: [AnyHashable: Any] {
        return [VTrackingKeyParentContentId: dependencyManager.context]
    }
}

private extension VDependencyManager {
    var captionBarDependency: VDependencyManager? {
        return childDependency(forKey: "captionBar")
    }

    /// STAGE has historically been used to track stage content before there was main_stage, vip_stage. Leaving this in until vip stage has been released, then it should be revisited.
    var context: String {
        return string(forKey: "context") ?? "STAGE"
    }
    
    var backgroundImage: UIImage? {
        return image(forKey: "stay.tuned.image")
    }
}

private final class StagePreparer {
    var nextStageContent: StageContent?
    func prepareNextContent(_ stageContent: StageContent, for stage: StageViewController) {
        let isYouTube = stageContent.content.assets.first?.videoSource == .youtube
        nextStageContent = stageContent
        if stage.isOnScreen || !isYouTube {
            stage.updateStageContent(stageContent: stageContent)
        }
    }
    
    func stage(_ stage: StageViewController, didBecomeVisible visible: Bool) {
        if let stageContent = nextStageContent, visible {
            stage.updateStageContent(stageContent: stageContent)
        }
    }
}
