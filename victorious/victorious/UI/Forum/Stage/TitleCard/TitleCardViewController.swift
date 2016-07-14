//
//  TitleCardViewController.swift
//  victorious
//
//  Created by Sebastian Nystorm on 13/7/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class TitleCardViewController: UIViewController {

    private struct Constanst {
        static let animationDuration = NSTimeInterval(1)
        static let cornerRadius = CGFloat(6)
        static let maxWidth = CGFloat(250)

        /// This offset is so we clip the left side of the view to create the slide out title card effect.
        static let leadingEgdeOffset = CGFloat(-10)
    }

    @IBOutlet private weak var profileButton: VDefaultProfileButton!
    @IBOutlet private weak var authorLabel: UILabel!
    @IBOutlet private weak var titleLabel: UILabel!

    /// The animatable container view.
    @IBOutlet private weak var containerView: UIView!
    @IBOutlet private weak var containerViewLeadingConstraint: NSLayoutConstraint!

    enum State {
        case shown
        case hidden
    }

    private var currentState = State.hidden

    private var stageContent: StageContent?

    // UIDynamics
    private var animator: UIDynamicAnimator?

    private var openSnapBehaviour: UISnapBehavior?
    private var closeSnapBehaviour: UISnapBehavior?

    // MARK: - UIViewController life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        containerView.applyCornerRadius(Constanst.cornerRadius)
        containerView.layer.borderColor = UIColor(white: 0.0, alpha: 0.1).CGColor
        containerView.layer.borderWidth = 1
        view.backgroundColor = .clearColor()

        animator = setupAnimator(with: view)

        // Setup animator behaviour
        let titleCardBehaviour = UIDynamicItemBehavior(items: [containerView])
        titleCardBehaviour.allowsRotation = false
        titleCardBehaviour.density = 10
        animator?.addBehavior(titleCardBehaviour)

        openSnapBehaviour = UISnapBehavior(item: containerView, snapToPoint: CGPoint(x: -10, y: 100))
        closeSnapBehaviour = UISnapBehavior(item: containerView, snapToPoint: CGPoint(x: -250, y: 100))
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if let stageContent = stageContent {
            populateUI(with: stageContent)
        }
    }

    // MARK: Private

    private func setupAnimator(with referenceView: UIView) -> UIDynamicAnimator {
        return UIDynamicAnimator(referenceView: referenceView)
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
        guard let openSnapBehaviour = openSnapBehaviour,
            let closeSnapBehaviour = closeSnapBehaviour
            where currentState == .hidden
        else {
            return
        }
        currentState = .shown

        animator?.removeBehavior(closeSnapBehaviour)
        animator?.addBehavior(openSnapBehaviour)

//        containerViewLeadingConstraint.constant = Constanst.leadingEgdeOffset
//        print("containerViewLeadingConstraint.constant -> \(containerViewLeadingConstraint.constant)")
//        UIView.animateWithDuration(
//            (animated ? Constanst.animationDuration : 0),
//            delay: 0,
//            usingSpringWithDamping: 0.75,
//            initialSpringVelocity: 0.1,
//            options: [.AllowUserInteraction, .BeginFromCurrentState],
//            animations:
//            {   [weak self] in
//                print("Inside show animation block")
//                self?.view.layoutIfNeeded()
//            }) { (completed) in
//                print("SHOWN")
//        }
    }

    func hide(animated animated: Bool) {
        print("HIDING TITLE CARD")
        guard let openSnapBehaviour = openSnapBehaviour,
            let closeSnapBehaviour = closeSnapBehaviour
            where currentState == .shown
        else {
            return
        }
        currentState = .hidden

        animator?.removeBehavior(openSnapBehaviour)
        animator?.addBehavior(closeSnapBehaviour)


//        let containerOffset = -view.frame.width
//        containerViewLeadingConstraint.constant = containerOffset
//        print("containerViewLeadingConstraint.constant -> \(containerViewLeadingConstraint.constant)")
//        UIView.animateWithDuration(
//            (animated ? Constanst.animationDuration : 0),
//            delay: 0,
//            usingSpringWithDamping: 0.75,
//            initialSpringVelocity: 0.1,
//            options: [.AllowUserInteraction, .BeginFromCurrentState],
//            animations:
//            {   [weak self] in
//                print("Inside hide animation block")
//                self?.view.layoutIfNeeded()
//            })
//        { (completed) in
//            print("HIDDEN")
//        }
    }

    // MARK: Private

    private func populateUI(with stageContent: StageContent?) {
        guard isViewLoaded() else {
            return
        }

        print("populateUI -> \(stageContent)")
        authorLabel.text = stageContent?.content.author.name ?? ""
        titleLabel.text = stageContent?.metaData?.title ?? ""

        if let profileImageURL = stageContent?.content.author.previewImageURL(ofMinimumSize: profileButton.bounds.size) {
            print("profileImageURL -> \(profileImageURL)")
            profileButton?.setProfileImageURL(profileImageURL, forState: .Normal)
        }

        view.setNeedsLayout()
    }

    @IBAction private func profileAction(sender: UIButton) {
        print("Tapped Avatar!")
        // TODO: open profile
    }
}
