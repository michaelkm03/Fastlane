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
    @IBOutlet private weak var containerView: UIView!
    
    private var dependencyManager: VDependencyManager!
    
    private struct Constants {
        static let cornerRadius: CGFloat = 10
    }
    
    // MARK: - Initialization
    
    class func newWithDependencyManager(dependencyManager: VDependencyManager) -> ImageAlertViewController {
        let imageAlertViewController = ImageAlertViewController.v_initialViewControllerFromStoryboard() as ImageAlertViewController
        imageAlertViewController.dependencyManager = dependencyManager
        
        return imageAlertViewController
    }
    
    // MARK: - View Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        styleComponents()
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        return .Portrait
    }
    
    @IBAction func dismiss(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - Private Methods
    
    private func styleComponents() {
        containerView.layer.cornerRadius = Constants.cornerRadius
        
        titleLabel.font = dependencyManager.titleFont
//        titleLabel.textColor = dependencyManager.textColor
        
        detailLabel.font = dependencyManager.detailLabelFont
//        detailLabel.textColor = dependencyManager.textColor
        
        confirmButton.layer.cornerRadius = Constants.cornerRadius
        confirmButton.titleLabel?.font = dependencyManager.confirmButtonTitleFont
        confirmButton.setTitleColor(dependencyManager.confirmButtonTitleColor, forState: .Normal)
        confirmButton.setTitleColor(dependencyManager.confirmButtonTitleColor?.colorWithAlphaComponent(0.5), forState: .Highlighted)
        confirmButton.backgroundColor = dependencyManager.confirmButtonBackgroundColor
        confirmButton.setTitle(dependencyManager.confirmButtonTitle, forState: .Normal)
    }
}

private extension VDependencyManager {
    var confirmButtonBackgroundColor: UIColor? {
        return self.colorForKey(VDependencyManagerLinkColorKey)
    }
    
    var confirmButtonTitleFont: UIFont? {
        return self.fontForKey(VDependencyManagerHeading4FontKey)
    }
    
    var confirmButtonTitleColor: UIColor? {
        return self.colorForKey(VDependencyManagerContentTextColorKey)
    }
    
    var titleFont: UIFont? {
        return self.fontForKey(VDependencyManagerHeading3FontKey)
    }
    
    var detailLabelFont: UIFont? {
        return self.fontForKey(VDependencyManagerParagraphFontKey)
    }
    
    var textColor: UIColor? {
        return self.colorForKey(VDependencyManagerMainTextColorKey)
    }
    
    var confirmButtonTitle: String {
        return self.stringForKey("button.title") ?? NSLocalizedString("Dismiss Alert", comment: "")
    }
}
