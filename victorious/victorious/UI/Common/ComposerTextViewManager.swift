//
//  ComposerTextViewManager.swift
//  victorious
//
//  Created by Sharif Ahmed on 3/11/16.
//  Copyright © 2016 Victorious. All rights reserved.
//

import Foundation

class ComposerTextViewManager: NSObject, UITextViewDelegate {
    
    var maximumTextLength: Int
    
    var lastContentSize: CGSize
    
    let dismissalStrings: [String]
    
    weak var delegate: ComposerTextViewManagerDelegate?
    
    init(maximumTextLength: Int, dismissalStrings: [String] = ["\n"], textView: UITextView, delegate: ComposerTextViewManagerDelegate?) {
        self.maximumTextLength = maximumTextLength
        self.delegate = delegate
        self.dismissalStrings = dismissalStrings
        lastContentSize = textView.contentSize
        super.init()
        textView.delegate = self
    }
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
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

        return additionalTextLength + textView.text.characters.count < maximumTextLength
    }
    
    func textViewDidChange(textView: UITextView) {
        delegate?.textViewHasText = textView.text.characters.count > 0
        delegate?.textViewContentSize = textView.contentSize
    }
}
