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
        let replacementRange = NSRange(location: textView.text.lengthWithUnicode, length: text.lengthWithUnicode)
        let appendedText = canUpdateTextView(textView, textInRange: replacementRange, replacementText: text)
        if appendedText {
            textView.text = textView.text + text
        }
        return appendedText
    }
    
    func canUpdateTextView(textView: UITextView, textInRange range: NSRange, replacementText text: String) -> Bool {
        
        var additionalTextLength = text.lengthWithUnicode
        guard additionalTextLength > 0 else {
            return true
        }
        
        if shouldDismissForText(text) {
            textView.resignFirstResponder()
            return false
        }
        
        if maximumTextLength == 0 {
            return true
        }
        
        if range.location < textView.text.lengthWithUnicode {
            additionalTextLength -= range.length
        }
        
        return additionalTextLength + textView.text.lengthWithUnicode <= maximumTextLength
    }
    
    func updateDelegateOfTextViewStatus(textView: UITextView) {
        delegate?.textViewHasText = textView.text.lengthWithUnicode > 0
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
}
