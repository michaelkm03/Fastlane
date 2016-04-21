//
//  ComposerTextViewManager.swift
//  victorious
//
//  Created by Sharif Ahmed on 3/11/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class ComposerTextViewManager: NSObject, UITextViewDelegate {
        
    let dismissOnReturn: Bool

    var maximumTextLength: Int
    
    weak var delegate: ComposerTextViewManagerDelegate?
    
    init(textView: UITextView, delegate: ComposerTextViewManagerDelegate? = nil, maximumTextLength: Int = 0, dismissOnReturn: Bool = true) {
        self.maximumTextLength = maximumTextLength
        self.delegate = delegate
        self.dismissOnReturn = dismissOnReturn
        super.init()
        textView.delegate = self
    }
    
    //MARK: - Updating logic
    
    func appendTextIfPossible(textView: UITextView, text: String) -> Bool {
        let replacementRange = NSRange(location: textView.text.characters.count, length: text.characters.count)
        let appendedText = canUpdateTextView(textView, textInRange: replacementRange, replacementText: text)
        if appendedText {
            textView.text = textView.text + text
        }
        return appendedText
    }
    
    func canUpdateTextView(textView: UITextView, textInRange range: NSRange, replacementText text: String) -> Bool {
        
        var additionalTextLength = text.characters.count
        guard additionalTextLength > 0 else {
            return true
        }
        
        if shouldDismissForText(text) {
            if let delegate = delegate where delegate.textViewCanDismiss {
                textView.resignFirstResponder()
            }
            return false
        }
        
        if maximumTextLength == 0 {
            return true
        }
        
        if range.location < textView.text.characters.count {
            additionalTextLength -= range.length
        }
        
        return additionalTextLength + textView.text.characters.count <= maximumTextLength
    }
    
    func updateDelegateOfTextViewStatus(textView: UITextView) {
        delegate?.textViewHasText = textView.text.characters.count > 0
        delegate?.textViewContentSize = textView.contentSize
    }
    
    func resetTextView(textView: UITextView) {
        textView.text = nil
        updateDelegateOfTextViewStatus(textView)
    }
    
    func shouldDismissForText(text: String) -> Bool {
        return dismissOnReturn && text == "\n"
    }
    
    //MARK: - UITextViewDelegate
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        return canUpdateTextView(textView, textInRange: range, replacementText: text)
    }
    
    func textViewDidChange(textView: UITextView) {
        updateDelegateOfTextViewStatus(textView)
    }
    
    func textViewDidBeginEditing(textView: UITextView) {
        delegate?.textViewIsEditing = true
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        delegate?.textViewIsEditing = false
    }
}
