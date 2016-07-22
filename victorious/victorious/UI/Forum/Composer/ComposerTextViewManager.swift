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
        updateDelegateOfTextViewStatus(textView)
    }
    
    // MARK: - Updating logic
    
    func replaceTextInRange(range: NSRange, withText text: String, inTextView textView: UITextView) -> Bool {
        
        let mutableString = NSMutableAttributedString(attributedString: textView.attributedText)
        
        guard range.location + range.length <= mutableString.string.characters.count &&
            canUpdateTextView(textView, textInRange: range, replacementText: text) else {
            return false
        }
        
        mutableString.replaceCharactersInRange(range, withString: text)
        textView.attributedText = mutableString
        
        return true
    }
    
    func appendTextIfPossible(textView: UITextView, text: String) -> Bool {
        let replacementRange = NSRange(location: textView.text.characters.count, length: text.characters.count)
        let canAppendText = canUpdateTextView(textView, textInRange: replacementRange, replacementText: text)
        if canAppendText {
            let newString = NSMutableAttributedString(attributedString: textView.attributedText)
            newString.appendAttributedString(NSAttributedString(string: text, attributes: getTextViewInputAttributes()))
            textView.attributedText = newString
            updateDelegateOfTextViewStatus(textView)
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
            return true
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
        delegate?.textViewHasText = captionFromTextView(textView, afterRemovingImage: false) != nil
        delegate?.textViewContentSize = textView.contentSize
    }
    
    func resetTextView(textView: UITextView) {
        textView.text = nil
        delegate?.textViewPrependedImage = nil
        updateDelegateOfTextViewStatus(textView)
    }
    
    func shouldDismissForText(text: String) -> Bool {
        return dismissOnReturn && text == "\n"
    }
    
    // MARK: - UITextViewDelegate
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        guard canUpdateTextView(textView, textInRange: range, replacementText: text) else {
            delegate?.textViewDidHitCharacterLimit(textView)
            return false
        }
        
        if
            text.characters.count == 0 &&
            shouldRemoveImageFromTextView(textView, tryingToDeleteRange: range)
        {
            removePrependedImageFrom(textView)
            // We handle the deletion ourselves through the removePrependedImage method
            return false
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
    
    // MARK: - Helpers
    
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
    
    // MARK: - Image management
    
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
        delegate?.textViewPrependedImage = image
        updateDelegateOfTextViewStatus(textView)
        return true
    }
    
    func removePrependedImageFrom(textView: UITextView) {
        if delegate?.textViewHasPrependedImage == true {
            textView.attributedText = removePrependedImageFromAttributedText(textView.attributedText)
            delegate?.textViewPrependedImage = nil
        }
        updateDelegateOfTextViewStatus(textView)
    }
    
    private func removePrependedImageFromAttributedText(attributedText: NSAttributedString) -> NSAttributedString? {
        let imageRange = NSMakeRange(0, attachmentStringLength)
        let mutableText = attributedText.mutableCopy() as! NSMutableAttributedString
        mutableText.deleteCharactersInRange(imageRange)
        let immutableCopy = mutableText.copy() as! NSAttributedString
        return immutableCopy.length > 0 ? immutableCopy : nil
    }
    
    private func shouldRemoveImageFromTextView(textView: UITextView, tryingToDeleteRange range: NSRange) -> Bool {
        return delegate?.textViewHasPrependedImage == true && range.location < attachmentStringLength
    }
    
    private func getTextViewInputAttributes() -> [String: AnyObject] {
        guard
            let delegate = delegate,
            let color = delegate.inputTextAttributes().inputTextColor,
            let font = delegate.inputTextAttributes().inputTextFont
        else {
            return [:]
        }
        
        return [
            NSForegroundColorAttributeName : color,
            NSFontAttributeName            : font
        ]
    }
    
    // This method removes leading and trailing whitespace and, optionally, a prepended image attachment from a copy of the the provided textView's attributed text.
    // It does not change any text on the textView and, therefore, does not update any status of delegate-stored properties.
    func captionFromTextView(textView: UITextView, afterRemovingImage: Bool = true) -> String? {
        var attributedText: NSAttributedString? = textView.attributedText
        if
            afterRemovingImage
            && delegate?.textViewHasPrependedImage == true,
            let existingText = attributedText
        {
            attributedText = removePrependedImageFromAttributedText(existingText)
        }
    
        guard
            let text = attributedText?.string.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
            where !text.isEmpty
        else {
            return nil
        }
        return text
    }
}
