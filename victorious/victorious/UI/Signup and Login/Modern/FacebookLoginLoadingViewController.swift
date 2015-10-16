//
//  FacebookLoginLoadingViewController.swift
//  victorious
//
//  Created by Cody Kolodziejzyk on 10/15/15.
//  Copyright © 2015 Victorious. All rights reserved.
//

import UIKit
import Foundation

class FacebookLoginLoadingViewController: UIViewController, VLoginFlowScreen, VBackgroundContainer {
    
    @IBOutlet weak var loadingLabel: UILabel!
    
    var cancelButton: UIBarButtonItem?
    
    var delegate: VLoginFlowControllerDelegate?
    
    class func newWithDependencyManager(dependencyManager: VDependencyManager) -> FacebookLoginLoadingViewController {
        let facebookLoginLoadingViewController: FacebookLoginLoadingViewController = self.v_initialViewControllerFromStoryboard()
        facebookLoginLoadingViewController.dependencyManager = dependencyManager
        return facebookLoginLoadingViewController
    }
    
    /// MARK: Factory method
    
    var dependencyManager: VDependencyManager! {
        didSet {
            if let dependencyManager = dependencyManager {
                cancelButton = UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: "pressedCancel")
                navigationItem.leftBarButtonItem = cancelButton
                dependencyManager.addBackgroundToBackgroundHost(self)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    /// MARK: Actions
    
    func pressedCancel() {
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    /// MARK: Background
    
    func backgroundContainerView() -> UIView {
        return view
    }
    
}