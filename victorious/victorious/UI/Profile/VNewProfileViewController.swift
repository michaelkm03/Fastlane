//
//  VNewProfileViewController.swift
//  victorious
//
//  Created by Jarod Long on 3/31/16.
//  Copyright (c) 2016 Victorious. All rights reserved.
//

import UIKit
import VictoriousIOSSDK

/// A view controller that displays the contents of a user's profile.
class VNewProfileViewController: UIViewController, ConfigurableGridStreamHeaderDelegate, AccessoryScreenContainer, CoachmarkDisplayer, VBackgroundContainer {
    
    // MARK: - Constants
    
    static let userAppearanceKey = "userAppearance"
    static let creatorAppearanceKey = "creatorAppearance"
    static let upgradeButtonID = "Accessory paygate"
    static let notificationsButtonID = "Accessory notifications"
    static let estimatedBarButtonWidth =  CGFloat(60.0)
    static let estimatedStatusBarHeight = CGFloat(20.0)
    static let estimatedNavBarRightPadding = CGFloat(10.0)
    static let goVIPButtonID = "Accessory VIP Chat"
    
    private enum ProfileScreenContext: String {
        case selfUser, otherUser, selfCreator, otherCreator
        
        var accessoryScreensKey: String {
            switch self {
                case .selfUser: return "accessories.user.own"
                case .otherUser: return "accessories.user.other"
                case .selfCreator: return "accessories.creator.own"
                case .otherCreator: return "accessories.user.creator"
            }
        }
        
        var coachmarkContext: String {
            switch self {
                case .selfUser: return "user"
                case .otherUser: return "other"
                case .selfCreator: return "self_creator"
                case .otherCreator: return "creator"
            }
        }
        
        var trackingString: String {
            switch self {
                case .selfUser: return "current_user"
                case .otherUser: return "other_user"
                case .selfCreator: return "current_user"
                case .otherCreator: return "creator"
            }
        }
    }
    
    // MARK: - Initializing
    
