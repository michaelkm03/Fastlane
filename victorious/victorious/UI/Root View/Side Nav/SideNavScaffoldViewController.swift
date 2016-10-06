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
    
    fileprivate static let estimatedBarButtonWidth: CGFloat = 60.0
    
    // MARK: - Initializing
    
    init(dependencyManager: VDependencyManager) {
        self.dependencyManager = dependencyManager
        
        // Future: Get rid of the ! from Objc
        let leftViewController = dependencyManager.viewController(forKey: "leftNavigation")!
        let centerViewController = dependencyManager.viewController(forKey: "centerScreen")!
        let rightNavViewController = dependencyManager.viewController(forKey: "rightNavigation")
        
        self.centerViewController = centerViewController
        self.rightNavViewController = rightNavViewController
        
        centerWrapperViewController.addChildViewController(centerViewController)
        centerWrapperViewController.view.addSubview(centerViewController.view)
        centerWrapperViewController.view.v_addFitToParentConstraints(toSubview: centerViewController.view)
        centerViewController.didMove(toParentViewController: centerWrapperViewController)
        
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
        view.v_addFitToParentConstraints(toSubview: sideMenuController.view)
        sideMenuController.didMove(toParentViewController: self)
        
        let navigationBar = mainNavigationController.navigationBar
        navigationBar.isTranslucent = false
        dependencyManager.applyStyle(to: navigationBar)
        
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
        
        NotificationCenter.default.addObserver(self, selector: #selector(loggedInStatusDidChange), name: NSNotification.Name.loggedInChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(mainFeedFilterDidChange), name: NSNotification.Name(rawValue: RESTForumNetworkSource.updateStreamURLNotification), object: nil)
        
        showCreatorLogoTitle()
        
        if dependencyManager.shouldOpenLeftNavInitially {
            sideMenuController.openSideViewController(on: .left, animated: false)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
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
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if presentedViewController == nil {
            let _ = InterstitialManager.sharedInstance.showNextInterstitial(onViewController: self)
        }
    }
    
    // MARK: - Setup
    
    fileprivate var hasPerformedFirstLaunchSetup = false
    
    fileprivate func setupNavigationButtons() {
        centerWrapperViewController.navigationItem.leftBarButtonItem = UIBarButtonItem(
            image: UIImage(named: "Hamburger"),
            style: .plain,
            target: self,
            action: #selector(leftNavButtonWasPressed)
        )
        
        if rightNavViewController != nil {
            let profileButton = SideNavProfileButton(type: .system)
            self.profileButton = profileButton
            profileButton.addTarget(self, action: #selector(profileButtonWasPressed), for: .touchUpInside)
            profileButton.user = VCurrentUser.user
            profileButton.sizeToFit()
            
            centerWrapperViewController.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: profileButton)
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
    fileprivate var profileButton: SideNavProfileButton?
    
    // MARK: - Actions
    
    @objc fileprivate func leftNavButtonWasPressed() {
        sideMenuController.toggleSideViewController(on: .left, animated: true)
    }
    
    /// A flag we use to prevent crashes due to pushing the right nav multiple times. Tapping the right nav button
    /// repeatedly during a navigation controller pop transition queues up multiple pushes of the same right-nav view
    /// controller. The navigation controller doesn't list the right nav view controller in its `viewControllers`
    /// property, so we can't check that it's already been pushed that way. Thus, this flag is born.
    fileprivate var allowsRightNavigation = true
    
    @objc fileprivate func profileButtonWasPressed() {
        guard allowsRightNavigation else {
            return
        }
        
        if let rightNavViewController = rightNavViewController {
            allowsRightNavigation = false
            mainNavigationController.pushViewController(rightNavViewController, animated: true)
        }
    }
    
    // MARK: - Status bar
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        let navigationBarTextColor = dependencyManager.forNavigationBar().color(forKey: VDependencyManagerMainTextColorKey) ?? .black
        return StatusBarUtilities.statusBarStyle(color: navigationBarTextColor)
    }
    
    override var childViewControllerForStatusBarHidden : UIViewController? {
        return sideMenuController
    }
    
    // MARK: - Notifications
    
    fileprivate dynamic func loggedInStatusDidChange(_ notification: Notification) {
        handleLoggedInStatusChange()
        profileButton?.user = VCurrentUser.user
    }
    
    fileprivate dynamic func mainFeedFilterDidChange(_ notification: Notification) {
        sideMenuController.closeSideViewController(animated: true)
        if let title = ((notification as NSNotification).userInfo?["selectedItem"] as? ListMenuSelectedItem)?.title {
            mainNavigationController.navigationBar.topItem?.titleView = nil
            mainNavigationController.navigationBar.topItem?.title = title
        }
        else {
            showCreatorLogoTitle()
        }
    }
    
    fileprivate func showCreatorLogoTitle() {
        dependencyManager.childDependency(forKey: "centerScreen")?.configureNavigationItem(mainNavigationController.navigationBar.topItem)
    }
    
    // MARK: - Orientation
    
    override var supportedInterfaceOrientations : UIInterfaceOrientationMask {
        return [.portrait]
    }
    
    // MARK: - Layout
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Shouldn't be necessary, but UIBarButtonItem doesn't trigger layoutSubviews properly otherwise.
        profileButton?.setNeedsLayout()
        profileButton?.layoutIfNeeded()
    }
    
    // MARK: - Scaffold
    
    let coachmarkManager: CoachmarkManager
    
    // MARK: - UINavigationControllerDelegate
    
    func navigationController(_ navigationController: UINavigationController, didShow viewController: UIViewController, animated: Bool) {
        allowsRightNavigation = navigationController.viewControllers.count <= 1
        sideMenuController.panningIsEnabled = navigationController.viewControllers.count <= 1
        viewController.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
}

private extension VDependencyManager {
    var shouldOpenLeftNavInitially: Bool {
        // TODO: This should come from the template.
        return true
    }
}
