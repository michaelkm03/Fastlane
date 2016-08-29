//
//  LevelUpViewController.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 9/4/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation
import VictoriousIOSSDK

private struct Constants {
    static let distanceToContainerFromSide: CGFloat = 50
    static let collectionViewHeight: CGFloat = 80
    static let badgeHeight = 159 // This needs to be slightly higher than in the mocks to accomodate for rounded corners
    static let badgeWidth = 135
}

class LevelUpViewController: UIViewController, Interstitial, VVideoPlayerDelegate {
    
    struct AnimationConstants {
        static let presentationDuration = 0.4
        static let dismissalDuration = 0.2
        static let progressAnimation = 2.0
    }
    
    @IBOutlet weak var dismissButton: UIButton! {
        didSet {
            if let dismissButton = dismissButton {
                dismissButton.backgroundColor = dependencyManager.dismissButtonColor
                dismissButton.setTitleColor(dependencyManager.dismissButtonTitleColor, forState: .Normal)
                dismissButton.titleLabel?.font = dependencyManager.dismissButtonTitleFont
                dismissButton.setTitle(dependencyManager.dismissButtonTitle, forState: .Normal)
            }
        }
    }
    
    private let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .Light))
    private let contentContainer = UIView()
    private var badgeView: AnimatedBadgeView?
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let videoBackground = VVideoView()
    private lazy var collectionViewHeightConstraint: NSLayoutConstraint = {
       let collectionViewHeightConstraint = NSLayoutConstraint(item: self.iconCollectionView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 1, constant: Constants.collectionViewHeight)
        return collectionViewHeightConstraint
    }()
    
    private var displayLink: CADisplayLink!
    private var firstTimeStamp: NSTimeInterval?
    private var hasAppeared = false
    private var videoURL: NSURL?
    
    private var icons: [NSURL]? {
        didSet {
            // Reload icon collection view
            iconCollectionView.reloadData()
            
            // Update constraints on collection view
            collectionViewHeightConstraint.constant = showCollectionView() ? Constants.collectionViewHeight : 0
        }
    }
    
    private lazy var iconCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .Horizontal
        let collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: layout)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.clearColor()
        collectionView.registerClass(LevelUpIconCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        return collectionView
        }()
    
    // MARK: Interstitial View Controller
    
    weak var interstitialDelegate: InterstitialDelegate?
    
    func presentationAnimator() -> UIViewControllerAnimatedTransitioning? {
        return LevelUpAnimator()
    }
    
    func dismissalAnimator() -> UIViewControllerAnimatedTransitioning? {
        let levelUpAnimator = LevelUpAnimator()
        levelUpAnimator.isDismissal = true
        return levelUpAnimator
    }
    
    func presentationController(presentedViewController: UIViewController, presentingViewController: UIViewController) -> UIPresentationController {
        return UIPresentationController(presentedViewController: presentedViewController, presentingViewController: presentingViewController)
    }
    
    func preferredModalPresentationStyle() -> UIModalPresentationStyle {
        return .FullScreen
    }
    
    // MARK: - Public Properties
    
    var alert: Alert? {
        didSet {
            guard let alert = alert,
                let fanLoyalty = alert.parameters.userFanLoyalty else {
                    return
            }
            badgeView?.levelNumberString = String(fanLoyalty.level)
            titleLabel.text = alert.parameters.title
            descriptionLabel.text = alert.parameters.description
            icons = alert.parameters.icons
        }
    }
    
    var dependencyManager: VDependencyManager! {
        didSet {
            if let dependencyManager = dependencyManager {
                titleLabel.font = dependencyManager.titleFont
                titleLabel.textColor = dependencyManager.textColor
                descriptionLabel.font = dependencyManager.descriptionFont
                descriptionLabel.textColor = dependencyManager.textColor
                badgeView = dependencyManager.animatedBadgeView
            }
        }
    }
    
    /// MARK: Factory method
    
    class func newWithDependencyManager(dependencyManager: VDependencyManager) -> LevelUpViewController {
        let levelUpViewController: LevelUpViewController = self.v_initialViewControllerFromStoryboard()
        levelUpViewController.dependencyManager = dependencyManager
        return levelUpViewController
    }
    
    // MARK: UIViewController
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return .Portrait
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.blackColor()
        
        videoBackground.delegate = self
        view.addSubview(videoBackground)
        view.sendSubviewToBack(videoBackground)
        
        layoutContent()
        
        dismissButton.layer.cornerRadius = 4
        dismissButton.layer.masksToBounds = true
        
        titleLabel.textAlignment = NSTextAlignment.Center
        
        descriptionLabel.numberOfLines = 0;
        descriptionLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        descriptionLabel.textAlignment = NSTextAlignment.Center
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if !hasAppeared {
            setToInitialState()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        guard let alert = alert,
            let fanLoyalty = alert.parameters.userFanLoyalty where !hasAppeared else {
                return
        }
        
        animateIn()
        
        if let videoURL = alert.parameters.backgroundVideoURL {
            let videoPlayerItem = VVideoPlayerItem(URL: videoURL)
            videoPlayerItem.loop = false
            videoPlayerItem.muted = true
            self.videoBackground.setItem( videoPlayerItem )
        }

        // FIXME: We shouldn't need this anymore. Confirm
//        // Assuming this level up alert contains the most up-to-date fanloyalty info,
//        // we update the user's level and level progress when the interstitial appears
//        if let currentUser = VCurrentUser.user {
//            currentUser.level = fanLoyalty.level
//            currentUser.levelProgressPercentage = fanLoyalty.progress
//        }
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    /// MARK: Actions
    
    @IBAction func pressedDismiss(sender: AnyObject) {
        self.interstitialDelegate?.dismissInterstitial(self)
    }
    
    /// MARK: Helpers
    
    private func animateIn() {
        
        // Title animation
        UIView.animateWithDuration(0.6,
            delay: 0.1,
            usingSpringWithDamping: 0.8,
            initialSpringVelocity: 0.4,
            options: .CurveEaseIn,
            animations: {
                self.titleLabel.transform = CGAffineTransformIdentity
                self.descriptionLabel.transform = CGAffineTransformIdentity
                self.iconCollectionView.transform = CGAffineTransformIdentity
            },
            completion: nil)
        
        // Badge animation
        UIView.animateWithDuration(0.5,
            delay: 0,
            usingSpringWithDamping: 0.5,
            initialSpringVelocity: 0.4,
            options: .CurveEaseIn,
            animations: {
                self.badgeView?.transform = CGAffineTransformIdentity
            },
            completion: nil)
        
        // Button animation
        UIView.animateWithDuration(0.6,
            delay: 0.2,
            options: .CurveEaseIn,
            animations: {
                self.dismissButton.alpha = 1
            },
            completion: nil)
    }
    
    private func setToInitialState() {
        badgeView?.transform = CGAffineTransformMakeScale(0, 0)
        titleLabel.transform = CGAffineTransformMakeTranslation(0, self.view.bounds.height - titleLabel.bounds.origin.y)
        descriptionLabel.transform = CGAffineTransformMakeTranslation(0, self.view.bounds.height - titleLabel.bounds.origin.y)
        iconCollectionView.transform = CGAffineTransformMakeTranslation(0, self.view.bounds.height - titleLabel.bounds.origin.y)
        dismissButton.alpha = 0
    }
    
    /// MARK: Video View Delegate
    
    func videoPlayerDidBecomeReady(videoPlayer: VVideoPlayer) {
        videoPlayer.playFromStart()
    }
    
    func videoPlayer(videoPlayer: VVideoPlayer, didPlayToTime time: Float64) {
        let fadeOutTime = 1.0
        let timeLeft = videoPlayer.durationSeconds - videoPlayer.currentTimeSeconds
        // Add a small 0.1s of padding in case we receive this callback late
        if timeLeft <= fadeOutTime + 0.1 {
            UIView.animateWithDuration(fadeOutTime) {
                self.videoBackground.alpha = 0
            }
        }
    }
}

