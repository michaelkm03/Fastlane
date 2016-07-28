//
//  VTabScaffoldViewController.swift
//  victorious
//
//  Created by Jarod Long on 4/21/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

/// A scaffold view controller that uses a `UITabBarController` for its user interface.
class VTabScaffoldViewController: UIViewController, Scaffold, UITabBarControllerDelegate {
    // MARK: - Initializing
    
    init(dependencyManager: VDependencyManager) {
        self.dependencyManager = dependencyManager
        tabShim = dependencyManager.templateValueOfType(VTabMenuShim.self, forKey: "menu") as? VTabMenuShim
        self.coachmarkManager = CoachmarkManager(dependencyManager: dependencyManager)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init(coder: NSCoder) {
        fatalError("NSCoding not supported.")
    }
    
    deinit {
        internalTabBarController.delegate = nil
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        performCommonInitialSetup()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(loggedInStatusDidChange(_: )), name: kLoggedInChangedNotification, object: nil)
        
        addChildViewController(mainNavigationController)
        mainNavigationController.view.frame = view.bounds
        mainNavigationController.view.translatesAutoresizingMaskIntoConstraints = false
        mainNavigationController.setNavigationBarHidden(true)
        mainNavigationController.innerNavigationController.navigationBar.translucent = false
        dependencyManager.applyStyleToNavigationBar(mainNavigationController.innerNavigationController.navigationBar)
        view.addSubview(mainNavigationController.view)
        view.v_addFitToParentConstraintsToSubview(mainNavigationController.view)
        mainNavigationController.didMoveToParentViewController(self)
        
        if VCurrentUser.user() != nil {
            configureTabBar()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if !AgeGate.isAnonymousUser() && !hasPerformedFirstLaunchSetup {
            hasPerformedFirstLaunchSetup = true
            
            performSetup { [weak self] in
                self?.configureTabBar()
            }
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
    
    private func configureTabBar() {
        guard !mainNavigationController.innerNavigationController.viewControllers.contains(internalTabBarController) else {
            return
        }
        
        internalTabBarController.delegate = self
        internalTabBarController.tabBar.tintColor = tabShim?.selectedIconColor
        internalTabBarController.viewControllers = tabShim?.wrappedNavigationDesinations() as? [UIViewController]
        hidingHelper = VTabScaffoldHidingHelper(tabBar: internalTabBarController.tabBar)
        
        if let tabBarBackground = tabShim?.background as? VSolidColorBackground {
            internalTabBarController.tabBar.translucent = false
            internalTabBarController.tabBar.barTintColor = tabBarBackground.backgroundColor
        }
        
        mainNavigationController.innerNavigationController.pushViewController(internalTabBarController, animated: false)
    }
    
    // MARK: - Dependency manager
    
    let dependencyManager: VDependencyManager
    
    // MARK: - View controllers
    
    let internalTabBarController: UITabBarController = NavigationBarHiddenTabViewController()
    let mainNavigationController = VNavigationController()
    var willSelectContainerViewController: VNavigationDestinationContainerViewController?
    
    override var tabBarController: UITabBarController? {
        return internalTabBarController
    }
    
    func setSelectedMenuItemAtIndex(index: Int) {
        let tabCount = internalTabBarController.viewControllers?.count ?? 0
        
        guard 0 ..< tabCount ~= index else {
            assertionFailure("Cannot select tab at index \(index). There are only \(tabCount) tabs.")
            return
        }
        
        internalTabBarController.selectedIndex = index
    }
    
    // MARK: - Tab bar helpers
    
    private let tabShim: VTabMenuShim?
    private var hidingHelper: VTabScaffoldHidingHelper?
    
    // MARK: - Orientation
    
    override func shouldAutorotate() -> Bool {
        return false
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return [.Portrait]
    }
    
    // MARK: - Status bar
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        let navigationBarTextColor = dependencyManager.dependencyManagerForNavigationBar().colorForKey(VDependencyManagerMainTextColorKey)
        return StatusBarUtilities.statusBarStyle(color: navigationBarTextColor)
    }
    
    override func childViewControllerForStatusBarHidden() -> UIViewController? {
        return internalTabBarController
    }
    
    override func childViewControllerForStatusBarStyle() -> UIViewController? {
        return internalTabBarController
    }
    
    // MARK: - Notifications
    
    func loggedInStatusDidChange(notification: NSNotification) {
        handleLoggedInStatusChange()
    }
    
    // MARK: - Scaffold
    
    let coachmarkManager: CoachmarkManager
    
    var navigationDestinations: [VNavigationDestination] {
        return internalTabBarController.viewControllers?.flatMap { viewController in
            if let containerViewController = viewController as? VNavigationDestinationContainerViewController {
                return containerViewController.navigationDestination
            } else {
                return viewController as? VNavigationDestination
            }
        } ?? []
    }
    
    
    // MARK: - UITabBarControllerDelegate
    
    func tabBarController(tabBarController: UITabBarController, shouldSelectViewController viewController: UIViewController) -> Bool {
        if viewController === tabBarController.selectedViewController {
            (viewController as? VTabMenuContainedViewControllerNavigation)?.reselected()
            return false
        }
        
        if let index = tabBarController.viewControllers?.indexOf(viewController) {
            tabShim?.willNavigateToIndex(index)
        }
        
        if let navigationDestinationContainer = viewController as? VNavigationDestinationContainerViewController {
            willSelectContainerViewController = navigationDestinationContainer
        }
        
        return false
    }
}
