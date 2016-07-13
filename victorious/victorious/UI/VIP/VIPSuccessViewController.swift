//
//  VIPSuccessViewController.swift
//  victorious
//
//  Created by Sharif Ahmed on 5/24/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

protocol VIPSuccessViewControllerDelegate: class {
    func successViewControllerFinished(successViewController: VIPSuccessViewController)
}

class VIPSuccessViewController: UIViewController {
    @IBOutlet weak var successImageView: UIImageView!
    @IBOutlet weak var headlineTextView: UITextView!
    @IBOutlet weak var detailTextView: UITextView!
    @IBOutlet weak var confirmButton: UIButton!
    
    @IBOutlet var successImageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var headlineTextViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var detailTextViewHeightConstraint: NSLayoutConstraint!
    
    weak var delegate: VIPSuccessViewControllerDelegate?
    
    private var dependencyManager: VDependencyManager! {
        didSet {
            updateSubviewContents()
        }
    }
    
    static func newWithDependencyManager(dependencyManager: VDependencyManager) -> VIPSuccessViewController {
        
        let successViewController: VIPSuccessViewController = v_initialViewControllerFromStoryboard()
        successViewController.dependencyManager = dependencyManager
        return successViewController
    }
    
    // MARK: - UIViewController lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateSubviewContents()
    }
    
    override func updateViewConstraints() {
        
        super.updateViewConstraints()
        headlineTextViewHeightConstraint.constant = headlineTextView.contentSize.height
        detailTextViewHeightConstraint.constant = detailTextView.contentSize.height
        var imageViewHeight: CGFloat = 0
        if let imageHeight = successImageView.image?.size.height {
            imageViewHeight = imageHeight
        }
        successImageViewHeightConstraint.constant = imageViewHeight
    }
    
    // MARK: - Subview population
    
    private func updateSubviewContents() {
        guard isViewLoaded() else {
            return
        }
        
        var headlineText = NSAttributedString()
        if let text = dependencyManager.headlineText,
            let attributes = dependencyManager.headlineTextAttributes {
            headlineText = NSAttributedString(string: text, attributes: attributes)
        }
        headlineTextView.attributedText = headlineText
        
        var detailText = NSAttributedString()
        if let text = dependencyManager.detailText,
            let attributes = dependencyManager.detailTextAttributes {
            detailText = NSAttributedString(string: text, attributes: attributes)
        }
        detailTextView.attributedText = detailText
        
        successImageView.image = dependencyManager.successIcon
        if let tintColor = dependencyManager.successIconTintColor {
            successImageView.tintColor = tintColor
        }
        
        confirmButton.backgroundColor = dependencyManager.confirmButonBackgroundColor
        if let attributedConfirmText = dependencyManager.confirmButtonAttributedText {
            confirmButton.setAttributedTitle(attributedConfirmText, forState: .Normal)
        }
        
        view.setNeedsUpdateConstraints()
    }
    
    // MARK: - Actions
    
    @IBAction private func onConfirm() {
        delegate?.successViewControllerFinished(self)
    }
}

private extension VDependencyManager {
    
    var successIcon: UIImage? {
        return imageForKey("successIcon")
    }
    
    var successIconTintColor: UIColor? {
        return colorForKey("color.successIcon")
    }
    
    var headlineText: String? {
        return stringForKey("text.successMessage")
    }
    
    var headlineTextAttributes: [String : AnyObject]? {
        
        guard let font = fontForKey("font.successMessage"),
            let color = colorForKey("color.successMessage") else {
                return nil
        }
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .Center
        return [
            NSFontAttributeName: font,
            NSForegroundColorAttributeName: color,
            NSParagraphStyleAttributeName: paragraphStyle
        ]
    }
    
    var detailText: String? {
        return stringForKey("text.successDetails")
    }
    
    var detailTextAttributes: [String : AnyObject]? {
        
        guard let font = fontForKey("font.successDetails"),
            let color = colorForKey("color.successDetails") else {
                return nil
        }
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .Center
        return [
            NSFontAttributeName: font,
            NSForegroundColorAttributeName: color,
            NSParagraphStyleAttributeName: paragraphStyle
        ]
    }
    
    var confirmButtonAttributedText: NSAttributedString? {
        guard
            let font = fontForKey("font.proceedMessage"),
            let color = colorForKey("color.proceedMessage"),
            let text = stringForKey("text.proceedMessage")
        else {
                return nil
        }

        let attributes = [
            NSFontAttributeName: font,
            NSForegroundColorAttributeName: color
        ]
        
        return NSAttributedString(string: text, attributes: attributes)
    }
    
    var confirmButonBackgroundColor: UIColor? {
        return colorForKey("color.proceedButton")
    }
}