extension LevelUpViewController: UICollectionViewDelegateFlowLayout {
    
    private func showCollectionView() -> Bool {
        if let icons = icons {
            return icons.count > 0
        }
        return false
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return showCollectionView() ? CGSize(width: collectionView.bounds.height, height: collectionView.bounds.height) : CGSizeZero
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, view.bounds.width / 2 - Constants.distanceToContainerFromSide - collectionView.bounds.height / 2, 0, 10)
    }
}

extension LevelUpViewController: UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let icons = icons {
            return icons.count
        }
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as? LevelUpIconCollectionViewCell {
            if let url =  icons?[indexPath.row] {
                cell.iconURL = url
            }
            return cell
        }
        return UICollectionViewCell()
    }
}

// Extension for handling constraints
extension LevelUpViewController {
    
    private func layoutContent() {
        
        view.v_addFitToParentConstraintsToSubview(videoBackground)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        contentContainer.addSubview(titleLabel)
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        contentContainer.addSubview(descriptionLabel)
        iconCollectionView.translatesAutoresizingMaskIntoConstraints = false
        contentContainer.addSubview(iconCollectionView)
        
        var views: [String : UIView]
        var verticalVisualString = ""
        var metrics = [String: AnyObject]()
        
        if let badgeView = badgeView {
            verticalVisualString = "V:|[badgeView(bHeight)]-55-[titleLabel]-5-[descriptionLabel]-30-[iconCollectionView]|"
            views = ["badgeView": badgeView, "titleLabel": titleLabel, "descriptionLabel": descriptionLabel, "iconCollectionView": iconCollectionView]
            metrics = ["bHeight": Constants.badgeHeight]
            badgeView.translatesAutoresizingMaskIntoConstraints = false
            
            // Add badge specific constraints
            contentContainer.addSubview(badgeView)
            badgeView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("[badgeView(bWidth)]", options: [], metrics: ["bWidth": Constants.badgeWidth], views: views))
                   contentContainer.addConstraint(NSLayoutConstraint(item: contentContainer, attribute: .CenterX, relatedBy: .Equal, toItem: badgeView, attribute: .CenterX, multiplier: 1, constant: 0))
        } else {
            verticalVisualString = "V:|[titleLabel]-5-[descriptionLabel]-30-[iconCollectionView]|"
            views = ["titleLabel": titleLabel, "descriptionLabel": descriptionLabel, "iconCollectionView": iconCollectionView]
        }
        
