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
    
    private var attachmentStringLength: Int
    
    private var updatingSelection = false
    
    init?(textView: UITextView, delegate: ComposerTextViewManagerDelegate? = nil, maximumTextLength: Int = 0, dismissOnReturn: Bool = true) {
        
        guard let imageString = ComposerTextViewManager.attachmentStringForImage(UIImage(), fromTextView: textView) else {
            assertionFailure("Failed to initialize ComposerTextViewManager because it was provided a textView with no textColor or font")
            return nil
        }
        self.attachmentStringLength = imageString.length
        self.maximumTextLength = maximumTextLength
        self.delegate = delegate
        self.dismissOnReturn = dismissOnReturn
        super.init()
        textView.delegate = self
    }
    
    //MARK: - Updating logic
    
    func replaceTextInRange(range: NSRange, withText text: String, inTextView textView: UITextView) -> Bool {
        
//        guard range.location + range.length <= updatedText.characters.count &&
//            canUpdateTextView(textView, textInRange: range, replacementText: text) else {
//            return false
//        }
//        
//        updatedText = (updatedText as NSString).stringByReplacingCharactersInRange(range, withString: text)
//        textView.attributedText = NSAttributedString(string: updatedText)
//        return true
        
        return false
        
    }
    
    func appendTextIfPossible(textView: UITextView, text: String) -> Bool {
        let replacementRange = NSRange(location: textView.text.characters.count, length: text.characters.count)
        let canAppendText = canUpdateTextView(textView, textInRange: replacementRange, replacementText: text)
        if canAppendText {
            let newString = NSMutableAttributedString()
            newString.appendAttributedString(textView.attributedText)
            newString.appendAttributedString(NSAttributedString(string: text))
            textView.attributedText = newString 
        }
        else {
            delegate?.textViewDidHitCharacterLimit(textView)
        }
        return canAppendText
    }
    
    func canUpdateTextView(textView: UITextView, textInRange range: NSRange, replacementText text: String) -> Bool {
        
        var additionalTextLength = text.characters.count
        if additionalTextLength <= 0 {
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
        delegate?.textViewHasText = !textView.text.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).isEmpty
        delegate?.textViewContentSize = textView.contentSize
        let imageRange = NSMakeRange(0, attachmentStringLength)
        let hasImage = textView.attributedText.length >= attachmentStringLength && textView.attributedText.containsAttachmentsInRange(imageRange)
        delegate?.textViewHasPrependedImage = hasImage
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
        guard canUpdateTextView(textView, textInRange: range, replacementText: text) else {
            delegate?.textViewDidHitCharacterLimit(textView)
            return false
        }
        
        if text.characters.count == 0 &&
            shouldRemoveImageFromTextView(textView, tryingToDeleteRange: range) {
            removePrependedImageFrom(textView)
            return true
        }
        
        return true
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
    
    func textViewDidChangeSelection(textView: UITextView) {
        guard let delegate = delegate where !updatingSelection else {
            updatingSelection = false
            return
        }
        
        if delegate.textViewHasPrependedImage && textView.selectedRange.location < attachmentStringLength {
            let amountInAttachmentArea = attachmentStringLength - textView.selectedRange.location
            let length = max(0, textView.selectedRange.length - amountInAttachmentArea)
            updatingSelection = true
            textView.selectedRange = NSMakeRange(attachmentStringLength, length)
        }
        
        if textView.selectedRange.length == 0 {
            delegate.textViewCurrentHashtag = hashtagStringAroundLocation(textView.selectedRange.location, inTextView: textView)
        } else {
            delegate.textViewCurrentHashtag = nil
        }
    }
    
    //MARK: - Helpers
    
    private static func attributedTextAttributesFor(textView: UITextView) -> [String: AnyObject]? {
        
        guard let font = textView.font,
            let color = textView.textColor else {
                return nil
        }
        
        return [NSFontAttributeName: font, NSForegroundColorAttributeName: color]
    }
    
    private func hashtagStringAroundLocation(location: Int, inTextView textView: UITextView) -> (String, NSRange)? {
        
        let hashtagCharacter = Character("#")
        let hashtagBoundaryCharacters = [hashtagCharacter, Character(" "), Character("\n")]

        let text = textView.text
        guard let (preceedingString, preceedingCharacter, preceedingRange) = text.substringBeforeLocation(location, afterCharacters: hashtagBoundaryCharacters) where
            preceedingCharacter == hashtagCharacter else {
            return nil
        }
        
        var foundRange = text.NSRangeFromRange(preceedingRange)
        guard let (proceedingString, _, proceedingRange) = text.substringAfterLocation(location, beforeCharacters: hashtagBoundaryCharacters) else {
            return (preceedingString, foundRange)
        }
        
        let foundEndRange = text.NSRangeFromRange(proceedingRange)
        foundRange = NSMakeRange(foundRange.location, foundRange.length + foundEndRange.length)
        return (preceedingString + proceedingString, foundRange)
    }
    
    //MARK: - Image management
    
    private static func attachmentStringForImage(image: UIImage, fromTextView textView: UITextView) -> NSAttributedString? {
        
        guard let attributes = attributedTextAttributesFor(textView) else {
            return nil
        }
        
        let attachment = NSTextAttachment()
        attachment.image = image
        let screenScale = UIScreen.mainScreen().scale
        attachment.bounds.size = CGSizeMake(image.size.width / screenScale, image.size.height / screenScale)
        let imageString = NSAttributedString(attachment: attachment).mutableCopy() as! NSMutableAttributedString
        imageString.addAttributes(attributes, range: NSMakeRange(0, imageString.length))
        let newLineString = NSAttributedString(string: "\n", attributes: attributes)
        imageString.appendAttributedString(newLineString)
        return imageString
    }
    
    func prependImage(image: UIImage, toTextView textView: UITextView) -> Bool {
        
        guard let prependedString = ComposerTextViewManager.attachmentStringForImage(image, fromTextView: textView) else {
            return false
        }
        
        removePrependedImageFrom(textView)
        
        let mutableText = textView.attributedText.mutableCopy() as! NSMutableAttributedString
        mutableText.insertAttributedString(prependedString, atIndex: 0)
        textView.attributedText = mutableText
        updateDelegateOfTextViewStatus(textView)
        return true
    }
    
    func removePrependedImageFrom(textView: UITextView) {
        guard let delegate = delegate else {
            return
        }
        
        if delegate.textViewHasPrependedImage {
            let imageRange = NSMakeRange(0, attachmentStringLength)
            let mutableText = textView.attributedText.mutableCopy() as! NSMutableAttributedString
            mutableText.deleteCharactersInRange(imageRange)
            textView.attributedText = mutableText
        }
        updateDelegateOfTextViewStatus(textView)
    }
    
    private func shouldRemoveImageFromTextView(textView: UITextView, tryingToDeleteRange range: NSRange) -> Bool {
        
        guard let delegate = delegate else {
            return false
        }
        
        return delegate.textViewHasPrependedImage && range.location < attachmentStringLength
    }
}
