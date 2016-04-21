//
//  SideMenuController.swift
//  victorious
//
//  Created by Jarod Long on 4/19/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

/// An enum for the edges that a `SideMenuController` can have view controllers on.
enum SideMenuControllerEdge {
    case left, right
}

/// A general-purpose container view controller similar in concept to UIKit containers like `UINavigationController`
/// and `UITabBarController`.
///
/// A side menu controller manages up to three child view controllers. It should always be configured with a
/// `centerViewController`, which normally occupies the container's entire view. In addition, it can optionally have a
/// `leftViewController` and `rightViewController`, which generally act as menus. The `centerViewController` can slide
/// left or right by gesture or programmatically to reveal the left and right view controllers underneath.
///
class SideMenuController: UIViewController {
    // MARK: - Config
    
    private static let sideViewControllerWidth: CGFloat = 260.0
    private static let slideAnimationDuration: NSTimeInterval = 0.5
    private static let statusBarAnimationDuration: NSTimeInterval = 0.2
    private static let panTriggerThreshold: CGFloat = 80.0
    
    // MARK: - Initializing
    
    init(centerViewController: UIViewController? = nil, leftViewController: UIViewController? = nil, rightViewController: UIViewController? = nil) {
        self.centerViewController = centerViewController
        self.leftViewController = leftViewController
        self.rightViewController = rightViewController
        super.init(nibName: nil, bundle: nil)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        view.addSubview(centerContainerView)
        
        panRecognizer.addTarget(self, action: #selector(SideMenuController.panWasRecognized))
        view.addGestureRecognizer(panRecognizer)
        
        tapRecognizer.addTarget(self, action: #selector(SideMenuController.centerViewTapWasRecognized))
        tapRecognizer.enabled = false
        centerContainerView.addGestureRecognizer(tapRecognizer)
    }
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addCenterViewController()
    }
    
    // MARK: - Status bar
    
    override func preferredStatusBarUpdateAnimation() -> UIStatusBarAnimation {
        return .Slide
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return centerViewXOffset != 0.0 || panRecognizer.state == .Changed || centerViewController?.prefersStatusBarHidden() == true
    }
    
    override func childViewControllerForStatusBarStyle() -> UIViewController? {
        return centerViewController ?? self
    }
    
    private func animateStatusBarUpdate() {
        UIView.animateWithDuration(SideMenuController.statusBarAnimationDuration) { [weak self] in
            self?.setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    // MARK: - Opening and closing side view controllers
    
    /// The edge of the the currently-open side view controller, if any.
    private var openEdge: SideMenuControllerEdge? {
        didSet {
            animateStatusBarUpdate()
            tapRecognizer.enabled = openEdge != nil
        }
    }
    
    /// Opens the side view controller on `edge`. Does nothing if the view controller on `edge` is already open.
    ///
    /// - REQUIRES: The view controller associated with `edge` is not nil.
    ///
    func openSideViewController(on edge: SideMenuControllerEdge, animated: Bool, completion: (() -> Void)? = nil) {
        guard edge != openEdge else {
            return
        }
        
        let oldOpenSideController = openEdge.flatMap { sideViewController(on: $0) }
        
        guard let newOpenSideController = sideViewController(on: edge) else {
            assertionFailure("Tried to show controller on edge \(edge) in a SideMenuController, but no controller was set for that edge.")
            return
        }
        
        beginRemoving(oldOpenSideController, animated: animated)
        beginAdding(newOpenSideController, animated: animated, below: centerContainerView)
        
        openEdge = edge
        
        slideCenterViewToCurrentOffset(animated: animated) { [weak self] in
            self?.endRemoving(oldOpenSideController)
            self?.endAdding(newOpenSideController)
            completion?()
        }
    }
    
    /// Closes the currently-open side view controller, if any. Does nothing if no view controller is open.
    func closeSideViewController(animated animated: Bool, completion: (() -> Void)? = nil) {
        guard let openEdge = openEdge, openSideController = sideViewController(on: openEdge) else {
            return
        }
        
        beginRemoving(openSideController, animated: animated)
        
        self.openEdge = nil
        
        slideCenterViewToCurrentOffset(animated: animated) { [weak self] in
            self?.endRemoving(openSideController)
            completion?()
        }
    }
    
    /// Toggles the side view controller on `edge`.
    ///
    /// - REQUIRES: The view controller associated with `edge` is not nil.
    ///
    func toggleSideViewController(on edge: SideMenuControllerEdge, animated: Bool, completion: (() -> Void)? = nil) {
        if openEdge == edge {
            closeSideViewController(animated: animated, completion: completion)
        } else {
            openSideViewController(on: edge, animated: animated, completion: completion)
        }
    }
    
    // MARK: - Managing child view controllers
    
    /// The view controller which normally occupies the entire container and displays the main content.
    var centerViewController: UIViewController? {
        didSet {
            if centerViewController !== oldValue {
                addCenterViewController(replacing: oldValue)
            }
        }
    }
    
    /// The view controller hidden to the left of the `centerViewController`. If nil, the `centerViewController` cannot
    /// slide to the right.
    private(set) var leftViewController: UIViewController?
    
    /// The view controller hidden to the right of the `centerViewController`. If nil, the `centerViewController`
    /// cannot slide to the left.
    private(set) var rightViewController: UIViewController?
    
    /// The view controller associated with `edge`, if any.
    private func sideViewController(on edge: SideMenuControllerEdge) -> UIViewController? {
        switch edge {
        case .left:
            return leftViewController
        case .right:
            return rightViewController
        }
    }
    
    /// Whether or not the view controller associated with `edge` is active, meaning it has been added to the view
    /// hierarchy.
    ///
    /// Being active doesn't necessarily mean that the view controller is open or visible. Side view controllers can be
    /// temporarily added during panning gestures.
    ///
    private func viewControllerIsActive(on edge: SideMenuControllerEdge) -> Bool {
        return sideViewController(on: edge)?.parentViewController === self
    }
    
    /// Adds `centerViewController` to the view hierarchy and establishes the containment relationship, removing
    /// `oldCenterViewController` if needed.
    private func addCenterViewController(replacing oldCenterViewController: UIViewController? = nil) {
        if let oldCenterViewController = oldCenterViewController {
            beginRemoving(oldCenterViewController, animated: false)
            endRemoving(oldCenterViewController)
        }
        
        if let centerViewController = centerViewController {
            addChildViewController(centerViewController)
            centerContainerView.addSubview(centerViewController.view)
        }
    }
    
    private func beginAdding(childViewController: UIViewController?, animated: Bool, below overlappingSubview: UIView? = nil) {
        guard let childViewController = childViewController else {
            return
        }
        
        childViewController.beginAppearanceTransition(true, animated: animated)
        addChildViewController(childViewController)
        
        if let overlappingSubview = overlappingSubview {
            view.insertSubview(childViewController.view, belowSubview: overlappingSubview)
        } else {
            view.addSubview(childViewController.view)
        }
    }
    
    private func endAdding(childViewController: UIViewController?) {
        childViewController?.endAppearanceTransition()
    }
    
    private func beginRemoving(childViewController: UIViewController?, animated: Bool) {
        childViewController?.beginAppearanceTransition(false, animated: animated)
        childViewController?.willMoveToParentViewController(nil)
    }
    
    private func endRemoving(childViewController: UIViewController?) {
        childViewController?.view.removeFromSuperview()
        childViewController?.removeFromParentViewController()
        childViewController?.endAppearanceTransition()
    }
    
    // MARK: - Helper views
    
    /// A container view for `centerViewController`'s view.
    private let centerContainerView: UIView = {
        let view = UIView()
        view.layer.shadowColor = UIColor.blackColor().CGColor
        view.layer.shadowOpacity = 0.65
        view.layer.shadowRadius = 8.0
        return view
    }()
    
    // MARK: - Gesture recognizers
    
    private let panRecognizer = UIPanGestureRecognizer()
    private let tapRecognizer = UITapGestureRecognizer()
    
    /// The value of `centerViewXOffset` when a pan was first recognized.
    private var initialPanningCenterViewXOffset: CGFloat = 0.0
    
    @objc private func panWasRecognized() {
        switch panRecognizer.state {
        case .Began:
            beginPan()
        case .Changed:
            updatePan()
        case .Ended:
            endPan()
        default:
            break
        }
    }
    
    private func beginPan() {
        initialPanningCenterViewXOffset = centerViewXOffset
    }
    
    private func updatePan() {
        panXOffset = panRecognizer.translationInView(view).x
        
        // Side view controllers that are revealed by panning need to be added immediately.
        if let visibleEdge = visibleEdge, let visibleSideViewController = sideViewController(on: visibleEdge) where !viewControllerIsActive(on: visibleEdge) {
            beginAdding(visibleSideViewController, animated: false, below: centerContainerView)
            endAdding(visibleSideViewController)
        }
        
        slideCenterViewToCurrentOffset(animated: false)
    }
    
    private func endPan() {
        let visibleEdge = self.visibleEdge
        
        // If a side view controller was added during a pan, but is no longer visible, it needs to be removed.
        if visibleEdge != .left && viewControllerIsActive(on: .left) {
            beginRemoving(leftViewController, animated: false)
            endRemoving(leftViewController)
        }
        
        if visibleEdge != .right && viewControllerIsActive(on: .right) {
            beginRemoving(rightViewController, animated: false)
            endRemoving(rightViewController)
        }
        
        let translation = abs(centerViewXOffset - initialPanningCenterViewXOffset)
        
        // Reset panning state.
        panXOffset = 0.0
        initialPanningCenterViewXOffset = 0.0
        
        triggerPanActionIfNeeded(with: translation, from: visibleEdge)
    }
    
    private func triggerPanActionIfNeeded(with translation: CGFloat, from visibleEdge: SideMenuControllerEdge?) {
        if translation >= SideMenuController.panTriggerThreshold {
            // The user panned far enough, so we trigger an open or close.
            if let visibleEdge = visibleEdge where visibleEdge != openEdge {
                openEdge = visibleEdge
                slideCenterViewToCurrentOffset(animated: true)
            }
            else if openEdge != nil {
                closeSideViewController(animated: true)
            }
            else {
                slideCenterViewToCurrentOffset(animated: true)
            }
        }
        else {
            // The user didn't pan far enough, so we slide back to our original position. If we're animating back
            // to a closed state, we need to remove the visible side view controller, if any.
            let visibleViewController = visibleEdge.flatMap { sideViewController(on: $0) }
            
            if openEdge == nil {
                beginRemoving(visibleViewController, animated: true)
            }
            
            slideCenterViewToCurrentOffset(animated: true) { [weak self] in
                if self?.openEdge == nil {
                    self?.endRemoving(visibleViewController)
                }
            }
        }
    }
    
    @objc private func centerViewTapWasRecognized() {
        closeSideViewController(animated: true)
    }
    
    // MARK: - Layout
    
    /// The constrained, calculated X offset to apply to the center view.
    private var centerViewXOffset: CGFloat {
        let sideWidth = SideMenuController.sideViewControllerWidth
        let minX = rightViewController == nil ? 0.0 : -sideWidth
        let maxX = leftViewController == nil ? 0.0 : sideWidth
        return max(minX, min(maxX, openEdgeXOffset + panXOffset))
    }
    
    /// The X offset to apply to the center view based on the `openEdge`.
    private var openEdgeXOffset: CGFloat {
        guard let openEdge = openEdge else {
            return 0.0
        }
        
        switch openEdge {
        case .left:
            return SideMenuController.sideViewControllerWidth
        case .right:
            return -SideMenuController.sideViewControllerWidth
        }
    }
    
    /// The X offset to apply to the center view based on panning.
    private var panXOffset: CGFloat = 0.0 {
        didSet {
            animateStatusBarUpdate()
        }
    }
    
    /// The edge of the side view controller that is currently visible, if any, based on `centerViewOffset`.
    ///
    /// A side view controller can be visible but not open during panning gestures.
    ///
    private var visibleEdge: SideMenuControllerEdge? {
        switch centerViewXOffset {
        case let offset where offset < 0.0:
            return .right
        case let offset where offset > 0.0:
            return .left
        default:
            return nil
        }
    }
    
    /// Slides the center view to its appropriate offset given the state of the controller, optionally animated.
    private func slideCenterViewToCurrentOffset(animated animated: Bool, completion: (() -> Void)? = nil) {
        if animated {
            UIView.animateWithDuration(
                SideMenuController.slideAnimationDuration,
                delay: 0.0,
                usingSpringWithDamping: 1.0,
                initialSpringVelocity: 0.5,
                options: [],
                animations: { [weak self] in
                    self?.slideCenterViewToCurrentOffset(animated: false)
                },
                completion: { finished in
                    completion?()
                }
            )
        }
        else {
            view.setNeedsLayout()
            view.layoutIfNeeded()
            completion?()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        centerContainerView.frame = view.bounds.offsetBy(dx: centerViewXOffset, dy: 0.0)
        centerViewController?.view.frame = centerContainerView.bounds
        
        leftViewController?.view.frame = CGRect(
            x: view.bounds.minX,
            y: view.bounds.minY,
            width: max(0.0, centerContainerView.frame.minX - view.bounds.minX),
            height: view.bounds.height
        )
        
        rightViewController?.view.frame = CGRect(
            x: centerContainerView.frame.maxX,
            y: view.bounds.minY,
            width: max(0.0, view.bounds.maxX - centerContainerView.frame.maxX),
            height: view.bounds.height
        )
    }
}
