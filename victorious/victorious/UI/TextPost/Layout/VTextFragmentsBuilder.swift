//
//  VFragmentsBuilder.swift
//  victorious
//
//  Created by Patrick Lynch on 4/13/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

/**
Represents a line, part of a line or a single word of text
*/
class VTextFragment
{
    static let topInsetMultiplier: CGFloat = 0.42
    static let bottomInsetMultipler: CGFloat = 0.09
    
    let text: String
    var rect: CGRect
    let range: NSRange
    let isCallout: Bool ///< Is this fragment a callout as indicated by a callout delimeter prefix ("#" or "@")
    let isNewLine: Bool ///< Is the fragment the star to of a new line
    
    init( text: String, rect: CGRect, range: NSRange, isCallout: Bool, isNewLine: Bool )
    {
        self.text = text
        self.rect = rect
        self.range = range
        self.isCallout = isCallout
        self.isNewLine = isNewLine
    }
}

/**
Primary reponsiblity is to break apart attributed text from a text view into a group of
VTextFragments so that the `rect` properties of those fragments can be rendered in the background
of a text view for text posts.
*/
class VTextFragmentsBuilder: NSObject
{
    /**
    Iterates through the text in the text view using properties of the text view's attributed text,
    layoutManager and textContainer in order to size and position background frame elements properly.
    */
    func fragmentsInTextView( textView: UITextView, calloutRanges: [NSRange] ) -> [VTextFragment]
    {
        var output = [VTextFragment]()
        
        let text: NSString = count(textView.attributedText.string) == 0 ? " " : textView.attributedText.string
        textView.textContainer.size = CGSizeMake( textView.bounds.size.width, CGFloat.max )
        
        var currentFragmentRect = CGRectZero
        var lastFragmentRect = CGRectZero
        var lastCalloutIndex: Int = -1
        var selectedRangeLocation = 0
        var fragmentStartIndex = 0
        var isNewLine = true
        
        for i in 0...text.length-1
        {
            let glyphRange = NSMakeRange( i, 1 )
            let currentCharacter = text.substringWithRange( glyphRange )
            let fragmentRect = textView.layoutManager.boundingRectForGlyphRange( glyphRange, inTextContainer: textView.textContainer )
            let fragmentRange = NSMakeRange( fragmentStartIndex, i - fragmentStartIndex )
            let fragmentText = text.substringWithRange( fragmentRange )
            let isSpace = currentCharacter == " "
            let needsNewLine = i > 0 && fragmentRect.origin.y > lastFragmentRect.origin.y
            let isLastCharacter = i == text.length-1
            let isFirstCharacter = i == 0
            let isMinCalloutLength = fragmentRange.length > 2
            let calloutIndex: Int = self.indexOfCalloutRangeContainingIndex( i, calloutRanges: calloutRanges ) ?? -1
            let isLineBreak = currentCharacter == "\n"
            
            
            if isFirstCharacter
            {
                fragmentStartIndex = i
                currentFragmentRect = fragmentRect
            }
            
            let isStartOfCallout = calloutIndex >= 0 && lastCalloutIndex != calloutIndex && fragmentText != "\n"
            let isEndOfCallout = calloutIndex < 0 && lastCalloutIndex >= 0 && fragmentText != "\n"
            
            if isStartOfCallout
            {
                if count(fragmentText) > 0
                {
                    output.append( VTextFragment(
                        text: fragmentText,
                        rect:currentFragmentRect,
                        range: fragmentRange,
                        isCallout: calloutIndex >= 0,
                        isNewLine: isNewLine )
                    )
                    isNewLine = false
                }
                fragmentStartIndex = i
                currentFragmentRect = fragmentRect
            }
            else if isEndOfCallout
            {
                output.append( VTextFragment(
                    text: fragmentText,
                    rect:currentFragmentRect,
                    range: fragmentRange,
                    isCallout: calloutIndex >= 0,
                    isNewLine: isNewLine )
                )
                isNewLine = false
                fragmentStartIndex = i
                currentFragmentRect = fragmentRect
            }
            else if needsNewLine
            {
                let isValidFragment = count(fragmentText) > 0 && fragmentText != " " && fragmentText != "\n"
                if isValidFragment
                {
                    output.append( VTextFragment(
                        text: fragmentText,
                        rect: currentFragmentRect,
                        range: fragmentRange,
                        isCallout: calloutIndex >= 0,
                        isNewLine: isNewLine )
                    )
                }
                isNewLine = true
                fragmentStartIndex = i
                currentFragmentRect = fragmentRect
            }
            
            if !isLineBreak
            {
                currentFragmentRect.size.width = CGRectGetMaxX( fragmentRect ) - currentFragmentRect.origin.x
            }
            
            if isLastCharacter
            {
                let lastRange = NSMakeRange( fragmentStartIndex, i - fragmentStartIndex + 1 )
                let text = text.substringWithRange( lastRange )
                if count(text) > 0 && text != "\n"
                {
                    output.append( VTextFragment(
                        text: text,
                        rect: currentFragmentRect,
                        range: fragmentRange,
                        isCallout: calloutIndex >= 0,
                        isNewLine: isNewLine )
                    )
                }
            }
            
            lastCalloutIndex = calloutIndex
            lastFragmentRect = fragmentRect
        }
        
        return output
    }
    
    /**
    Applies spacing adjustments to the rects of each VTextFragment to match up within the layout
    of the textView when rending those rects as background frames.  The spacing values all derive from
    readable properties of attribtues of the text and are all based on how it looks when rendered.char
    */
    func applySpacingToFragments( fragments: [VTextFragment], spacing: CGFloat, horizontalOffset: CGFloat )
    {
        for var i = 0; i < count(fragments); i++
        {
            let fragment = fragments[i]
            
            // Apply offsets and collect rects for output
            let original = fragment.rect
            fragment.rect = CGRect(
                x: original.origin.x + spacing - horizontalOffset,
                y: original.origin.y + original.size.height * VTextFragment.topInsetMultiplier,
                width: original.size.width - spacing * 2,
                height: original.size.height - original.size.height * VTextFragment.bottomInsetMultipler
            )
            
            if let nextFragment = (i < fragments.count - 1 ? fragments[i+1] : nil)
            {
                if nextFragment.isNewLine
                {
                    let multipler: CGFloat = fragment.isCallout ? 1.0 : 2.0
                    fragment.rect.size.width += horizontalOffset * multipler
                }
            }
            else
            {
                fragment.rect.size.width += horizontalOffset
            }
        }
    }
    
    // MARK: - Private helpers
    
    private func indexOfCalloutRangeContainingIndex( index: Int, calloutRanges: [NSRange] ) -> Int?
    {
        if calloutRanges.count == 0
        {
            return nil
        }
        for i in 0...calloutRanges.count - 1
        {
            let range = calloutRanges[i]
            if index >= range.location && index < range.location + range.length
            {
                return i
            }
        }
        return nil
    }
}
