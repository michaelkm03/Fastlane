//
//  ImageAlertViewController.swift
//  victorious
//
//  Created by Tian Lan on 3/28/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

class ImageAlertViewController: UIViewController {
    
    @IBOutlet private weak var iconImageView: UIImageView?
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var detailLabel: UILabel!
    @IBOutlet private weak var confirmButton: UIButton!
    @IBOutlet private weak var semiTransparentBackgroundButton: UIButton!
    
    private var dependencyManager: VDependencyManager!
    
    //MARK: - Initialization
    
    class func newWithDependencyManager(dependencyManager: VDependencyManager) -> ImageAlertViewController {
        let imageAlertViewController = ImageAlertViewController.v_initialViewControllerFromStoryboard() as ImageAlertViewController
        imageAlertViewController.dependencyManager = dependencyManager
        
        return imageAlertViewController
    }
    
    //MARK: - View Controller Life Cycle
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return .Portrait
    }
    
    @IBAction func dismiss(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

private extension VDependencyManager {
    
}
