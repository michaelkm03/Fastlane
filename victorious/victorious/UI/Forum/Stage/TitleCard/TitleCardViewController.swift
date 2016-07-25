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

    /// Time after `show` is called to automatically slide out the card.
    var autoHideDelay = NSTimeInterval(4)

    private var autoHideTimer: VTimerManager?

    private var currentState = State.hidden

    private var stageContent: StageContent?

    private struct Constants {
        static let cornerRadius = CGFloat(6)
        static let borderWidth = CGFloat(1)
        static let borderColor = UIColor(white: 0.0, alpha: 0.1).CGColor

        /// This offset is so we clip the left side of the view to create the slide out title card effect.
        static let leadingEdgeOffset = CGFloat(-5)

        /// Amount the card can be dragged horizontally from the target spot.
        static let horizontalDragLimit = CGFloat(10)
    }

    @IBOutlet private weak var avatarView: AvatarView! {
        didSet {
            avatarView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(avatarTapped)))
        }
    }

    @IBOutlet private weak var authorLabel: UILabel!
    @IBOutlet private weak var titleLabel: UILabel!

    /// The draggable container view - the actual title card that is animated.
    @IBOutlet private weak var draggableView: UIView!

    // MARK: - UIDynamics & Interraction

    private var animator: UIDynamicAnimator?
    private var draggableBehavior: DraggableBehavior?

    // MARK: - UIViewController life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupContainerView()
        setupDynamics(inReferenceView: view, withDraggableView: draggableView)
        setupRecognizers(on: draggableView)
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let stageContent = stageContent {
            populateUI(with: stageContent)
        }
    }

    // MARK: Public

    /// Sets the content on the title card, call before `show` to have the right content be present before it animates in.
    func populate(with stageContent: StageContent?) {
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
        animateTitleCard(withInitialVelocity: CGPointZero)

        autoHideTimer?.invalidate()
        autoHideTimer = VTimerManager.scheduledTimerManagerWithTimeInterval(autoHideDelay, target: self, selector: #selector(hide), userInfo: nil, repeats: false)
    }

    /// Slides out the title card from the screen.
    func hide() {
        guard currentState != .hidden else {
            return
        }

        autoHideTimer?.invalidate()

        currentState = .hidden
        animateTitleCard(withInitialVelocity: CGPointZero)
    }

    // MARK: Private

    private func setupContainerView() {
        draggableView.applyCornerRadius(Constants.cornerRadius)
        draggableView.layer.borderColor = Constants.borderColor
        draggableView.layer.borderWidth = Constants.borderWidth
        view.backgroundColor = .clearColor()
    }

    private func setupRecognizers(on view: UIView) {
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(didPan(_:)))
        view.addGestureRecognizer(panGestureRecognizer)

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTap(_:)))
        view.addGestureRecognizer(tapGestureRecognizer)
    }

    private func setupDynamics(inReferenceView referenceView: UIView, withDraggableView draggableView: UIView) {
        animator = UIDynamicAnimator(referenceView: referenceView)
        draggableBehavior = DraggableBehavior(with: draggableView)
    }

    /// Target point of title card that depends on current state.
    private var targetPoint: CGPoint {
        var point: CGPoint
        switch currentState {
            case .shown:
                point = CGPoint(x: (draggableView.frame.width / 2) + Constants.leadingEdgeOffset, y: draggableView.frame.height / 2)
            case .hidden:
                point = CGPoint(x: -draggableView.frame.width, y: draggableView.frame.height / 2)
        }
        return point
    }

    private func animateTitleCard(withInitialVelocity initialVelocity: CGPoint) {
        guard let draggableBehavior = draggableBehavior else {
            return
        }
        draggableBehavior.targetPoint = targetPoint
        draggableBehavior.velocity = initialVelocity
        animator?.addBehavior(draggableBehavior)
    }

    @objc private func didPan(recognizer: UIPanGestureRecognizer) {
        let point = recognizer.translationInView(draggableView?.superview)
        let newCenter = CGPoint(x: draggableView.center.x + point.x, y: draggableView.center.y)
        if newCenter.x < (targetPoint.x + Constants.horizontalDragLimit) {
            draggableView.center = newCenter
        }
        recognizer.setTranslation(CGPointZero, inView: draggableView?.superview)

        switch recognizer.state {
            case .Began:
                animator?.removeAllBehaviors()
            case .Ended:
                var velocity = recognizer.velocityInView(draggableView?.superview)
                velocity.y = 0
                if velocity.x <= 0 {
                    currentState = .hidden
                }

                animateTitleCard(withInitialVelocity: velocity)
            default:
                break
        }
    }

    @objc private func didTap(recognizer: UITapGestureRecognizer) {
        guard let draggableBehavior = draggableBehavior else {
            return
        }

        currentState = .hidden
        animateTitleCard(withInitialVelocity: draggableBehavior.velocity)
    }

    private func populateUI(with stageContent: StageContent?) {
        guard isViewLoaded() else {
            return
        }

        authorLabel.text = stageContent?.content.author.displayName ?? ""
        titleLabel.text = stageContent?.metaData?.title ?? ""
        avatarView.user = stageContent?.content.author
    }

    @objc private func avatarTapped() {
        guard let avatarUser = stageContent?.content.author else {
            return
        }
        delegate?.didTap(on: avatarUser)
    }
}
