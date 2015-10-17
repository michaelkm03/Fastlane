//
//  ModernLoadingViewController.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 10/15/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import UIKit
import Foundation

class ModernLoadingViewController: UIViewController, VLoginFlowScreen, VBackgroundContainer {
    
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
    
    private var cancelButton: UIBarButtonItem?
    private var ellipsesTimer: NSTimer?
    
    /// MARK : Public properties
    
    var delegate: VLoginFlowControllerDelegate?
    
    var dependencyManager: VDependencyManager! {
        didSet {
            if let dependencyManager = dependencyManager {
                cancelButton = UIBarButtonItem(title: dependencyManager.buttonTitle, style: .Plain, target: self, action: "pressedCancel")
                navigationItem.leftBarButtonItem = cancelButton
                dependencyManager.addBackgroundToBackgroundHost(self)
            }
        }
    }
    
    /// A block that gets called when the loading screen finishes appearing
    var onAppearance: (() -> ())?
    
    /// MARK: Factory method
    
    class func newWithDependencyManager(dependencyManager: VDependencyManager) -> ModernLoadingViewController {
        let facebookLoginLoadingViewController: ModernLoadingViewController = self.v_initialViewControllerFromStoryboard()
        facebookLoginLoadingViewController.dependencyManager = dependencyManager
        return facebookLoginLoadingViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        ellipsesTimer = NSTimer.scheduledTimerWithTimeInterval(0.3, target: self, selector: "animate", userInfo: nil, repeats: true)
        ellipsesTimer?.fire()
        if let onAppearance = onAppearance {
            onAppearance()
            self.onAppearance = nil
        }
    }
    
    override func viewDidDisappear(animated: Bool) {
        ellipsesTimer?.invalidate()
        ellipsesTimer = nil
        ellipsesLabel.text = ""
    }
    
    /// MARK: Actions
    
    func pressedCancel() {
        delegate?.loadingScreenCanceled()
    }
    
    func animate() {
        let ellipses = "..."
        if let range = ellipsesLabel.text?.rangeOfString(ellipses) {
            ellipsesLabel.text = ellipsesLabel.text?.stringByReplacingCharactersInRange(range, withString: "")
        }
        else {
            ellipsesLabel.text = ellipsesLabel.text?.stringByAppendingString(".")
        }
    }
    
    /// MARK: Background
    
    func backgroundContainerView() -> UIView {
        return view
    }
    
}

private extension VDependencyManager {
    var prompt: String {
        return self.stringForKey("prompt")
    }
    
    var buttonTitle: String {
        return self.stringForKey("button.title")
    }
    
    var textColor: UIColor {
        return self.colorForKey(VDependencyManagerMainTextColorKey)
    }
    
    var promptFont: UIFont {
        return self.fontForKey(VDependencyManagerHeading1FontKey)
    }
}
