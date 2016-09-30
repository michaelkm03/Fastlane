//
//  VIPSuccessViewController.swift
//  victorious
//
//  Created by Sharif Ahmed on 5/24/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import UIKit

protocol VIPSuccessViewControllerDelegate: class {
    func successViewControllerFinished(_ successViewController: VIPSuccessViewController)
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
    
    fileprivate var dependencyManager: VDependencyManager! {
        didSet {
            updateSubviewContents()
        }
    }
    
    static func new(withDependencyManager dependencyManager: VDependencyManager) -> VIPSuccessViewController {
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
        successImageViewHeightConstraint.constant = successImageView.image?.size.height ?? 0
    }
    
    // MARK: - Subview population
    
    fileprivate func updateSubviewContents() {
        guard isViewLoaded else {
            return
        }
        
        var headlineText = NSAttributedString()
        if
            let text = dependencyManager.headlineText,
            let attributes = dependencyManager.headlineTextAttributes {
            headlineText = NSAttributedString(string: text, attributes: attributes)
        }
        headlineTextView.attributedText = headlineText
        
        var detailText = NSAttributedString()
        if
            let text = dependencyManager.detailText,
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
            confirmButton.setAttributedTitle(attributedConfirmText, for: .normal)
        }
        
        view.setNeedsUpdateConstraints()
    }
    
    // MARK: - Actions
    
    @IBAction fileprivate func onConfirm() {
        delegate?.successViewControllerFinished(self)
    }
}

private extension VDependencyManager {
    var successIcon: UIImage? {
        return image(forKey: "successIcon")
    }
    
    var successIconTintColor: UIColor? {
        return color(forKey: "color.successIcon")
    }
    
    var headlineText: String? {
        return string(forKey: "text.successMessage")
    }
    
    var headlineTextAttributes: [String : AnyObject]? {
        guard
            let font = font(forKey: "font.successMessage"),
            let color = color(forKey: "color.successMessage")
        else {
            return nil
        }
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        return [
            NSFontAttributeName: font,
            NSForegroundColorAttributeName: color,
            NSParagraphStyleAttributeName: paragraphStyle
        ]
    }
    
    var detailText: String? {
        return string(forKey: "text.successDetails")
    }
    
    var detailTextAttributes: [String : AnyObject]? {
        guard
            let font = font(forKey: "font.successDetails"),
            let color = color(forKey: "color.successDetails")
        else {
            return nil
        }
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        return [
            NSFontAttributeName: font,
            NSForegroundColorAttributeName: color,
            NSParagraphStyleAttributeName: paragraphStyle
        ]
    }
    
    var confirmButtonAttributedText: NSAttributedString? {
        guard
            let font = font(forKey: "font.proceedMessage"),
            let color = color(forKey: "color.proceedMessage"),
            let text = string(forKey: "text.proceedMessage")
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
        return color(forKey: "color.proceedButton")
    }
}
