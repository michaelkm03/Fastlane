//
//  AboutMeTextCell.swift
//  victorious
//
//  Created by Michael Sena on 7/18/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class AboutMeTextCell: UITableViewCell, UITextViewDelegate {
    
    var tagline: String? {
        get {
            return textView.text
        }
    }
    
    var dependencyManager: VDependencyManager? {
        didSet {
            // Visual Configuration
            guard let dependencyManager = dependencyManager,
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
            
            contentView.backgroundColor = dependencyManager.cellBackgroundColor
        }
    }
    
    /// Provide a closure to be notified about changes to the height of the cell
    var onDesiredHeightChangeClosure: ((desiredHeight: CGFloat) -> ())?
    
    @IBOutlet private var textView: VPlaceholderTextView!
    
    // MARK: - Target / Action
    
    @objc func textViewDidChange(textView: UITextView) {
        let textSize = textView.sizeThatFits(CGSize(width: textView.bounds.width, height: CGFloat.max))
        guard textSize.height != contentView.bounds.height else {
            return
        }
        
        onDesiredHeightChangeClosure?(desiredHeight: textSize.height)
    }
    
    // MARK: - API
    
    func beginEditing() {
        textView.becomeFirstResponder()
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
