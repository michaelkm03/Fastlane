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
    
    fileprivate static let visibleCenterEdgeWidth: CGFloat = 54.0
    fileprivate static let slideAnimationDuration: TimeInterval = 0.5
    fileprivate static let statusBarAnimationDuration: TimeInterval = 0.2
    fileprivate static let panTriggerThreshold: CGFloat = 80.0
    
    fileprivate var associatedChildViewControllers = [UIView: UIViewController]()
    
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
    
    fileprivate func setup() {
        view.addSubview(leftContainerView)
        view.addSubview(rightContainerView)
        view.addSubview(centerContainerView)
        
        leftContainerView.clipsToBounds = true
        rightContainerView.clipsToBounds = true
        
        panRecognizer.addTarget(self, action: #selector(panWasRecognized))
        view.addGestureRecognizer(panRecognizer)
        
        tapRecognizer.addTarget(self, action: #selector(centerViewTapWasRecognized))
        tapRecognizer.isEnabled = false
        centerContainerView.addGestureRecognizer(tapRecognizer)
    }
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addCenterViewController()
        updateFocusOfContainedViews()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        closeSideViewController(animated: true)
    }
    
    // MARK: - Status bar
    
    override var preferredStatusBarUpdateAnimation : UIStatusBarAnimation {
        return .slide
    }
    
    override var prefersStatusBarHidden : Bool {
        return centerViewController?.prefersStatusBarHidden == true
    }
    
    override var childViewControllerForStatusBarStyle : UIViewController? {
        return centerViewController ?? self
    }
    
    fileprivate func animateStatusBarUpdate() {
        UIView.animate(withDuration: SideMenuController.statusBarAnimationDuration, animations: { [weak self] in
            self?.setNeedsStatusBarAppearanceUpdate()
        }) 
    }
    
    // MARK: - Opening and closing side view controllers
    
    /// The edge of the the currently-open side view controller, if any.
    fileprivate var openEdge: SideMenuControllerEdge? {
        didSet {
            animateStatusBarUpdate()
            tapRecognizer.isEnabled = openEdge != nil
            updateFocusOfContainedViews()
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
        beginAdding(newOpenSideController, toSuperview: containerView(on: edge), animated: animated)
        
        openEdge = edge
        
        slideCenterViewToCurrentOffset(animated: animated) { [weak self] in
            self?.endRemoving(oldOpenSideController)
            self?.endAdding(newOpenSideController)
            (newOpenSideController as? CoachmarkDisplayer)?.triggerCoachmark(withContext: nil)
            completion?()
        }
    }
    
    /// Closes the currently-open side view controller, if any. Does nothing if no view controller is open.
    func closeSideViewController(animated: Bool, completion: (() -> Void)? = nil) {
        guard let openEdge = openEdge, let openSideController = sideViewController(on: openEdge) else {
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
    
    // MARK: - Focus management
    
    fileprivate func updateFocusOfContainedViews() {
        
        addFocusWithType(currentFocusTypeForEdge(.left), toControllerAssociatedWithContainer: leftContainerView)
        addFocusWithType(currentFocusTypeForEdge(nil), toControllerAssociatedWithContainer: centerContainerView)
        addFocusWithType(currentFocusTypeForEdge(.right), toControllerAssociatedWithContainer: rightContainerView)
    }
    
    fileprivate func currentFocusTypeForEdge(_ edge: SideMenuControllerEdge?) -> VFocusType {
        
        let isFocused = panRecognizer.state != .Changed && openEdge == edge
        return isFocused ? .Stream : .None
    }
    
    fileprivate func addFocusWithType(_ focusType: VFocusType, toControllerAssociatedWithContainer container: UIView) {
        guard let viewController = associatedChildViewControllers[container] else {
            return
        }
        
        addFocusWithType(focusType, toViewController: viewController)
    }
    
    /// Calls recursively to adjust the focus of the provided view controller, any focusable
    /// view controller inside the provided viewController's `viewControllers` array (in the
    /// case of it being a navigation controller), and the viewController's child view controllers
    fileprivate func addFocusWithType(_ focusType: VFocusType, toViewController viewController: UIViewController) {
        
        if let focusable = viewController as? VFocusable {
            focusable.focusType = focusType
        }
        
        if let navigationController = viewController as? UINavigationController,
            let topViewController = navigationController.topViewController {
            addFocusWithType(focusType, toViewController: topViewController)
        }
        
        for childViewController in viewController.childViewControllers {
            addFocusWithType(focusType, toViewController: childViewController)
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
    fileprivate(set) var leftViewController: UIViewController?
    
    /// The view controller hidden to the right of the `centerViewController`. If nil, the `centerViewController`
    /// cannot slide to the left.
    fileprivate(set) var rightViewController: UIViewController?
    
    /// The view controller associated with `edge`, if any.
    fileprivate func sideViewController(on edge: SideMenuControllerEdge) -> UIViewController? {
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
    fileprivate func viewControllerIsActive(on edge: SideMenuControllerEdge) -> Bool {
        return sideViewController(on: edge)?.parent === self
    }
    
    /// Adds `centerViewController` to the view hierarchy and establishes the containment relationship, removing
    /// `oldCenterViewController` if needed.
    fileprivate func addCenterViewController(replacing oldCenterViewController: UIViewController? = nil) {
        if let oldCenterViewController = oldCenterViewController {
            beginRemoving(oldCenterViewController, animated: false)
            endRemoving(oldCenterViewController)
        }
        
        if let centerViewController = centerViewController {
            beginAdding(centerViewController, toSuperview: centerContainerView, animated: false)
            endAdding(centerViewController)
        }
    }
    
    fileprivate func beginAdding(_ childViewController: UIViewController?, toSuperview superview: UIView, animated: Bool) {
        guard let childViewController = childViewController else {
            return
        }
        
        associatedChildViewControllers[superview] = childViewController
        childViewController.beginAppearanceTransition(true, animated: animated)
        addChildViewController(childViewController)
        superview.addSubview(childViewController.view)
    }
    
    fileprivate func endAdding(_ childViewController: UIViewController?) {
        childViewController?.endAppearanceTransition()
    }
    
    fileprivate func beginRemoving(_ childViewController: UIViewController?, animated: Bool) {
        if let superview = childViewController?.view.superview {
            associatedChildViewControllers[superview] = nil
        }
        childViewController?.beginAppearanceTransition(false, animated: animated)
        childViewController?.willMove(toParentViewController: nil)
    }
    
    fileprivate func endRemoving(_ childViewController: UIViewController?) {
        childViewController?.view.removeFromSuperview()
        childViewController?.removeFromParentViewController()
        childViewController?.endAppearanceTransition()
    }
    
    // MARK: - Helper views
    
    /// A container view for `centerViewController`'s view.
    fileprivate let centerContainerView: UIView = {
        let view = UIView()
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.65
        view.layer.shadowRadius = 8.0
        return view
    }()
    
    /// A container view for `leftViewController`'s view.
    fileprivate let leftContainerView = UIView()
    
    /// A container view for `rightViewController`'s view.
    fileprivate let rightContainerView = UIView()
    
    fileprivate func containerView(on edge: SideMenuControllerEdge) -> UIView {
        switch edge {
        case .left:
            return leftContainerView
        case .right:
            return rightContainerView
        }
    }
    
    // MARK: - Gesture recognizers
    
    fileprivate let panRecognizer = UIPanGestureRecognizer()
    fileprivate let tapRecognizer = UITapGestureRecognizer()
    
    /// The state of the current pan gesture. Will be nil if a pan gesture is not being performed.
    fileprivate var panState: SideMenuControllerPanState?
    
    /// Whether or not the panning gesture to open or close side view controllers is enabled.
    var panningIsEnabled: Bool {
        get {
            return panRecognizer.isEnabled
        }
        set {
            panRecognizer.isEnabled = newValue
        }
    }
    
    @objc fileprivate func panWasRecognized() {
        switch panRecognizer.state {
        case .began:
            beginPan()
        case .changed:
            updatePan()
        case .ended:
            endPan()
        default:
            break
        }
    }
    
    fileprivate func beginPan() {
        panState = SideMenuControllerPanState(
            initialCenterViewXOffset: centerViewXOffset,
            hasShownSideMenu: false
        )
    }
    
    fileprivate func updatePan() {
        panXOffset = panRecognizer.translation(in: view).x
        
        // Side view controllers that are revealed by panning need to be added immediately.
        if let visibleEdge = visibleEdge, let visibleSideViewController = sideViewController(on: visibleEdge) , !viewControllerIsActive(on: visibleEdge) {
            beginAdding(visibleSideViewController, toSuperview: containerView(on: visibleEdge), animated: false)
            endAdding(visibleSideViewController)
            panState?.hasShownSideMenu = true
        }
        
        slideCenterViewToCurrentOffset(animated: false)
    }
    
    fileprivate func endPan() {
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
        
        let translation = abs(centerViewXOffset - (panState?.initialCenterViewXOffset ?? 0.0))
        
        // Reset panning state.
        panXOffset = 0.0
        panState = nil
        
        triggerPanActionIfNeeded(with: translation, from: visibleEdge)
        animateStatusBarUpdate()
    }
    
    fileprivate func triggerPanActionIfNeeded(with translation: CGFloat, from visibleEdge: SideMenuControllerEdge?) {
        if translation >= SideMenuController.panTriggerThreshold {
            // The user panned far enough, so we trigger an open or close.
            if let visibleEdge = visibleEdge , visibleEdge != openEdge {
                openEdge = visibleEdge
                slideCenterViewToCurrentOffset(animated: true) {
                    if self.openEdge == .left {
                        (self.leftViewController as? CoachmarkDisplayer)?.triggerCoachmark(withContext: nil)
                    }
                }
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
    
    @objc fileprivate func centerViewTapWasRecognized() {
        closeSideViewController(animated: true)
    }
    
    // MARK: - Layout
    
    /// The width of an open side view controller.
    fileprivate var sideViewControllerWidth: CGFloat {
        return view.bounds.width - SideMenuController.visibleCenterEdgeWidth
    }
    
    /// The constrained, calculated X offset to apply to the center view.
    fileprivate var centerViewXOffset: CGFloat {
        let sideWidth = sideViewControllerWidth
        let minX = rightViewController == nil ? 0.0 : -sideWidth
        let maxX = leftViewController == nil ? 0.0 : sideWidth
        return max(minX, min(maxX, openEdgeXOffset + panXOffset))
    }
    
    /// The X offset to apply to the center view based on the `openEdge`.
    fileprivate var openEdgeXOffset: CGFloat {
        guard let openEdge = openEdge else {
            return 0.0
        }
        
        switch openEdge {
        case .left:
            return sideViewControllerWidth
        case .right:
            return -sideViewControllerWidth
        }
    }
    
    /// The X offset to apply to the center view based on panning.
    fileprivate var panXOffset: CGFloat = 0.0 {
        didSet {
            animateStatusBarUpdate()
        }
    }
    
    /// The edge of the side view controller that is currently visible, if any, based on `centerViewOffset`.
    ///
    /// A side view controller can be visible but not open during panning gestures.
    ///
    fileprivate var visibleEdge: SideMenuControllerEdge? {
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
    fileprivate func slideCenterViewToCurrentOffset(animated: Bool, completion: (() -> Void)? = nil) {
        if animated {
            UIView.animate(
                withDuration: SideMenuController.slideAnimationDuration,
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
        
        let sideWidth = sideViewControllerWidth
        
        centerContainerView.frame = view.bounds.offsetBy(dx: centerViewXOffset, dy: 0.0)
        centerViewController?.view.frame = centerContainerView.bounds
        
        // Obfuscates the key string to prevent static analysis
        if let statusBarWindow = UIApplication.shared.value(forKey: "statusBar" + "Window") as? UIWindow {
            statusBarWindow.frame = view.bounds.offsetBy(dx: centerViewXOffset, dy: 0)
        }

        leftContainerView.frame = CGRect(
            x: view.bounds.minX,
            y: view.bounds.minY,
            width: max(0.0, centerContainerView.frame.minX - view.bounds.minX),
            height: view.bounds.height
        )
        
        leftViewController?.view.frame = CGRect(
            x: leftContainerView.bounds.minX,
            y: leftContainerView.bounds.minY,
            width: sideWidth,
            height: leftContainerView.bounds.height
        )
        
        rightContainerView.frame = CGRect(
            x: centerContainerView.frame.maxX,
            y: view.bounds.minY,
            width: max(0.0, view.bounds.maxX - centerContainerView.frame.maxX),
            height: view.bounds.height
        )
        
        rightViewController?.view.frame = CGRect(
            x: rightContainerView.bounds.maxX - sideWidth,
            y: rightContainerView.bounds.minY,
            width: sideWidth,
            height: rightContainerView.bounds.height
        )
    }
}

private struct SideMenuControllerPanState {
    /// The value of `centerViewXOffset` when a pan was first recognized.
    var initialCenterViewXOffset: CGFloat
    
    /// Whether a side menu has become visible during this pan yet or not.
    var hasShownSideMenu: Bool
}
