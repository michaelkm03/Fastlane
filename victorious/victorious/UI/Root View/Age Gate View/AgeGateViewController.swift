//
//  AgeGateViewController.swift
//  victorious
//
//  Created by Tian Lan on 12/3/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import UIKit

/// AgeGateViewController delegates should be able to handle next steps after user provide birthday
@objc protocol AgeGateViewControllerDelegate: class {
    func continueButtonTapped(isAnonymousUser: Bool)
}

/// Age gate view appears on splash screen when app first starts, if it is enabled in info.plist.
/// It is presented by Root View, and Root view(as this view's delegate)
/// will proceed to loading view after user taps `continue` button
class AgeGateViewController: UIViewController {
    @IBOutlet private weak var backgroundView: UIView!
    @IBOutlet private weak var blurView: UIVisualEffectView!
    @IBOutlet private weak var dimmingView: UIView!
    @IBOutlet private weak var widgetBackground: UIView!
    @IBOutlet private weak var promptLabel: UILabel!
    @IBOutlet private weak var datePicker: UIDatePicker! {
        didSet {
            datePicker.maximumDate = NSDate()
        }
    }
    @IBOutlet private weak var continueButton: UIButton! {
        didSet {
            continueButton.enabled = false
        }
    }
    @IBOutlet private var separatorHeightConstraints: [NSLayoutConstraint]!
    @IBOutlet weak var legalPromptLabel: UILabel!
    @IBOutlet weak var tosButton: UIButton!
    @IBOutlet weak var privacyButton: UIButton!
    
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
        let ageGateViewController = AgeGateViewController.v_fromStoryboard("Main") as AgeGateViewController
        ageGateViewController.delegate = delegate
            
        return ageGateViewController
    }
    
    //MARK: - View Controller Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupBackgroundViews()
        setupDisplayText()
        setupSeparators()
        setUpLegalInfoContainer()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        showDatePickerWithAnimation()
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    @IBAction private func tappedOnContinue(sender: UIButton) {
        let shouldBeAnonymous = AgeGate.isUserYoungerThan(13, forBirthday: datePicker.date)
        
        AgeGate.saveShouldUserBeAnonymous(shouldBeAnonymous)
        delegate?.continueButtonTapped(shouldBeAnonymous)
    }
    
    @IBAction private func selectedBirthday(sender: UIDatePicker) {
        continueButton.enabled = true
    }
    
    @IBAction private func tappedTermsOfService(sender: UIButton) {
        presentViewController(VTOSViewController.presentableTermsOfServiceViewController(), animated: true, completion: nil)
    }
    
    @IBAction private func tappedPrivacyPolicy(sender: UIButton) {
        presentViewController(VPrivacyPoliciesViewController.presentableTermsOfServiceViewControllerWithDependencyManager(nil), animated: true, completion: nil)
    }
    
    //MARK: - Private functions
    
    private func setupBackgroundViews() {
        let launchScreen = VLaunchScreenProvider.launchScreen()
        launchScreen.translatesAutoresizingMaskIntoConstraints = false
        backgroundView.addSubview(launchScreen)
        backgroundView.v_addFitToParentConstraintsToSubview(launchScreen)
        
        widgetBackground.layer.cornerRadius = UIConstant.widgetBackgroundCornerRadius
        
        blurView.transform = CGAffineTransformMakeScale(UIConstant.initialTransformScale, UIConstant.initialTransformScale)
        blurView.alpha = 0.0
        blurView.layer.cornerRadius = UIConstant.blurViewCornerRadius
        blurView.layer.masksToBounds = true
        
        dimmingView.alpha = 0.0
    }
    
    private func setupDisplayText() {
        promptLabel.text = NSLocalizedString("Enter birthday before continuing", comment: "Age gate prompt telling user to select birthday")
        continueButton.setTitle(NSLocalizedString("Continue", comment: "Age gate Continue button title"),
            forState: .Normal)
    }
    
    private func setupSeparators() {
        for separator in separatorHeightConstraints {
            separator.constant = 0.5
        }
    }
    
    private func setUpLegalInfoContainer() {
        let legalAttributesUnderline = [NSUnderlineStyleAttributeName: NSUnderlineStyle.StyleSingle.rawValue]
        
        let legalPrompt = NSLocalizedString("Legal Prompt on Age Gate", comment: "Legal prompt on age gate view")
        let tosText = NSAttributedString(string: NSLocalizedString("terms of service", comment: "") , attributes: legalAttributesUnderline)
        let ppText = NSAttributedString(string: NSLocalizedString("privacy policy", comment: ""), attributes: legalAttributesUnderline)
        
        legalPromptLabel.text = legalPrompt
        legalPromptLabel.textColor = UIColor.lightTextColor()
        tosButton.setAttributedTitle(tosText, forState: .Normal)
        privacyButton.setAttributedTitle(ppText, forState: .Normal)
        
        tosButton.accessibilityIdentifier = VAutomationIdentifierLRegistrationTOS
        privacyButton.accessibilityIdentifier = VAutomationIdentifierLRegistrationPrivacy
    }
    
    private func showDatePickerWithAnimation() {
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
}