    init(dependencyManager: VDependencyManager) {
        self.dependencyManager = dependencyManager
        subscribeButton = SubscribeButton(dependencyManager: dependencyManager)
        subscribeButton.sizeToFit()
        
        super.init(nibName: nil, bundle: nil)

        // Applies a fallback background color while we fetch the user.
        view.backgroundColor = dependencyManager.color(forKey: VDependencyManagerBackgroundColorKey)
        
        fetchUser(using: dependencyManager)
        
        NotificationCenter.default.addObserver(self, selector: #selector(currentUserDidUpdate), name: NSNotification.Name(rawValue: VCurrentUser.userDidUpdateNotificationKey), object: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("NSCoding not supported.")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dependencyManager.addBackground(toBackgroundHost: self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        gridStreamController?.reloadHeader()
        trackViewWillAppearIfReady()
        BadgeCountManager.shared.fetchBadgeCount(for: .unreadNotifications)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        triggerCoachmark(withContext: profileScreenContext?.coachmarkContext)
        dependencyManager.trackViewWillDisappear(for: self)
    }
    
    // MARK: - Dependency Manager
    
    let dependencyManager: VDependencyManager!
    
    // MARK: - Model Data
    
    var user: UserModel? {
        return gridStreamController?.content
    }
    
    // MARK: - View controllers
    
    private var gridStreamController: GridStreamViewController<VNewProfileHeaderView>? {
        willSet {
            if let existingController = gridStreamController {
                existingController.view.removeFromSuperview()
                existingController.removeFromParentViewController()
            }
        }
    }
    
    // MARK: - Views
    
    private let subscribeButton: SubscribeButton
    
    private lazy var overflowButton: UIBarButtonItem = {
        return UIBarButtonItem(
            image: self.dependencyManager.overflowIcon,
            style: .done,
            target: self,
            action: #selector(overflow)
        )
    }()
    
    private lazy var upvoteButton: UIButton = {
        let button = BackgroundButton(type: .system)
        button.addTarget(self, action: #selector(toggleUpvote), for: .touchUpInside)
        return button
    }()
    
    private func goVIPButton(for menuItem: VNavigationMenuItem) -> UIButton {
        let button = BackgroundButton(type: .system)
        button.addTarget(self, action: #selector(goVIPButtonWasPressed), for: .touchUpInside)
        button.setTitle(menuItem.title, for: .normal)
        button.sizeToFit()
        return button
    }
    
    private let spinner = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    
    // MARK: - View updating
    
    private func updateBarButtonItems() {
        supplementalRightButtons = []
        
        guard let user = user else {
            return
        }
        
        let isCurrentUser = user.isCurrentUser
        let isCreator = user.accessLevel.isCreator
        let currentIsCreator = VCurrentUser.user?.accessLevel.isCreator == true
        let vipEnabled = dependencyManager.isVIPEnabled == true
        
        if !isCurrentUser {
            if isCreator && !currentIsCreator && vipEnabled {
                supplementalRightButtons.append(UIBarButtonItem(customView: subscribeButton))
            }
            
            if !isCreator {
                if user.isUpvoted {
                    upvoteButton.setImage(dependencyManager.upvoteIconSelected, for: .normal)
                    upvoteButton.backgroundColor = dependencyManager.upvoteIconSelectedBackgroundColor
                    upvoteButton.tintColor = dependencyManager.upvoteIconTint
                }
                else {
                    upvoteButton.setImage(dependencyManager.upvoteIconUnselected, for: .normal)
                    upvoteButton.backgroundColor = dependencyManager.upvoteIconUnselectedBackgroundColor
                    upvoteButton.tintColor = nil
                }
                
                upvoteButton.sizeToFit()
                supplementalRightButtons.append(UIBarButtonItem(customView: upvoteButton))
                supplementalRightButtons.append(overflowButton)
            }
        }
        else if
            currentIsCreator,
            let menuItems = dependencyManager.accessoryMenuItems(withKey: ProfileScreenContext.selfCreator.accessoryScreensKey) as? [VNavigationMenuItem]
        {
            let goVIPMenuItems = menuItems.filter() { $0.identifier == VNewProfileViewController.goVIPButtonID }
            if
                goVIPMenuItems.count == 1,
                let goVIPMenuItem = goVIPMenuItems.first
            {
                supplementalRightButtons.append(UIBarButtonItem(customView: goVIPButton(for: goVIPMenuItem)))
            }
        }
        
        applyAccessoryScreens(to: navigationItem, from: dependencyManager)
    }
    
    // MARK: - Actions
    
    private dynamic func goVIPButtonWasPressed() {
        guard let scaffold = VRootViewController.shared()?.scaffold else {
            return
        }
        Router(originViewController: scaffold, dependencyManager: dependencyManager).navigate(to: .vipForum, from: DeeplinkContext(value: DeeplinkContext.userProfile))
    }
    
    private dynamic func toggleUpvote() {
        guard let user = user else {
            return
        }
        
        UserUpvoteToggleOperation(
            user: user,
            upvoteAPIPath: dependencyManager.userUpvoteAPIPath,
            unupvoteAPIPath: dependencyManager.userUnupvoteAPIPath
        ).queue { [weak self] _ in
            self?.updateBarButtonItems()
        }
    }
    
    private dynamic func overflow() {
        guard let user = user else {
            return
        }
        
        let toggleBlockedOperation = UserBlockToggleOperation(
            user: user,
            blockAPIPath: dependencyManager.userBlockAPIPath,
            unblockAPIPath: dependencyManager.userUnblockAPIPath
        )
        
        let actionTitle = user.isBlocked
            ? NSLocalizedString("UnblockUser", comment: "")
            : NSLocalizedString("BlockUser", comment: "")
        let confirm = ConfirmDestructiveActionOperation(
            actionTitle: actionTitle,
            originViewController: self,
            dependencyManager: dependencyManager
        )
        
        confirm.queue() { result in
            switch result {
                case .success:
                    toggleBlockedOperation.queue() { [weak self] _ in
                        let _ = self?.navigationController?.popViewController(animated: true)
                }
                case .failure, .cancelled:
                    break
            }
        }
    }
    
    // MARK: - AccessoryScreenContainer
    
    private var supplementalLeftButtons = [UIBarButtonItem]()
    private var supplementalRightButtons = [UIBarButtonItem]()
    
    private var profileScreenContext: ProfileScreenContext? {
        guard let user = self.user else {
            return nil
        }
        
        if user.accessLevel.isCreator == true {
            return user.isCurrentUser ? ProfileScreenContext.selfCreator : ProfileScreenContext.otherCreator
        }
        else {
            return user.isCurrentUser ? ProfileScreenContext.selfUser : ProfileScreenContext.otherUser
        }
    }
    
    var accessoryScreensKey: String? {
        return profileScreenContext?.accessoryScreensKey
    }
    
    func addCustomLeftItems(to items: [AccessoryScreenBarButtonItem]) -> [UIBarButtonItem] {
        return items.filter({ shouldDisplay(screen: $0.accessoryScreen) }) + supplementalLeftButtons
    }
    
    func addCustomRightItems(to items: [AccessoryScreenBarButtonItem]) -> [UIBarButtonItem] {
        return items.filter({ shouldDisplay(screen: $0.accessoryScreen) }) + supplementalRightButtons
    }
    
    private func shouldDisplay(screen: AccessoryScreen) -> Bool {
        return ![VNewProfileViewController.upgradeButtonID, VNewProfileViewController.goVIPButtonID].contains(screen.id)
    }
    
    func badgeCountType(for screen: AccessoryScreen) -> BadgeCountType? {
        switch screen.id {
            case VNewProfileViewController.notificationsButtonID: return .unreadNotifications
            default: return nil
        }
    }
    
    func navigate(to destination: UIViewController, from accessoryScreen: AccessoryScreen) {
        navigationController?.pushViewController(destination, animated: true)
    }
    
    // MARK: - Managing the user
    
    private dynamic func currentUserDidUpdate() {
        setUser(user: VCurrentUser.user, using: dependencyManager)
    }
    
    private func fetchUser(using dependencyManager: VDependencyManager) {
        if let userRemoteID = dependencyManager.templateValue(ofType: NSNumber.self, forKey: VDependencyManager.userRemoteIdKey) as? NSNumber {
            fetchUser(withRemoteID: userRemoteID.intValue)
        }
        else {
            setUser(user: VCurrentUser.user, using: dependencyManager)
        }
    }
    
    private func setUser(user: UserModel?, using dependencyManager: VDependencyManager) {
        guard let user = user else {
            assertionFailure("Failed to fetch user for profile view controller.")
            return
        }
        
        // If the user has not changed, we don't want to perform all the UI updates
        guard user != self.user else {
            return
        }
        
        setupGridStreamController(for: user)
        
        updateBarButtonItems()
        
        trackViewWillAppearIfNeeded()
    }
    
    private func setupGridStreamController(for user: UserModel?) {
        //Setup a new controller every time since the api path changes
        let header = VNewProfileHeaderView.new(with: dependencyManager)
        header.delegate = self
        let userID = VNewProfileViewController.getUserID(forDependencyManager: dependencyManager)
        
        let gridStreamController = GridStreamViewController(
            dependencyManager: dependencyManager,
            header: header,
            content: nil,
            streamAPIPath: dependencyManager.streamAPIPath(forUserID: userID)
        )
        self.gridStreamController = gridStreamController
        
        addChildViewController(gridStreamController)
        view.addSubview(gridStreamController.view)
        view.v_addFitToParentConstraints(toSubview: gridStreamController.view)
        gridStreamController.didMove(toParentViewController: self)
        
        gridStreamController.setContent(user, withError: false)
    }
    
    private static func getUserID(forDependencyManager dependencyManager: VDependencyManager) -> Int {
        if let userRemoteID = dependencyManager.templateValue(ofType: NSNumber.self, forKey: VDependencyManager.userRemoteIdKey) as? NSNumber {
            return userRemoteID.intValue
        }
        else {
            let user = VCurrentUser.user
            assert(user != nil, "User should not be nil")
            return user?.id ?? 0
        }
    }
    
    // MARK: - Tracking
    
    private var wantsToTrackViewWillAppear = false
    
    private func trackViewWillAppearIfNeeded() {
        if wantsToTrackViewWillAppear {
            trackViewWillAppearIfReady()
        }
    }
    
    private func trackViewWillAppearIfReady() {
        guard let context = profileScreenContext else {
            wantsToTrackViewWillAppear = true
            return
        }
        
        wantsToTrackViewWillAppear = false
        
        dependencyManager.trackViewWillAppear(for: self, parameters: [
            VTrackingKeyContext: context.trackingString as AnyObject
        ])
    }
    
    // MARK: - ConfigurableGridStreamContainer
    
    func shouldRefresh() {
        guard let userID = user?.id else {
            return
        }
        fetchUser(withRemoteID: userID, shouldShowSpinner: false)
    }
    
    private func fetchUser(withRemoteID remoteID: Int, shouldShowSpinner: Bool = true) {
        guard
            let apiPath = dependencyManager.networkResources?.userFetchAPIPath,
            let request = UserInfoRequest(apiPath: apiPath, userID: remoteID)
        else {
            return
        }
        
        if shouldShowSpinner {
            spinner.frame = CGRect(center: view.bounds.center, size: CGSize.zero)
            view.addSubview(spinner)
            spinner.startAnimating()
        }
        
        let operation = RequestOperation(request: request)
        operation.queue { [weak self] result in
            guard let dependencyManager = self?.dependencyManager else {
                return
            }
            
            self?.spinner.stopAnimating()
            self?.spinner.removeFromSuperview()
            
            switch result {
                case .success(let user):
                    self?.setUser(user: user, using: dependencyManager)
                case .failure(let error):
                    Log.warning("Failed to fetch user information with error: \(error)")
                case .cancelled:
                    break
            }
        }
    }
    
    // MARK: - Coachmark Displayer
    
    func highlightFrame(forIdentifier identifier: String) -> CGRect? {
        if let barFrame = navigationController?.navigationBar.frame, identifier == "bump" {
            return CGRect(
                x: barFrame.width - VNewProfileViewController.estimatedBarButtonWidth - VNewProfileViewController.estimatedNavBarRightPadding,
                y: VNewProfileViewController.estimatedStatusBarHeight,
                width: VNewProfileViewController.estimatedBarButtonWidth,
                height: barFrame.height
            )
        }
        return nil
    }
    
    // MARK: - VBackgroundContainer
    
    func backgroundContainerView() -> UIView {
        return view
    }
}

private extension VDependencyManager {
    var refreshControlColor: UIColor? {
        return color(forKey: VDependencyManagerMainTextColorKey)
    }
}

private extension VDependencyManager {
    func streamAPIPath(forUserID userID: Int) -> APIPath {
        guard var apiPath = apiPath(forKey: "streamURL") else {
            return APIPath(templatePath: "")
        }
        
        apiPath.queryParameters = [
            "user_id": "\(userID)"
        ]
        
        return apiPath
    }
}

private extension VDependencyManager {
    var userUpvoteAPIPath: APIPath {
        guard let apiPath = networkResources?.apiPath(forKey: "userUpvoteURL") else {
            assertionFailure("Failed to retrieve main feed API path from dependency manager.")
            return APIPath(templatePath: "")
        }
        return apiPath
    }
    
    var userUnupvoteAPIPath: APIPath {
        guard let apiPath = networkResources?.apiPath(forKey: "userUnupvoteURL") else {
            assertionFailure("Failed to retrieve main feed API path from dependency manager.")
            return APIPath(templatePath: "")
        }
        return apiPath
    }
    
    var userBlockAPIPath: APIPath {
        guard let apiPath = networkResources?.apiPath(forKey: "userBlockURL") else {
            assertionFailure("Failed to retrieve main feed API path from dependency manager.")
            return APIPath(templatePath: "")
        }
        return apiPath
    }
    
    var userUnblockAPIPath: APIPath {
        guard let apiPath = networkResources?.apiPath(forKey: "userUnblockURL") else {
            assertionFailure("Failed to retrieve main feed API path from dependency manager.")
            return APIPath(templatePath: "")
        }
        return apiPath
    }
    
    var upvoteIconTint: UIColor? {
        return color(forKey: "color.text.actionButton")
    }
    
    var upvoteIconSelectedBackgroundColor: UIColor? {
        return color(forKey: "color.background.upvote.selected")
    }
    
    var upvoteIconUnselectedBackgroundColor: UIColor? {
        return color(forKey: "color.background.upvote.unselected")
    }
    
    var upvoteIconSelected: UIImage? {
        return image(forKey: "upvote_icon_selected")?.withRenderingMode(.alwaysTemplate)
    }
    
    var upvoteIconUnselected: UIImage? {
        return image(forKey: "upvote_icon_unselected")?.withRenderingMode(.alwaysTemplate)
    }
    
    var overflowIcon: UIImage? {
        return image(forKey: "more_icon")
    }
    
    var shareIcon: UIImage? {
        return image(forKey: "share_icon")
    }
}
