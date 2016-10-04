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
    
    fileprivate var attachmentStringLength: Int
    
    fileprivate var updatingSelection = false
    
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
    
    func replaceTextInRange(_ range: NSRange, withText text: String, inTextView textView: UITextView) -> Bool {
        
        let mutableString = NSMutableAttributedString(attributedString: textView.attributedText)
        
        guard range.location + range.length <= mutableString.string.characters.count &&
            canUpdateTextView(textView, textInRange: range, replacementText: text) else {
            return false
        }
        
        mutableString.replaceCharacters(in: range, with: text)
        textView.attributedText = mutableString
        
        return true
    }
    
    func insertTextAtSelectionIfPossible(_ textView: UITextView, text: String) -> Bool {
        guard let selectedTextRange = textView.selectedTextRange else {
            return false
        }
        
        let selectedRange = textView.selectedRange
        let replacementRange = NSRange(location: selectedRange.location, length: text.characters.count - selectedRange.length)
        let canAppendText = canUpdateTextView(textView, textInRange: replacementRange, replacementText: text)
        if canAppendText {
            textView.replaceRange(selectedTextRange, withText: text)
            updateDelegateOfTextViewStatus(textView)
        }
        else {
            delegate?.textViewDidHitCharacterLimit(textView)
        }
        return canAppendText
    }
    
    func appendTextIfPossible(_ textView: UITextView, text: String) -> Bool {
        let replacementRange = NSRange(location: textView.text.characters.count, length: text.characters.count)
        let canAppendText = canUpdateTextView(textView, textInRange: replacementRange, replacementText: text)
        if canAppendText {
            let newString = NSMutableAttributedString(attributedString: textView.attributedText)
            newString.append(NSAttributedString(string: text, attributes: getTextViewInputAttributes()))
            textView.attributedText = newString
            updateDelegateOfTextViewStatus(textView)
        }
        else {
            delegate?.textViewDidHitCharacterLimit(textView)
        }
        return canAppendText
    }
    
    func canUpdateTextView(_ textView: UITextView, textInRange range: NSRange, replacementText text: String) -> Bool {
        
        var additionalTextLength = text.characters.count
        if additionalTextLength <= 0 {
            return true
        }
                
        if shouldDismissForText(text) {
            if let delegate = delegate , delegate.textViewCanDismiss {
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
    
    func updateDelegateOfTextViewStatus(_ textView: UITextView) {
        delegate?.textViewHasText = captionFromTextView(textView, afterRemovingImage: false) != nil
        delegate?.textViewContentSize = textView.contentSize
    }
    
    func resetTextView(_ textView: UITextView) {
        textView.text = nil
        delegate?.textViewPrependedImage = nil
        updateDelegateOfTextViewStatus(textView)
    }
    
    func shouldDismissForText(_ text: String) -> Bool {
        return dismissOnReturn && text == "\n"
    }
    
    // MARK: - UITextViewDelegate
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
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
    
    func textViewDidChange(_ textView: UITextView) {
        updateDelegateOfTextViewStatus(textView)
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        delegate?.textViewIsEditing = true
        updateCurrentHashtag(forTextView: textView)
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        endEditing(textView)
        return true
    }
    
    func endEditing(_ textView: UITextView) {
        delegate?.textViewIsEditing = false
        updateCurrentHashtag(forTextView: textView, isDismissing: true)
    }
    
    func textViewDidChangeSelection(_ textView: UITextView) {
        guard let delegate = delegate , !updatingSelection else {
            updatingSelection = false
            return
        }
        
        if delegate.textViewHasPrependedImage && textView.selectedRange.location < attachmentStringLength {
            let amountInAttachmentArea = attachmentStringLength - textView.selectedRange.location
            let length = max(0, textView.selectedRange.length - amountInAttachmentArea)
            updatingSelection = true
            textView.selectedRange = NSMakeRange(attachmentStringLength, length)
        }
        
        updateCurrentHashtag(forTextView: textView)
    }
    
    fileprivate func updateCurrentHashtag(forTextView textView: UITextView, isDismissing: Bool = false) {
        if !isDismissing &&
            textView.isFirstResponder &&
            textView.selectedRange.length == 0 {
            delegate?.textViewCurrentHashtag = hashtagStringAroundLocation(textView.selectedRange.location, inTextView: textView)
        } else {
            delegate?.textViewCurrentHashtag = nil
        }
    }
    
    // MARK: - Helpers
    
    fileprivate static func attributedTextAttributesFor(_ textView: UITextView) -> [String: AnyObject]? {
        
        guard let font = textView.font,
            let color = textView.textColor else {
                return nil
        }
        
        return [NSFontAttributeName: font, NSForegroundColorAttributeName: color]
    }
    
    fileprivate func hashtagStringAroundLocation(_ location: Int, inTextView textView: UITextView) -> (String, NSRange)? {
        
        let hashtagCharacter = Character("#")
        let hashtagBoundaryCharacters = [hashtagCharacter, Character(" "), Character("\n")]

        let text = textView.text!
        guard let (preceedingString, preceedingCharacter, preceedingRange) = text.substringBeforeLocation(location: location, afterCharacters: hashtagBoundaryCharacters) ,
            preceedingCharacter == hashtagCharacter else {
            return nil
        }
        
        var foundRange = text.NSRangeFromRange(range: preceedingRange)
        guard let (proceedingString, _, proceedingRange) = text.substringAfterLocation(location: location, beforeCharacters: hashtagBoundaryCharacters) else {
            return (preceedingString, foundRange)
        }
        
        let foundEndRange = text.NSRangeFromRange(range: proceedingRange)
        foundRange = NSMakeRange(foundRange.location, foundRange.length + foundEndRange.length)
        return (preceedingString + proceedingString, foundRange)
    }
    
    // MARK: - Image management
    
    fileprivate static func attachmentStringForImage(_ image: UIImage, fromTextView textView: UITextView) -> NSAttributedString? {
        
        guard let attributes = attributedTextAttributesFor(textView) else {
            return nil
        }
        
        let attachment = NSTextAttachment()
        attachment.image = image
        let screenScale = UIScreen.main.scale
        attachment.bounds.size = CGSize(width: image.size.width / screenScale, height: image.size.height / screenScale)
        let imageString = NSAttributedString(attachment: attachment).mutableCopy() as! NSMutableAttributedString
        imageString.addAttributes(attributes, range: NSMakeRange(0, imageString.length))
        let newLineString = NSAttributedString(string: "\n", attributes: attributes)
        imageString.append(newLineString)
        return imageString
    }
    
    func prependImage(_ image: UIImage, toTextView textView: UITextView) -> Bool {
        
        guard let prependedString = ComposerTextViewManager.attachmentStringForImage(image, fromTextView: textView) else {
            return false
        }
        
        removePrependedImageFrom(textView)
        
        let mutableText = textView.attributedText.mutableCopy() as! NSMutableAttributedString
        mutableText.insert(prependedString, at: 0)
        textView.attributedText = mutableText
        delegate?.textViewPrependedImage = image
        updateDelegateOfTextViewStatus(textView)
        return true
    }
    
    fileprivate func removePrependedImageFrom(_ textView: UITextView) {
        if delegate?.textViewHasPrependedImage == true {
            textView.attributedText = removePrependedImageFromAttributedText(textView.attributedText)
            delegate?.textViewPrependedImage = nil
        }
        updateDelegateOfTextViewStatus(textView)
    }
    
    fileprivate func removePrependedImageFromAttributedText(_ attributedText: NSAttributedString) -> NSAttributedString? {
        let imageRange = NSMakeRange(0, attachmentStringLength)
        let mutableText = attributedText.mutableCopy() as! NSMutableAttributedString
        mutableText.deleteCharacters(in: imageRange)
        let immutableCopy = mutableText.copy() as! NSAttributedString
        return immutableCopy.length > 0 ? immutableCopy : nil
    }
    
    fileprivate func shouldRemoveImageFromTextView(_ textView: UITextView, tryingToDeleteRange range: NSRange) -> Bool {
        return delegate?.textViewHasPrependedImage == true && range.location < attachmentStringLength
    }
    
    fileprivate func getTextViewInputAttributes() -> [String: AnyObject] {
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
    func captionFromTextView(_ textView: UITextView, afterRemovingImage: Bool = true) -> String? {
        var attributedText: NSAttributedString? = textView.attributedText
        if
            afterRemovingImage
            && delegate?.textViewHasPrependedImage == true,
            let existingText = attributedText
        {
            attributedText = removePrependedImageFromAttributedText(existingText)
        }
    
        guard
            let text = attributedText?.string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            , !text.isEmpty
        else {
            return nil
        }
        return text
    }
}
