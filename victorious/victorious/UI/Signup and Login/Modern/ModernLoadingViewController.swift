//
//  ModernLoadingViewController.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 10/15/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import UIKit
import Foundation

class ModernLoadingViewController: UIViewController, LoginFlowLoadingScreen, VBackgroundContainer {
    
    @IBOutlet weak var loadingLabel: UILabel! {
        didSet {
            guard let loadingLabel = loadingLabel else {
                return
            }
            
            loadingLabel.text = dependencyManager.prompt
            loadingLabel.font = dependencyManager.promptFont
            loadingLabel.textColor = dependencyManager.textColor
        }
    }
    
    @IBOutlet weak var ellipsesLabel: UILabel! {
        didSet {
            guard let ellipsesLabel = ellipsesLabel else {
                return
            }
            
            ellipsesLabel.font = dependencyManager.promptFont
            ellipsesLabel.textColor = dependencyManager.textColor
        }
    }
    
    fileprivate var cancelButton: UIBarButtonItem?
    fileprivate var timerManager: VTimerManager?
    
    // MARK : Public properties
    
    weak var delegate: VLoginFlowControllerDelegate?
    
    var dependencyManager: VDependencyManager! {
        didSet {
            if let dependencyManager = dependencyManager {
                cancelButton = UIBarButtonItem(title: dependencyManager.buttonTitle, style: .plain, target: self, action: #selector(pressedCancel))
                navigationItem.leftBarButtonItem = cancelButton
                dependencyManager.addBackground(toBackgroundHost: self)
            }
        }
    }
    
    var canCancel = true {
        didSet {
            self.cancelButton?.isEnabled = canCancel
        }
    }
    
    // MARK: Login Flow Loading Screen
    
    weak var loadingScreenDelegate: LoginLoadingScreenDelegate?
        
    // MARK: Factory method
    
    class func new(with dependencyManager: VDependencyManager) -> ModernLoadingViewController {
        let facebookLoginLoadingViewController: ModernLoadingViewController = self.v_initialViewControllerFromStoryboard()
        facebookLoginLoadingViewController.dependencyManager = dependencyManager
        return facebookLoginLoadingViewController
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        timerManager?.invalidate()
        timerManager = VTimerManager.scheduledTimerManager(withTimeInterval: 0.3, target: self, selector: #selector(animate), userInfo: nil, repeats: true)
        if let loadingScreenDelegate = loadingScreenDelegate {
            loadingScreenDelegate.loadingScreenDidAppear()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        ellipsesLabel.text = ""
    }
    
    // MARK: Actions
    
    func pressedCancel() {
        loadingScreenDelegate?.loadingScreenCancelled()
    }
    
    func animate() {
        let ellipses = "..."
        if let range = ellipsesLabel.text?.range(of: ellipses) {
            ellipsesLabel.text = ellipsesLabel.text?.replacingCharacters(in: range, with: "")
        }
        else {
            ellipsesLabel.text = (ellipsesLabel.text ?? "") + "."
        }
    }
    
    // MARK: Background
    
    func backgroundContainerView() -> UIView {
        return view
    }
}

private extension VDependencyManager {
    var prompt: String? {
        return self.string(forKey: "prompt")
    }
    
    var buttonTitle: String? {
        return self.string(forKey: "button.title")
    }
    
    var textColor: UIColor? {
        return self.color(forKey: VDependencyManagerMainTextColorKey)
    }
    
    var promptFont: UIFont? {
        return self.font(forKey: VDependencyManagerHeading1FontKey)
    }
}
