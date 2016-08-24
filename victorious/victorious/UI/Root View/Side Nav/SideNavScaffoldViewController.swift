//
//  SideNavScaffoldViewController.swift
//  victorious
//
//  Created by Patrick Lynch on 3/19/16.
//  Copyright © 2016 victorious. All rights reserved.
//

import SDWebImage
import UIKit

/// A scaffold view controller that uses a `SideMenuController` for its UI.
class SideNavScaffoldViewController: UIViewController, Scaffold, UINavigationControllerDelegate {
    // MARK: - Configuration
    
    private static let estimatedBarButtonWidth: CGFloat = 60.0
    
    // MARK: - Initializing
    
    init(dependencyManager: VDependencyManager) {
        self.dependencyManager = dependencyManager
        
        let leftViewController = dependencyManager.viewControllerForKey("leftNavigation")
        let centerViewController = dependencyManager.viewControllerForKey("centerScreen")
        let rightNavViewController = dependencyManager.viewControllerForKey("rightNavigation")
        
        if leftViewController == nil || centerViewController == nil {
            assertionFailure("`SideNavScaffoldViewController` requires `leftNavigation` and `centerScreen` subcomponents.")
        }
        
        self.centerViewController = centerViewController
        self.rightNavViewController = rightNavViewController
        
        centerWrapperViewController.addChildViewController(centerViewController)
        centerWrapperViewController.view.addSubview(centerViewController.view)
        centerWrapperViewController.view.v_addFitToParentConstraintsToSubview(centerViewController.view)
        centerViewController.didMoveToParentViewController(centerWrapperViewController)
        
        mainNavigationController = UINavigationController(rootViewController: centerWrapperViewController)
        
        sideMenuController = SideMenuController(
            centerViewController: mainNavigationController,
            leftViewController: leftViewController
        )
        
        coachmarkManager = CoachmarkManager(dependencyManager: dependencyManager)
        
        super.init(nibName: nil, bundle: nil)
        
        mainNavigationController.delegate = self
        
        addChildViewController(sideMenuController)
        view.addSubview(sideMenuController.view)
        view.v_addFitToParentConstraintsToSubview(sideMenuController.view)
        sideMenuController.didMoveToParentViewController(self)
        
        let navigationBar = mainNavigationController.navigationBar
        navigationBar.translucent = false
        dependencyManager.applyStyleToNavigationBar(navigationBar)
        
        let backArrowImage = UIImage(named: "BackArrow")
        navigationBar.backIndicatorImage = backArrowImage
        navigationBar.backIndicatorTransitionMaskImage = backArrowImage
    }
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported.")
    }
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        performCommonInitialSetup()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(loggedInStatusDidChange), name: kLoggedInChangedNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(mainFeedFilterDidChange), name: RESTForumNetworkSource.updateStreamURLNotification, object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if !hasPerformedFirstLaunchSetup {
            hasPerformedFirstLaunchSetup = true
            performSetup { [weak self] in
                // FUTURE: This is bad architecture since we don't want side nav to know about ForumViewController at all.
                // But this is required right now to guarantee that we start loading main feed after tutorials are dismissed.
                // Otherwise, we have the bug that main feed shows up empty after dismissing tutorials.
                // We filed a ticket to fix this properly by implementing some transition between flows
                guard let forumVC = self?.centerViewController as? ForumViewController else {
                    return
                }
                forumVC.forumNetworkSource?.setUpIfNeeded()
            }
            setupNavigationButtons()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if presentedViewController == nil {
            InterstitialManager.sharedInstance.showNextInterstitial(onViewController: self)
        }
        
    }
    
    // MARK: - Setup
    
    private var hasPerformedFirstLaunchSetup = false
    
    private func setupNavigationButtons() {
        centerWrapperViewController.navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(named: "Hamburger"),
            style: .Plain,
            target: self,
            action: #selector(leftNavButtonWasPressed)
        )
        
        if rightNavViewController != nil {
            let avatarView = AvatarView()
            self.avatarView = avatarView
            avatarView.user = VCurrentUser.user()
            avatarView.sizeToFit()
            
            let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(rightNavButtonWasPressed))
            avatarView.addGestureRecognizer(tapRecognizer)
            
            centerWrapperViewController.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: avatarView)
        }
    }
    
    // MARK: - Dependency manager
    
    let dependencyManager: VDependencyManager
    
    // MARK: - Views and view controllers
    
    /// The side menu controller that manages the overall layout and interaction of the scaffold.
    let sideMenuController: SideMenuController
    
    /// The navigation controller that contains the center view controller.
    let mainNavigationController: UINavigationController
    
    /// A view controller that wraps the `centerViewController` to allow configuration of navigation items.
    let centerWrapperViewController = UIViewController()
    
    /// The view controller that displays the center content.
    let centerViewController: UIViewController?
    
    /// The view controller that displays the right navigation area.
    let rightNavViewController: UIViewController?
    
    /// The avatar view used as the right navigation button.
    private var avatarView: AvatarView?
    
    // MARK: - Actions
    
    @objc private func leftNavButtonWasPressed() {
        sideMenuController.toggleSideViewController(on: .left, animated: true)
    }
    
    /// A flag we use to prevent crashes due to pushing the right nav multiple times. Tapping the right nav button
    /// repeatedly during a navigation controller pop transition queues up multiple pushes of the same right-nav view
    /// controller. The navigation controller doesn't list the right nav view controller in its `viewControllers`
    /// property, so we can't check that it's already been pushed that way. Thus, this flag is born.
    private var allowsRightNavigation = true
    
    @objc private func rightNavButtonWasPressed() {
        guard allowsRightNavigation else {
            return
        }
        
        if let rightNavViewController = rightNavViewController {
            allowsRightNavigation = false
            mainNavigationController.pushViewController(rightNavViewController, animated: true)
        }
    }
    
    // MARK: - Status bar
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        let navigationBarTextColor = dependencyManager.dependencyManagerForNavigationBar().colorForKey(VDependencyManagerMainTextColorKey)
        return StatusBarUtilities.statusBarStyle(color: navigationBarTextColor)
    }
    
    override func childViewControllerForStatusBarHidden() -> UIViewController? {
        return sideMenuController
    }
    
    // MARK: - Notifications
    
    private dynamic func loggedInStatusDidChange(notification: NSNotification) {
        handleLoggedInStatusChange()
        avatarView?.user = VCurrentUser.user()
    }
    
    private dynamic func mainFeedFilterDidChange(notification: NSNotification) {
        sideMenuController.closeSideViewController(animated: true)
        if let title = (notification.userInfo?["selectedItem"] as? ReferenceWrapper<ListMenuSelectedItem>)?.value.title {
            mainNavigationController.navigationBar.topItem?.titleView = nil
            mainNavigationController.navigationBar.topItem?.title = title
        }
        else {
            // Display Creator Logo/Name
            loadNavigationBarTitle()
        }
    }
    
    private func loadNavigationBarTitle() {
        dispatch_async(dispatch_get_main_queue()) {
            self.dependencyManager.childDependencyForKey("centerScreen")?.configureNavigationItem(self.mainNavigationController.navigationBar.topItem)
        }
    }
    
    // MARK: - Orientation
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return [.Portrait]
    }
    
    // MARK: - Layout
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Shouldn't be necessary, but UIBarButtonItem doesn't trigger layoutSubviews properly otherwise.
        avatarView?.setNeedsLayout()
        avatarView?.layoutIfNeeded()
    }
    
    // MARK: - Scaffold
    
    let coachmarkManager: CoachmarkManager
    
    // MARK: - UINavigationControllerDelegate
    
    func navigationController(navigationController: UINavigationController, didShowViewController viewController: UIViewController, animated: Bool) {
        allowsRightNavigation = navigationController.viewControllers.count <= 1
        sideMenuController.panningIsEnabled = navigationController.viewControllers.count <= 1
        viewController.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
    }
}
