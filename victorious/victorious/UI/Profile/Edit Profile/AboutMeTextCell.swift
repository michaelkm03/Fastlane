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
    
    private struct Constants {
        static let textViewInsets = UIEdgeInsets(top: 15, left: -4, bottom: 14, right: -5)
    }
    
    @IBOutlet private var textView: VPlaceholderTextView!
    
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
    
    func textViewDidChange(textView: UITextView) {
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
    var onDesiredHeightChangeClosure: ((desiredHeight: CGFloat) -> ())?
    
    // MARK: - Misc Private Functions
    
    private func notifySizeChangeIfNeeded() {
        let textSize = textView.sizeThatFits(CGSize(width: textView.bounds.width, height: CGFloat.max))
        guard textSize.height != contentView.bounds.height else {
            return
        }
        onDesiredHeightChangeClosure?(desiredHeight: textSize.height)
    }
}

private extension VDependencyManager {
    
    var placeholderAndEnteredTextFont: UIFont? {
        return fontForKey("font.paragraph")
    }
    
    var placeholderTextColor: UIColor? {
        return colorForKey("color.text.placeholder")
    }
    
    var enteredTextColor: UIColor? {
        return colorForKey("color.text")
    }
    
    var cellBackgroundColor: UIColor? {
        return colorForKey("color.accent")
    }
}
