//
//  AboutMeTextCell.swift
//  victorious
//
//  Created by Michael Sena on 7/18/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

/// Provides UI for the user to edit their `tagline`.
class AboutMeTextCell: UITableViewCell, UITextViewDelegate {
    fileprivate struct Constants {
        static let textViewInsets = UIEdgeInsets(top: 15, left: -4, bottom: 14, right: -5)
    }
    
    @IBOutlet fileprivate var textView: VPlaceholderTextView!
    
    var dependencyManager: VDependencyManager? {
        didSet {
            // Visual Configuration
            guard
                let dependencyManager = dependencyManager,
                let font = dependencyManager.placeholderAndEnteredTextFont,
                let placeholderTextColor = dependencyManager.placeholderTextColor,
                let enteredTextColor = dependencyManager.enteredTextColor else {
                    return
            }
            
            textView.placeholderText = "About Me"
            textView.setPlaceholderFont(font)
            textView.setPlaceholderTextColor(placeholderTextColor)
            textView.textColor = enteredTextColor
            textView.font = font
            textView.textContainerInset = Constants.textViewInsets
            
            contentView.backgroundColor = dependencyManager.cellBackgroundColor
        }
    }
    
    // MARK: - UITextViewDelegate
    
    func textView(_ textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        let newText = (textView.text as NSString).stringByReplacingCharactersInRange(range, withString: text)
        let isValid = newText.characters.count < 256;
        if !isValid {
            textView.v_performShakeAnimation()
        }
        
        return isValid
    }
    
    func textViewDidChange(_ textView: UITextView) {
        onDataChange?()
        notifySizeChangeIfNeeded()
    }
    
    // MARK: - API
    
    /// The current value of the user's
    var tagline: String? {
        get {
            return textView.text
        }
        set {
            textView.text = newValue
        }
    }
    
    /// Use this to bring up the UI for editing the `tagline`.
    func beginEditing() {
        textView.becomeFirstResponder()
    }
    
    /// Provide a closure to be notified when any data within the cell has changed.
    var onDataChange: (() -> ())?
    
    /// Provide a closure to be notified about changes to the height of the cell
    var onDesiredHeightChangeClosure: ((_ desiredHeight: CGFloat) -> ())?
    
    // MARK: - Misc Private Functions
    
    fileprivate func notifySizeChangeIfNeeded() {
        let textSize = textView.sizeThatFits(CGSize(width: textView.bounds.width, height: CGFloat.max))
        guard textSize.height != contentView.bounds.height else {
            return
        }
        onDesiredHeightChangeClosure?(desiredHeight: textSize.height)
    }
}

private extension VDependencyManager {
    
    var placeholderAndEnteredTextFont: UIFont? {
        return font(forKey: "font.paragraph")
    }
    
    var placeholderTextColor: UIColor? {
        return color(forKey: "color.text.placeholder")
    }
    
    var enteredTextColor: UIColor? {
        return color(forKey: "color.text")
    }
    
    var cellBackgroundColor: UIColor? {
        return color(forKey: "color.accent")
    }
}
