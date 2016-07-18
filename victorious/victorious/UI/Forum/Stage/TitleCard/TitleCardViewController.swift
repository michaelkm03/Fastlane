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

    private struct Constants {
        static let cornerRadius = CGFloat(6)
        static let maxWidth = CGFloat(250)

        /// This offset is so we clip the left side of the view to create the slide out title card effect.
        static let leadingEdgeOffset = CGFloat(-12)
    }

    @IBOutlet private weak var avatarView: AvatarView! {
        didSet {
            avatarView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(avatarTapped)))
        }
    }

    @IBOutlet private weak var authorLabel: UILabel!
    @IBOutlet private weak var titleLabel: UILabel!

    /// The draggable container view.
    @IBOutlet private weak var containerView: UIView!

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

        containerView.applyCornerRadius(Constants.cornerRadius)
        containerView.layer.borderColor = UIColor(white: 0.0, alpha: 0.1).CGColor
        containerView.layer.borderWidth = 1
        view.backgroundColor = .clearColor()

        setupAnimator(with: view)
        setupRecognizers(on: containerView)

        // Set the tile card in it's starting state.
        containerView.center = targetPoint
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let stageContent = stageContent {
            populateUI(with: stageContent)
        }
    }

    // MARK: Private

    private func setupRecognizers(on view: UIView) {
        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(didPand(_:)))
        containerView.addGestureRecognizer(panGestureRecognizer)
        self.panGestureRecognizer = panGestureRecognizer

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(didTap(_:)))
        containerView.addGestureRecognizer(tapGestureRecognizer)
        self.tapGestureRecognizer = tapGestureRecognizer
    }

    private func setupAnimator(with referenceView: UIView) {
        animator = UIDynamicAnimator(referenceView: referenceView)
    }

    /// Target point of tile card that depends on current state.
    private var targetPoint: CGPoint {
        var point: CGPoint
        switch currentState {
            case .shown:
                point = CGPoint(x: (containerView.frame.width / 2) + Constants.leadingEdgeOffset, y: containerView.frame.height / 2)
            case .hidden:
                point = CGPoint(x: -containerView.frame.width, y: containerView.frame.height / 2)
        }
        print("state -> \(currentState)   point -> \(point)")
        return point
    }

    private func animateTileCard(withInitialVelocity initialVelocity: CGPoint) {
        if draggableBehaviour == nil {
            draggableBehaviour = DraggableBehaviour(with: containerView)
        }
        draggableBehaviour?.targetPoint = targetPoint
        draggableBehaviour?.velocity = initialVelocity
        animator?.addBehavior(draggableBehaviour!)
    }

    @objc private func didPand(recognizer: UIPanGestureRecognizer) {
        let point = recognizer.translationInView(containerView?.superview)
        containerView.center = CGPoint(x: containerView.center.x + point.x, y: containerView.center.y)
        recognizer.setTranslation(CGPointZero, inView: containerView?.superview)

        switch recognizer.state {
            case .Began:
                animator?.removeAllBehaviors()
            case .Ended:
                var velocity = recognizer.velocityInView(containerView?.superview)
                velocity.y = 0
                currentState = (velocity.x > 0 ? .shown : .hidden)
                animateTileCard(withInitialVelocity: velocity)
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
        animateTileCard(withInitialVelocity: draggableBehaviour.velocity)
    }

    // MARK: Public

    ///
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

    func show(animated animated: Bool) {
        print("SHOWING TITLE CARD")
        guard currentState == .hidden else {
            return
        }
        currentState = .shown
        animateTileCard(withInitialVelocity: CGPointZero)
    }

    func hide(animated animated: Bool) {
        print("HIDING TITLE CARD")
        guard currentState == .shown else {
            return
        }
        currentState = .hidden
        animateTileCard(withInitialVelocity: CGPointZero)
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
