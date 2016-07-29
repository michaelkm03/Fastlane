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
        static let contentSizeAnimationDuration = NSTimeInterval(0.5)
        static let defaultAspectRatio: CGFloat = 16 / 9
        static let titleCardDelayedShow = NSTimeInterval(1)
        static let mediaContentViewAnimationDuration = NSTimeInterval(0.75)
        static let mediaContentViewAnimationDurationMultiplier = 1.25
    }
    
    @IBOutlet private weak var captionBarContainerView: UIView!
    @IBOutlet private var captionBarHeightConstraint: NSLayoutConstraint! {
        didSet {
            captionBarHeightConstraint.constant = 0
        }
    }

    @IBOutlet private weak var loadingIndicator: UIActivityIndicatorView!

    private lazy var defaultStageHeight: CGFloat = {
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
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        mediaContentView?.willBeDismissed()
    }
    
    deinit {
        audioSession.removeObserver(self, forKeyPath: "outputVolume")
    }
    
    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = .blackColor()
        loadingIndicator.stopAnimating()
        captionBarViewController = childViewControllers.flatMap({ $0 as? CaptionBarViewController }).first

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
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        // Change the audio session category if the volume changes.
        if keyPath == "outputVolume" && isOnScreen {
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
            allowsVideoControls: false
        )

        mediaContentView.delegate = self
        mediaContentView.alpha = 0
        mediaContentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapOnContent)))

        return mediaContentView
    }

    /// Swapping content destroys the old MCV and creates a new instance.
    private func swapStageContent(to content: ContentModel) {
        if let mediaContentView = mediaContentView {
            tearDownMediaContentView(mediaContentView)
        }

        loadingIndicator.startAnimating()

        mediaContentView = nil
        mediaContentView = newMediaContentView(for: content)
        mediaContentView?.loadContent()
    }

    /// Every piece of content has it's own instance of MediaContentView, it is destroyed and recreated for each one.
    private func tearDownMediaContentView(mediaContentView: MediaContentView) {
        hideMediaContentView(mediaContentView, animated: true) { (completed) in
            mediaContentView.removeFromSuperview()
        }
    }

    private func newMediaContentView(for content: ContentModel) -> MediaContentView {
        let mediaContentView = setupMediaContentView(for: content)
        view.addSubview(mediaContentView)
        view.sendSubviewToBack(mediaContentView)
        view.v_addPinToLeadingTrailingToSubview(mediaContentView)
        view.v_addPinToTopToSubview(mediaContentView)
        // TODO: Fix this?
        view.v_addPinToBottomToSubview(mediaContentView, bottomMargin: captionBarContainerView.frame.size.height)

        return mediaContentView
    }

    private func showMediaContentView(mediaContentView: MediaContentView, animated: Bool, completion: ((Bool) -> Void)? = nil) {
        print("showMediaContentView")
        let animations = {
            mediaContentView.alpha = 1
        }
        UIView.animateWithDuration((animated ? Constants.mediaContentViewAnimationDuration : 0), animations: animations, completion: completion)
    }

    private func hideMediaContentView(mediaContentView: MediaContentView, animated: Bool, completion: ((Bool) -> Void)? = nil) {
        print("hideMediaContentView")
        let animations = {
            mediaContentView.alpha = 0
        }
        let duration = Constants.mediaContentViewAnimationDuration * Constants.mediaContentViewAnimationDurationMultiplier
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
        
        swapStageContent(to: stageContent.content)
        
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
    
    var childEventReceivers: [ForumEventReceiver] {
        return [stageDataSource].flatMap { $0 }
    }

    // MARK: - Show/Hide Stage

    func setHidden(hidden: Bool, animated: Bool) {
        if hidden {
            hide(animated: animated)
        } else {
            show(animated: animated)
        }
    }

    private func show(animated animated: Bool) {
        mediaContentView?.willBePresented()

        dispatch_after(Constants.titleCardDelayedShow) {
            self.titleCardViewController?.show()
        }

        guard !visible else {
            return
        }

        visible = true
        UIView.animateWithDuration(animated ? Constants.contentSizeAnimationDuration : 0) {
            self.view.layoutIfNeeded()
        }
    }

    private func hide(animated animated: Bool) {
        guard visible else {
            return
        }
        
        // Let MVC know it is being dismissed from the screen.
        mediaContentView?.willBeDismissed()
        
        UIView.animateWithDuration(animated ? Constants.contentSizeAnimationDuration : 0, animations: {
            self.mediaContentView?.alpha = 0
        }, completion: { _ in
            self.mediaContentView?.removeFromSuperview()
            self.mediaContentView = nil
        })
        
        visible = false
        UIView.animateWithDuration(animated ? Constants.contentSizeAnimationDuration : 0) {
            self.view.layoutIfNeeded()
        }

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
        guard mediaContentView.seekableWithinBounds == true else {
            hide(animated: true)
            return
        }
        
        show(animated: true)

        loadingIndicator.stopAnimating()

        showMediaContentView(mediaContentView, animated: true)
    }

    func mediaContentView(mediaContentView: MediaContentView, didFinishPlaybackOfContent content: ContentModel) {
        print("mediaContentView didFinishPlaybackOfContent didFinishPlaybackOfContent didFinishPlaybackOfContent")
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
        let destination = DeeplinkDestination(content: content)
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
}
