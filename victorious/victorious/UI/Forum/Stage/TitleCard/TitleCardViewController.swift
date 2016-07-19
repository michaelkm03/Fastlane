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
    var autoHideDelay = NSTimeInterval(3)

    private var autoHideTimer: VTimerManager?

    private struct Constants {
        static let cornerRadius = CGFloat(6)
        static let borderWidth = CGFloat(1)
        static let borderColor = UIColor(white: 0.0, alpha: 0.1).CGColor
        static let maxWidth = CGFloat(250)

        /// This offset is so we clip the left side of the view to create the slide out title card effect.
        static let leadingEdgeOffset = CGFloat(-10)

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

    /// The draggable container view, the actual title card that is animated.
    @IBOutlet private weak var draggableView: UIView!

    private var currentState = State.hidden

    private var stageContent: StageContent?

    // MARK: - UIDynamics & Interraction

    private var animator: UIDynamicAnimator?
    private var draggableBehaviour: DraggableBehaviour?

    private var panGestureRecognizer: UIPanGestureRecognizer?
    private var tapGestureRecognizer: UITapGestureRecognizer?


    // MARK: - UIViewController life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupContainerView()
        setupDynamics(inReferenceView: view, withDraggableView: draggableView)
        setupRecognizers(on: draggableView)

        // Set the tile card in it's starting state.
        draggableView.center = targetPoint
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let stageContent = stageContent {
            populateUI(with: stageContent)
        }
    }

    // MARK: Private

    private func setupContainerView() {
        draggableView.applyCornerRadius(Constants.cornerRadius)
        draggableView.layer.borderColor = Constants.borderColor
        draggableView.layer.borderWidth = Constants.borderWidth
        view.backgroundColor = .clearColor()
    }

    private func setupRecognizers(on view: UIView) {
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(didPand(_:)))
        draggableView.addGestureRecognizer(panGestureRecognizer)
        self.panGestureRecognizer = panGestureRecognizer

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTap(_:)))
        draggableView.addGestureRecognizer(tapGestureRecognizer)
        self.tapGestureRecognizer = tapGestureRecognizer
    }

    private func setupDynamics(inReferenceView referenceView: UIView, withDraggableView draggableView: UIView) {
        animator = UIDynamicAnimator(referenceView: referenceView)
        draggableBehaviour = DraggableBehaviour(with: draggableView)
    }

    /// Target point of tile card that depends on current state.
    private var targetPoint: CGPoint {
        var point: CGPoint
        switch currentState {
            case .shown:
                point = CGPoint(x: (draggableView.frame.width / 2) + Constants.leadingEdgeOffset, y: draggableView.frame.height / 2)
            case .hidden:
                point = CGPoint(x: -draggableView.frame.width, y: draggableView.frame.height / 2)
        }
        print("state -> \(currentState)   point -> \(point)")
        return point
    }

    private func animateTitleCard(withInitialVelocity initialVelocity: CGPoint) {
        guard let draggableBehaviour = draggableBehaviour else {
            return
        }

        draggableBehaviour.targetPoint = targetPoint
        draggableBehaviour.velocity = initialVelocity
        animator?.addBehavior(draggableBehaviour)
    }

    @objc private func didPand(recognizer: UIPanGestureRecognizer) {
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
                currentState = (velocity.x > 0 ? .shown : .hidden)
                animateTitleCard(withInitialVelocity: velocity)
            default:
                break
        }
    }

    @objc private func didTap(recognizer: UITapGestureRecognizer) {
        print("didTap")

        guard let draggableBehaviour = draggableBehaviour else {
            return
        }

        currentState = (currentState == .shown ? .hidden : .shown)
        animateTitleCard(withInitialVelocity: draggableBehaviour.velocity)
    }

    // MARK: Public

    /// Sets the content on the title card, call before `show` to have the right content be present before it animates in.
    func populate(with stageContent: StageContent?) {
        print("populate -> \(stageContent)")

        self.stageContent = stageContent
        populateUI(with: stageContent)
    }

    func clearCurrentContent() {
        print("clearCurrentContent")

        stageContent = nil
        populateUI(with: nil)
    }

    func show() {
        print("SHOWING TITLE CARD")
        guard currentState == .hidden else {
            return
        }

        currentState = .shown
        animateTitleCard(withInitialVelocity: CGPointZero)

        autoHideTimer?.invalidate()
        autoHideTimer = VTimerManager.scheduledTimerManagerWithTimeInterval(autoHideDelay, target: self, selector: #selector(hide), userInfo: nil, repeats: false)
    }

    func hide() {
        print("HIDING TITLE CARD")
        guard currentState == .shown else {
            return
        }
        autoHideTimer?.invalidate()

        currentState = .hidden
        animateTitleCard(withInitialVelocity: CGPointZero)
    }

    // MARK: Private

    private func populateUI(with stageContent: StageContent?) {
        guard isViewLoaded() else {
            return
        }

        authorLabel.text = stageContent?.content.author.name ?? ""
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
