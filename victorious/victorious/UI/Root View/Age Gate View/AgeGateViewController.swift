//
//  AgeGateViewController.swift
//  victorious
//
//  Created by Tian Lan on 12/3/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import UIKit

@objc protocol AgeGateViewControllerDelegate: class {
    func continueButtonTapped(isKid: Bool)
}

class AgeGateViewController: UIViewController {
    @IBOutlet private weak var backgroundView: UIView!
    @IBOutlet private weak var blurView: UIVisualEffectView!
    @IBOutlet private weak var dimmingView: UIView!
    @IBOutlet private weak var widgetBackground: UIView!
    @IBOutlet private weak var promptLabel: UILabel!
    @IBOutlet private weak var datePicker: UIDatePicker!
    @IBOutlet private weak var continueButton: UIButton!
    
    private weak var delegate: AgeGateViewControllerDelegate?
    
    private struct UIConstant {
        static let widgetBackgroundCornerRadius: CGFloat = 10.0
        static let blurViewCornerRadius: CGFloat = 17.0
        static let initialTransformScale: CGFloat = 1.2
    }
    
    private struct AnimationConstant {
        static let animationDuration: NSTimeInterval = 0.35
        static let springDamping: CGFloat = 1.0
    }
    
    static func ageGateViewController(withAgeGateDelegate delegate: AgeGateViewControllerDelegate) -> AgeGateViewController {
            let storyboard = UIStoryboard.v_mainStoryboard()
            guard let ageGateViewController = storyboard.instantiateViewControllerWithIdentifier(StringFromClass(AgeGateViewController)) as? AgeGateViewController else {
                fatalError("Could not instantiate an AgeGateViewController from Storyboard")
            }
            ageGateViewController.delegate = delegate
            
            return ageGateViewController
    }
    
    //MARK: - UI Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        blurView.layer.cornerRadius = UIConstant.blurViewCornerRadius
        blurView.layer.masksToBounds = true
        addBackgroundView()
        setupDisplayText()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        dimmingView.alpha = 0.0
        blurView.alpha = 0.0
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        self.blurView.transform = CGAffineTransformMakeScale(UIConstant.initialTransformScale, UIConstant.initialTransformScale)
        UIView.animateWithDuration(AnimationConstant.animationDuration,
            delay: 0.0,
            usingSpringWithDamping: AnimationConstant.springDamping,
            initialSpringVelocity: 0.0,
            options: [],
            animations: {
                self.dimmingView.alpha = 1.0
                self.blurView.alpha = 1.0
                self.blurView.transform = CGAffineTransformIdentity
            }, completion: nil)
    }
    
    @IBAction func tappedOnContinue(sender: UIButton) {
        let userIsKid = isKid(underAge: 13)
        delegate?.continueButtonTapped(userIsKid)
    }
    
    //MARK: - Private functions
    private func addBackgroundView() {
        let launchScreen = VLaunchScreenProvider.launchScreen()
        launchScreen.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.addSubview(launchScreen)
        backgroundView.v_addFitToParentConstraintsToSubview(launchScreen)
        
        widgetBackground.layer.cornerRadius = UIConstant.widgetBackgroundCornerRadius
    }
    
    private func setupDisplayText() {
        promptLabel.text = NSLocalizedString("Enter birthday before continuing", comment: "Age gate prompt telling user to select birthday")
        continueButton.setTitle(NSLocalizedString("Continue", comment: "Age gate Continue button title"),
            forState: .Normal)
    }
    
    private func isKid(underAge age: Int) -> Bool {
        let birthday = datePicker.date
        let now = NSDate()
        let ageComponents = NSCalendar.currentCalendar().components(.Year, fromDate: birthday, toDate: now, options: NSCalendarOptions())
        return ageComponents.year < 13
    }
}
