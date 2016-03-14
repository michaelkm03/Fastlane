//
//  ComposerTextViewManager.swift
//  victorious
//
//  Created by Sharif Ahmed on 3/11/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class ComposerTextViewManager: NSObject, UITextViewDelegate {
        
    let dismissalStrings: [String]

    var maximumTextLength: Int
    
    weak var delegate: ComposerTextViewManagerDelegate?
    
    init(textView: UITextView, delegate: ComposerTextViewManagerDelegate? = nil, maximumTextLength: Int = 0, dismissalStrings: [String] = ["\n"]) {
        self.maximumTextLength = maximumTextLength
        self.delegate = delegate
        self.dismissalStrings = dismissalStrings
        super.init()
        textView.delegate = self
    }
    
    //MARK: - Updating logic
    
    func canUpdateTextView(textView: UITextView, textInRange range: NSRange, replacementText text: String) -> Bool {
        
        var additionalTextLength = text.characters.count
        guard additionalTextLength > 0 else {
            return true
        }
        
        if dismissalStrings.contains(text) {
            textView.resignFirstResponder()
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
    
    //MARK: - UITextViewDelegate
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        return canUpdateTextView(textView, textInRange: range, replacementText: text)
    }
    
    func textViewDidChange(textView: UITextView) {
        updateDelegateOfTextViewStatus(textView)
    }
}
