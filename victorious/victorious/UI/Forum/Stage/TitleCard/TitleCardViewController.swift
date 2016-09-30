//
//  TitleCardViewController.swift
//  victorious
//
//  Created by Sebastian Nystorm on 13/7/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

protocol TileCardDelegate: class {
    func didTap(on user: UserModel)
}

class TitleCardViewController: UIViewController {
    /// The presentation state of the TitleCard.
    enum State {
        case shown
        case hidden
    }

    weak var delegate: TileCardDelegate?

    fileprivate var autoHideTimer: VTimerManager?

    fileprivate var currentState = State.hidden

    fileprivate var stageContent: StageContent?

    fileprivate struct Constants {
        static let cornerRadius = CGFloat(6)
        static let borderWidth = CGFloat(1)
        static let borderColor = UIColor(white: 0.0, alpha: 0.1).cgColor
        static let maxMarqueeViewWidth = CGFloat(182.0)
        static let minDelay = TimeInterval(4)

        /// This offset is so we clip the left side of the view to create the slide out title card effect.
        static let leadingEdgeOffset = CGFloat(-5)

        /// Amount the card can be dragged horizontally from the target spot.
        static let horizontalDragLimit = CGFloat(10)
    }

    @IBOutlet weak var marqueeView: MarqueeView!
    @IBOutlet weak var marqueeViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet fileprivate weak var avatarView: AvatarView! {
        didSet {
            avatarView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(avatarTapped)))
        }
    }


    /// The draggable container view - the actual title card that is animated.
    @IBOutlet fileprivate weak var draggableView: UIView!

    // MARK: - UIDynamics & Interraction

    fileprivate var animator: UIDynamicAnimator?
    fileprivate var draggableBehavior: DraggableBehavior?

    // MARK: - UIViewController life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupContainerView()
        setupDynamics(inReferenceView: view, withDraggableView: draggableView)
        setupRecognizers(on: draggableView)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let stageContent = stageContent {
            populateUI(with: stageContent)
        }
    }

    // MARK: Public

    /// Sets the content on the title card, call before `show` to have the right content be present before it animates in.
    func populate(with stageContent: StageContent?) {
        /// check if the title card is on the stage and hide it before populating with new content.
        if currentState == .shown {
            hide()
        }

        self.stageContent = stageContent
        populateUI(with: stageContent)
    }

    /// Slides out the title card if it's not already present on the screen.
    /// The card will auto hide after a length of time specified in `autoHideDelay`.
    func show() {
        guard currentState != .shown else {
            return
        }

        currentState = .shown
        animateTitleCard(withInitialVelocity: CGPoint.zero)

        autoHideTimer?.invalidate()

        let autoHideDelay = marqueeView.maxAnimationDuration > Constants.minDelay ? marqueeView.maxAnimationDuration : Constants.minDelay
        autoHideTimer = VTimerManager.scheduledTimerManager(withTimeInterval: autoHideDelay, target: self, selector: #selector(autoHideTimerDidFire), userInfo: nil, repeats: false)
    }

    /// Slides out the title card from the screen.
    func hide() {
        guard currentState != .hidden else {
            return
        }

        autoHideTimer?.invalidate()

        currentState = .hidden
        animateTitleCard(withInitialVelocity: CGPoint.zero)
    }

    // MARK: Private

    fileprivate func setupContainerView() {
        draggableView.applyCornerRadius(Constants.cornerRadius)
        draggableView.layer.borderColor = Constants.borderColor
        draggableView.layer.borderWidth = Constants.borderWidth
        view.backgroundColor = .clear
    }

    fileprivate func setupRecognizers(on view: UIView) {
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(didPan(_:)))
        view.addGestureRecognizer(panGestureRecognizer)

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTap(_:)))
        view.addGestureRecognizer(tapGestureRecognizer)
    }

    fileprivate func setupDynamics(inReferenceView referenceView: UIView, withDraggableView draggableView: UIView) {
        animator = UIDynamicAnimator(referenceView: referenceView)
        draggableBehavior = DraggableBehavior(with: draggableView)
    }

    /// Target point of title card that depends on current state.
    fileprivate var targetPoint: CGPoint {
        var point: CGPoint
        switch currentState {
            case .shown:
                point = CGPoint(x: (draggableView.frame.width / 2) + Constants.leadingEdgeOffset, y: draggableView.frame.height / 2)
            case .hidden:
                point = CGPoint(x: -draggableView.frame.width, y: draggableView.frame.height / 2)
        }
        return point
    }

    fileprivate func animateTitleCard(withInitialVelocity initialVelocity: CGPoint) {
        guard let draggableBehavior = draggableBehavior else {
            return
        }
        draggableBehavior.targetPoint = targetPoint
        draggableBehavior.velocity = initialVelocity
        animator?.addBehavior(draggableBehavior)
    }

    @objc fileprivate func didPan(_ recognizer: UIPanGestureRecognizer) {
        let point = recognizer.translation(in: draggableView?.superview)
        let newCenter = CGPoint(x: draggableView.center.x + point.x, y: draggableView.center.y)
        if newCenter.x < (targetPoint.x + Constants.horizontalDragLimit) {
            draggableView.center = newCenter
        }
        recognizer.setTranslation(CGPoint.zero, in: draggableView?.superview)

        switch recognizer.state {
            case .began:
                animator?.removeAllBehaviors()
            case .ended:
                var velocity = recognizer.velocity(in: draggableView?.superview)
                velocity.y = 0
                if velocity.x <= 0 {
                    currentState = .hidden
                }

                animateTitleCard(withInitialVelocity: velocity)
            default:
                break
        }
    }

    @objc fileprivate func didTap(_ recognizer: UITapGestureRecognizer) {
        guard let draggableBehavior = draggableBehavior else {
            return
        }

        currentState = .hidden
        animateTitleCard(withInitialVelocity: draggableBehavior.velocity)
    }

    fileprivate func populateUI(with stageContent: StageContent?) {
        guard isViewLoaded else {
            return
        }

        let author = stageContent?.content.author?.displayName ?? ""
        let title = stageContent?.metaData?.title ?? ""
        let marqueeWidth = marqueeView.updateLabels(author: author, title: title)
        marqueeViewWidthConstraint.constant = min(marqueeWidth, Constants.maxMarqueeViewWidth)
        marqueeView.layoutIfNeeded()
        marqueeView.scroll()
        avatarView.user = stageContent?.content.author
    }

    @objc fileprivate func autoHideTimerDidFire() {
        autoHideTimer?.invalidate()
        hide()
    }

    @objc fileprivate func avatarTapped() {
        guard let avatarUser = stageContent?.content.author else {
            return
        }
        delegate?.didTap(on: avatarUser)
    }
}
