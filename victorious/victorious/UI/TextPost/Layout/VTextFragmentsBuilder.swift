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
struct VTextFragment
{
    let text: String
    let rect: CGRect
    let range: NSRange
    let isCallout: Bool ///< Is this fragment a callout as indicated by a callout delimeter prefix ("#" or "@")
    let isNewLine: Bool ///< Is the fragment the star to of a new line
}

/**
A group of offset, spacing and inset values needed to properly calculate the final
layout size and position of background frames for a text view.
*/
struct VTextFragmentOffsets
{
    let horizontalOffset: CGFloat ///< Offset applied accoring to encapsulated layout rules
    let horizontalSpacing: CGFloat ///< Spacing between fragments
    let topInset: CGFloat ///< Offset applied to fragments to line up with text in text view
    let bottomInset: CGFloat ///< Offset applied to fragments to line up with text in text view
}

/**
Primary reponsiblity is to break apart attributed text from a text view into a group of
VTextFragments so that the `rect` properties of those fragments can be rendered in the background
of a text view for text posts.
*/
class VTextFragmentsBuilder: NSObject
{
    /**
    Iterates through the text in the text view using properties of the text view's attribtued text,
    layoutManager and textContainer in order to size and position background frame elements properly.
    */
    func fragmentsInTextView( textView: UITextView, calloutDelimeters: [String] ) -> [VTextFragment]
    {
        var output = [VTextFragment]()
        
        let text: NSString = count(textView.attributedText.string) == 0 ? " " : textView.attributedText.string
        textView.textContainer.size = CGSizeMake( textView.bounds.size.width, CGFloat.max )
        
        var currentFragmentRect = CGRectZero
        var lastFragmentRect = CGRectZero
        var isCalloutFragment = false
        var selectedRangeLocation = 0
        var fragmentStartIndex = 0
        var isNewLine = true
        
        for i in 0...text.length-1
        {
            let glyphRange = NSMakeRange( i, 1 )
            let currentCharacter = text.substringWithRange( glyphRange )
            let fragmentRect = textView.layoutManager.boundingRectForGlyphRange( glyphRange, inTextContainer: textView.textContainer )
            let fragmentRange = NSMakeRange( fragmentStartIndex, i - fragmentStartIndex + 1 )
            let fragmentText = text.substringWithRange( fragmentRange )
            let isCalloutDelimeter = contains( calloutDelimeters, currentCharacter )
            let isSpace = currentCharacter == " "
            let needsNewLine = i > 0 && fragmentRect.origin.y > lastFragmentRect.origin.y
            let isEndOfCallout = isSpace && isCalloutFragment
            let isLastCharacter = i == text.length-1
            let isFirstCharacter = i == 0
            let isMinCalloutLength = fragmentRange.length > 2
            
            if isFirstCharacter
            {
                fragmentStartIndex = i
                currentFragmentRect = fragmentRect
            }
            
            if needsNewLine
            {
                if ( fragmentText != " " )
                {
                    output.append( VTextFragment(
                        text: fragmentText,
                        rect:currentFragmentRect, range: fragmentRange,
                        isCallout: isCalloutFragment,
                        isNewLine: isNewLine )
                    )
                }
                isNewLine = true
                fragmentStartIndex = i
                currentFragmentRect = fragmentRect
            }
            
            if isCalloutDelimeter && !isLastCharacter
            {
                let nextCharacter = text.substringWithRange( NSMakeRange( i+1, 1 ) )
                if nextCharacter != " " ///< Make sure text typed isn't "#" followed by space
                {
                    if count(fragmentText) > 0 ///< Don't create fragments with empty text
                    {
                        output.append( VTextFragment(
                            text: fragmentText,
                            rect:currentFragmentRect,
                            range: fragmentRange,
                            isCallout: isCalloutFragment,
                            isNewLine: isNewLine )
                        )
                    }
                    isNewLine = false
                    fragmentStartIndex = i
                    currentFragmentRect = fragmentRect
                    isCalloutFragment = true
                }
            }
                
            else if isEndOfCallout
            {
                output.append( VTextFragment(
                    text: fragmentText,
                    rect:currentFragmentRect,
                    range: fragmentRange,
                    isCallout: isCalloutFragment,
                    isNewLine: isNewLine  )
                )
                isNewLine = false
                fragmentStartIndex = i
                currentFragmentRect = fragmentRect
                isCalloutFragment = false
            }
            
            currentFragmentRect.size.width = CGRectGetMaxX( fragmentRect ) - currentFragmentRect.origin.x
            
            if isLastCharacter
            {
                output.append( VTextFragment(
                    text: fragmentText,
                    rect:currentFragmentRect,
                    range: fragmentRange,
                    isCallout: isCalloutFragment,
                    isNewLine: isNewLine )
                )
            }
            
            lastFragmentRect = fragmentRect
        }
        
        return output
    }
    
    /**
    Extracts the `rect` values from each of the provided fragments, applies the offset, spacing and insets
    according to the VTextFragmentOffsets provided and returns those frames.
    */
    func rectsFromFragments( fragments: [VTextFragment], withOffsets offsets: VTextFragmentOffsets ) -> [CGRect]
    {
        var output = [CGRect]()
        
        for i in 0...fragments.count-1
        {
            var fragment: VTextFragment = fragments[i]
            var lastFragment: VTextFragment? = i > 0 ? fragments[i-1] : nil
            var nextFragment: VTextFragment? = i < fragments.count-1 ? fragments[i+1] : nil
            
            var offsetX1: CGFloat = offsets.horizontalSpacing
            var offsetX2: CGFloat = -offsets.horizontalSpacing*2
            
            // Adjust offet for callout spacing
            if fragment.isCallout && !fragment.isNewLine
            {
                offsetX1 -= offsets.horizontalOffset
                offsetX2 += offsets.horizontalOffset
            }
            if let next = nextFragment where next.isCallout && !next.isNewLine
            {
                offsetX2 -= offsets.horizontalOffset
            }
            
            // Adjust offset for new line spacing
            if fragment.isNewLine
            {
                offsetX1 -= offsets.horizontalOffset
                offsetX2 += offsets.horizontalOffset
            }
            if nextFragment == nil
            {
                offsetX2 += offsets.horizontalOffset
            }
            
            // Apply offsets and collect rects for output
            let original = fragment.rect
            output.append( CGRect(
                x: original.origin.x + offsetX1,
                y: original.origin.y + offsets.topInset,
                width: original.size.width + offsetX2,
                height: original.size.height - offsets.bottomInset
            ) )
            
            println( "\"\(fragment.text)\"" )
        }
        
        println( "------" )
        
        return output
    }
}