        let verticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat(verticalVisualString, options: [], metrics: metrics, views: views)
        contentContainer.addConstraints(verticalConstraints)
        
        iconCollectionView.addConstraint(collectionViewHeightConstraint)
        
        contentContainer.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[titleLabel]|", options: [], metrics: nil, views: views))
        contentContainer.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[descriptionLabel]|", options: [], metrics: nil, views: views))
        contentContainer.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[iconCollectionView]|", options: [], metrics: nil, views: views))
        
        contentContainer.translatesAutoresizingMaskIntoConstraints = false
        self.view.addSubview(contentContainer)
        self.view.addConstraint(NSLayoutConstraint(item: self.view, attribute: .CenterY, relatedBy: .Equal, toItem: contentContainer, attribute: .CenterY, multiplier: 1, constant: 0))
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-distance-[contentContainer]-distance-|", options: [], metrics: ["distance": Constants.distanceToContainerFromSide], views: ["contentContainer": contentContainer]))
    }
}

private extension VDependencyManager {
    var dismissButtonColor: UIColor {
        return self.colorForKey(VDependencyManagerLinkColorKey)
    }
    
    var dismissButtonTitleFont: UIFont {
        return self.fontForKey(VDependencyManagerHeading3FontKey)
    }
    
    var dismissButtonTitleColor: UIColor {
        return self.colorForKey(VDependencyManagerContentTextColorKey)
    }
    
    var titleFont: UIFont {
        return self.fontForKey(VDependencyManagerLabel1FontKey)
    }
    
    var descriptionFont: UIFont {
        return self.fontForKey(VDependencyManagerLabel2FontKey)
    }
    
    var textColor: UIColor {
        return self.colorForKey(VDependencyManagerMainTextColorKey)
    }
    
    var badgeColor: UIColor {
        return self.colorForKey(VDependencyManagerAccentColorKey)
    }
    
    var badgeTextColor: UIColor {
        return self.colorForKey(VDependencyManagerSecondaryTextColorKey)
    }
    
    var dismissButtonTitle: String {
        return self.stringForKey("button.title")
    }
    
    var animatedBadgeView: AnimatedBadgeView? {
        guard let badgeView = self.templateValueOfType(AnimatedBadgeView.self, forKey: "animatedBadge") as? AnimatedBadgeView else {
            return nil
        }
        
        badgeView.levelStringLabel.font = UIFont(name: "OpenSans-Bold", size: 15)
        badgeView.levelNumberLabel.font = UIFont(name: "OpenSans-Bold", size: 60)
        badgeView.animatedBorderWidth = 5
        badgeView.progressBarInset = 4
        return badgeView
    }
}
