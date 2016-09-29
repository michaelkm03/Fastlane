//
//  InlineValidationTextField.swift
//  victorious
//
//  Created by Jarod Long on 9/28/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import AudioToolbox
import UIKit

class InlineValidationTextField: UITextField {
    private struct Constants {
        static let baseIntrinsicHeight = CGFloat(26.0)
        static let validationHeight = CGFloat(24.0)
        static let sideInset = CGFloat(10.0)
        static let bottomClearInset = CGFloat(2.0)
    }
    
    // MARK: - Initializing
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setup()
    }
    
    private func setup() {
        validationIsVisible = false
        
        validationImageView.translatesAutoresizingMaskIntoConstraints = false
        validationImageView.image = UIImage(named: "inline_validation_alert_icon")?.imageWithRenderingMode(.AlwaysTemplate)
        validationImageView.tintColor = .redColor()
        
        validationLabel.translatesAutoresizingMaskIntoConstraints = false
        validationLabel.font = VThemeManager.sharedThemeManager().themedFontForKey(kVLabel4Font)
        validationLabel.numberOfLines = 2
        validationLabel.textColor = .redColor()
        
        addSubview(validationImageView)
        addSubview(validationLabel)
    }
    
    // MARK: - Subviews
    
    private let validationImageView = UIImageView()
    private let validationLabel = UILabel()
    
    // MARK: - Managing validation text
    
    private var validationIsVisible: Bool {
        get {
            return !validationLabel.hidden
        }
        set {
            validationImageView.hidden = !newValue
            validationLabel.hidden = !newValue
        }
    }
    
    func hideInvalidText() {
        validationIsVisible = false
        invalidateIntrinsicContentSize()
    }
    
    func showInvalidText(invalidText: String, animated: Bool, shake: Bool, forced: Bool) {
        guard forced || hasResignedFirstResponder else {
            return
        }
        
        validationLabel.text = invalidText
        validationIsVisible = true
        
        if animated {
            v_performShakeAnimation()
        }
        
        if shake {
            AudioServicesPlayAlertSound(kSystemSoundID_Vibrate)
        }
        
        invalidateIntrinsicContentSize()
    }
    
    func applyTextFieldStyle() {
        tintColor = VThemeManager.sharedThemeManager().themedColorForKey(kVLinkColor)
        font = VThemeManager.sharedThemeManager().themedFontForKey(kVHeading4Font)
        textColor = VThemeManager.sharedThemeManager().themedColorForKey(kVContentTextColor)
        invalidateIntrinsicContentSize()
    }
    
    func clearValidation() {
        hasResignedFirstResponder = false
        validationIsVisible = false
        invalidateIntrinsicContentSize()
    }
    
    // MARK: - Managing placeholders
    
    /// A placeholder that will display when the field is not the first responder.
    var inactivePlaceholder: NSAttributedString? {
        didSet {
            updatePlaceholder()
        }
    }
    
    /// A placeholder that will display when the field is the first responder.
    var activePlaceholder: NSAttributedString? {
        didSet {
            updatePlaceholder()
        }
    }
    
    private func updatePlaceholder() {
        if isFirstResponder() {
            if let activePlaceholder = activePlaceholder {
                attributedPlaceholder = activePlaceholder
            }
        }
        else if let inactivePlaceholder = inactivePlaceholder {
            attributedPlaceholder = inactivePlaceholder
        }
    }
    
    // MARK: - Managing first responder state
    
    private var hasResignedFirstResponder = false
    
    override func becomeFirstResponder() -> Bool {
        attributedPlaceholder = activePlaceholder
        return super.becomeFirstResponder()
    }
    
    override func resignFirstResponder() -> Bool {
        attributedPlaceholder = inactivePlaceholder
        
        if isFirstResponder() {
            hasResignedFirstResponder = true
        }
        
        return super.resignFirstResponder()
    }
    
    // MARK: - UITextField
    
    override func textRectForBounds(bounds: CGRect) -> CGRect {
        var modifiedRect = super.textRectForBounds(bounds).insetBy(dx: Constants.sideInset, dy: 0.0)
        modifiedRect.origin.y = Constants.validationHeight
        modifiedRect.size.height -= Constants.validationHeight
        return modifiedRect
    }
    
    override func placeholderRectForBounds(bounds: CGRect) -> CGRect {
        return textRectForBounds(bounds)
    }
    
    override func editingRectForBounds(bounds: CGRect) -> CGRect {
        return textRectForBounds(bounds)
    }
    
    override func clearButtonRectForBounds(bounds: CGRect) -> CGRect {
        var modifiedRect = super.clearButtonRectForBounds(bounds)
        modifiedRect.origin.y = bounds.maxY - modifiedRect.size.height - Constants.bottomClearInset
        return modifiedRect
    }
    
    // MARK: - Layout
    
    override func intrinsicContentSize() -> CGSize {
        return CGSize(
            width: UIViewNoIntrinsicMetric,
            height: Constants.validationHeight + Constants.baseIntrinsicHeight
        )
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let alertImageSize = validationImageView.intrinsicContentSize()
        
        validationLabel.frame = CGRect(
            x: bounds.minX + alertImageSize.width + 5.0,
            y: bounds.minY,
            width: bounds.width - alertImageSize.width - 5.0,
            height: Constants.validationHeight
        )
        
        validationImageView.frame = CGRect(
            x: bounds.minX,
            y: bounds.minY + (Constants.validationHeight - alertImageSize.height) / 2.0,
            width: alertImageSize.width,
            height: alertImageSize.height
        )
    }
}
