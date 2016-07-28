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
    
    @IBOutlet weak var captionBarContainerView: UIView!
    @IBOutlet private var captionBarHeightConstraint: NSLayoutConstraint! {
        didSet {
            captionBarHeightConstraint.constant = 0
        }
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

    private var isOnScreen: Bool {
        return self.view.window != nil
    }

    /// Shows meta data about the current item on the stage.
    private var titleCardViewController: TitleCardViewController?

    /// Holds the current aggregated information about the content and the meta data.
    private var currentStageContent: StageContent?

    private var stageDataSource: StageDataSource?
    
    weak var delegate: StageDelegate?
    private let audioSession = AVAudioSession.sharedInstance()

    var dependencyManager: VDependencyManager! {
        didSet {
            // The data source is initialized with the dependency manager since it needs URLs in the template to operate.
            stageDataSource = setupDataSource(dependencyManager)
        }
    }

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .blackColor()
        captionBarViewController = childViewControllers.flatMap({ $0 as? CaptionBarViewController }).first
        
        audioSession.addObserver(
            self,
            forKeyPath: "outputVolume",
            options: [.New, .Old],
            context: nil
        )
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)

        if mediaContentView?.seekableWithinBounds == true {
            show(false)
        }
        else {
            hide(false)
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
    
    private func setupDataSource(dependencyManager: VDependencyManager) -> StageDataSource {
        let dataSource = StageDataSource(dependencyManager: dependencyManager)
        dataSource.delegate = self
        return dataSource
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == "outputVolume" && view.window != nil {
            VAudioManager.sharedInstance().focusedPlaybackDidBegin(muted: false)
        }
    }
    
    private func swapStageContent(to content: ContentModel) {
        if let mediaContentView = mediaContentView {
            tearDownMediaContentView(mediaContentView)
        }
        self.mediaContentView = nil
        self.mediaContentView = newMediaContentView(for: content)
        self.mediaContentView?.loadContent()
    }
    
    private func tearDownMediaContentView(mediaContentView: MediaContentView) {
        let animations = {
            mediaContentView.alpha = 0
        }
        
        UIView.animateWithDuration(1, animations: animations) { _ in
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

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        super.prepareForSegue(segue, sender: sender)

        let destination = segue.destinationViewController
        if let titleCardViewController = destination as? TitleCardViewController {
            titleCardViewController.delegate = self
            self.titleCardViewController = titleCardViewController
        }
    }
    
    func setupMediaContentView(for content: ContentModel) -> MediaContentView {
        let configuration = MediaContentViewConfiguration(
            allowsVideoControls: false,
            fillMode: .fit
        )
        
        let mediaContentView = MediaContentView(
            content: content,
            dependencyManager: dependencyManager,
            configuration: configuration,
            delegate: self
        )
        
        mediaContentView.alpha = 0
        
        mediaContentView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didTapOnContent)))
        
        return mediaContentView
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
        hide(true)
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

    func hide(animated: Bool) {
        guard visible else {
            return
        }
        
        // Pause the video if necessary
        mediaContentView?.willBeDismissed()
        
        // Fade MCV Out
        let animations: ()->() = {
            self.mediaContentView?.alpha = 0
        }
        UIView.animateWithDuration(animated ? Constants.contentSizeAnimationDuration : 0, animations: animations) { _ in
            self.mediaContentView?.removeFromSuperview()
            self.mediaContentView = nil
        }
        
        visible = false
        UIView.animateWithDuration(animated ? Constants.contentSizeAnimationDuration : 0) {
            self.view.layoutIfNeeded()
        }

        titleCardViewController?.hide()
    }

    func show(animated: Bool) {
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

    // MARK: - TileCardDelegate

    func didTap(on user: UserModel) {
        let router = Router(originViewController: self, dependencyManager: dependencyManager)
        let destination = DeeplinkDestination(userID: user.id)
        router.navigate(to: destination)
    }

    // MARK: - MediaContentViewDelegate

    func didFinishLoadingContent(content: ContentModel) {
        guard isOnScreen else {
            return
        }
        
        guard mediaContentView?.seekableWithinBounds == true else {
            hide(true)
            return
        }
        
        show(true)
        
        let animations = {
            self.mediaContentView?.alpha = 1.0
            return
        }
        
        UIView.animateWithDuration(1, animations: animations) { _ in
            // TODO: Stop spinner
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
    
    var newItemButtonDependency: VDependencyManager? {
        return childDependencyForKey("newItemButton")
    }
}
