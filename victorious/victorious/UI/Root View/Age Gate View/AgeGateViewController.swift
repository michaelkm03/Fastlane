//
//  AgeGateViewController.swift
//  victorious
//
//  Created by Tian Lan on 12/3/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import UIKit

class AgeGateViewController: UIViewController {
    @IBOutlet private weak var backgroundView: UIView!
    @IBOutlet private weak var widgetBackground: UIView!
    @IBOutlet private weak var promptLabel: UILabel!
    @IBOutlet private weak var datePicker: UIDatePicker!
    @IBOutlet private weak var continueButton: UIButton!
    
    private var dependencyManager: VDependencyManager?
    
    private struct UIConstant {
        static let widgetBackgroundCornerRadius: CGFloat = 10.0
    }
    
    static func ageGateViewController(withDependencyManager dependencyManager: VDependencyManager) -> AgeGateViewController {
        let storyboard = UIStoryboard.v_mainStoryboard()
        guard let ageGateViewController = storyboard.instantiateViewControllerWithIdentifier(StringFromClass(AgeGateViewController)) as? AgeGateViewController else {
            fatalError("Could not instantiate an AgeGateViewController from Storyboard")
        }
        ageGateViewController.dependencyManager = dependencyManager
        return ageGateViewController
    }
    
    //MARK: - UI Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        addBackgroundView()
        setupDisplayText()
    }
    
    @IBAction func tappedOnContinue(sender: UIButton) {
        let loadingVC = VLoadingViewController.loadingViewControllerFromStoryboard()
        loadingVC.parentDependencyManager = dependencyManager
        presentViewController(loadingVC, animated: false, completion: nil)
    }
    
    //MARK: - Private helpers
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
}
