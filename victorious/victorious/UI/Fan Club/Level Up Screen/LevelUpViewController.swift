//
//  LevelUpViewController.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 9/4/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import Foundation

private struct Constants {
    static let distanceToContainerFromSide: CGFloat = 50
    static let collectionViewHeight = 80
    static let badgeHeight = 150
    static let badgeWidth = 135
}

class LevelUpViewController: UIViewController, InterstitialViewController {
    
    let model = LevelUpModel()
    
    @IBOutlet weak var dismissButton: UIButton!
    
    private let blurEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .Light))
    private let contentContainer = UIView()
    private let badgeView = LevelBadgeView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private var displayLink: CADisplayLink!
    private var firstTimeStamp: NSTimeInterval?
    private var hasAppeared = false
    
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
    
    weak var interstitialDelegate: InterstitialViewControllerControl?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(blurEffectView)
        view.sendSubviewToBack(blurEffectView)
        
        displayLink = CADisplayLink(target: self, selector: "update:")
        displayLink.addToRunLoop(NSRunLoop.mainRunLoop(), forMode: NSDefaultRunLoopMode)
        
        titleLabel.text = model.title
        titleLabel.font = UIFont.boldSystemFontOfSize(30)
        descriptionLabel.text = model.prizeDescription
        badgeView.levelNumber = model.level
        badgeView.color = model.badgeColor
        badgeView.title = "LEVEL"
        
        layoutContent()
        
        dismissButton.backgroundColor = UIColor(red: 80/255, green: 0, blue: 103/255, alpha: 1)
        dismissButton.layer.cornerRadius = 4
        dismissButton.layer.masksToBounds = true
        dismissButton.setTitleColor(UIColor.whiteColor(), forState: UIControlState.Normal)
        
        titleLabel.textAlignment = NSTextAlignment.Center
        titleLabel.textColor = UIColor.whiteColor()
        
        descriptionLabel.numberOfLines = 0;
        descriptionLabel.lineBreakMode = NSLineBreakMode.ByWordWrapping
        descriptionLabel.textAlignment = NSTextAlignment.Center
        descriptionLabel.textColor = UIColor.whiteColor()
    }
    
    func update(displayLink: CADisplayLink) {
        // Potential animation
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        if !hasAppeared {
            setToInitialState()
        }
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        if !hasAppeared {
            animateIn()
        }
    }
    
    /// MARK: Actions
    
    @IBAction func pressedDismiss(sender: AnyObject) {
        self.interstitialDelegate?.dismissInterstitial()
    }
    
    /// MARK: Helpers
    
    private func animateIn() {
        
        // Title animation
        UIView.animateWithDuration(1, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.4, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
            self.titleLabel.transform = CGAffineTransformIdentity
            self.descriptionLabel.transform = CGAffineTransformIdentity
            self.iconCollectionView.transform = CGAffineTransformIdentity
            }, completion: nil)
        
        // Badge animation
        UIView.animateWithDuration(0.5, delay: 0.6, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.4, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
            self.badgeView.transform = CGAffineTransformIdentity
            }, completion: nil)
        
        // Button animation
        UIView.animateWithDuration(0.6, delay: 1.0, options: UIViewAnimationOptions.CurveEaseIn, animations: { () -> Void in
            self.dismissButton.alpha = 1
            }, completion: nil)
    }
    
    private func setToInitialState() {
        badgeView.transform = CGAffineTransformMakeScale(0, 0)
        titleLabel.transform = CGAffineTransformMakeTranslation(0, self.view.bounds.height - titleLabel.bounds.origin.y)
        descriptionLabel.transform = CGAffineTransformMakeTranslation(0, self.view.bounds.height - titleLabel.bounds.origin.y)
        iconCollectionView.transform = CGAffineTransformMakeTranslation(0, self.view.bounds.height - titleLabel.bounds.origin.y)
        dismissButton.alpha = 0
    }
}

extension LevelUpViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.height, height: collectionView.bounds.height)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, view.bounds.width / 2 - Constants.distanceToContainerFromSide - collectionView.bounds.height / 2, 0, 10)
    }
}

extension LevelUpViewController: UICollectionViewDataSource {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if let let cell = collectionView.dequeueReusableCellWithReuseIdentifier("cell", forIndexPath: indexPath) as? LevelUpIconCollectionViewCell {
            return cell
        }
        return UICollectionViewCell()
    }
}

// Extension for handling constraints
extension LevelUpViewController {
    
    private func layoutContent() {
        
        view.v_addFitToParentConstraintsToSubview(blurEffectView)
        
        badgeView.setTranslatesAutoresizingMaskIntoConstraints(false)
        contentContainer.addSubview(badgeView)
        titleLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        contentContainer.addSubview(titleLabel)
        descriptionLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
        contentContainer.addSubview(descriptionLabel)
        iconCollectionView.setTranslatesAutoresizingMaskIntoConstraints(false)
        contentContainer.addSubview(iconCollectionView)
        
        let verticalVisualString = "V:|[badgeView(bHeight)]-55-[titleLabel]-5-[descriptionLabel]-30-[iconCollectionView(==cHeight)]|"
        let views = ["badgeView" : badgeView, "titleLabel" : titleLabel, "descriptionLabel" : descriptionLabel, "iconCollectionView" : iconCollectionView]
        let verticalConstraints = NSLayoutConstraint.constraintsWithVisualFormat(verticalVisualString, options: nil, metrics: ["cHeight" : Constants.collectionViewHeight, "bHeight" : Constants.badgeHeight], views: views)
        contentContainer.addConstraints(verticalConstraints)
        
        contentContainer.addConstraint(NSLayoutConstraint(item: contentContainer, attribute: .CenterX, relatedBy: .Equal, toItem: badgeView, attribute: .CenterX, multiplier: 1, constant: 0))
        badgeView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("[badgeView(bWidth)]", options: nil, metrics: ["bWidth" : Constants.badgeWidth], views: views))
        contentContainer.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[titleLabel]|", options: nil, metrics: nil, views: views))
        contentContainer.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[descriptionLabel]|", options: nil, metrics: nil, views: views))
        contentContainer.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|[iconCollectionView]|", options: nil, metrics: nil, views: views))
        
        contentContainer.setTranslatesAutoresizingMaskIntoConstraints(false)
        self.view.addSubview(contentContainer)
        self.view.addConstraint(NSLayoutConstraint(item: self.view, attribute: .CenterY, relatedBy: .Equal, toItem: contentContainer, attribute: .CenterY, multiplier: 1, constant: 0))
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("|-distance-[contentContainer]-distance-|", options: nil, metrics: ["distance" : Constants.distanceToContainerFromSide], views: ["contentContainer" : contentContainer]))
    }
}
