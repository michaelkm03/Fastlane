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

struct VTextFragmentPair
{
    let left: VTextFragment?
    let right: VTextFragment?
    
    func applyOffset( amount: CGFloat )
    {
        //left?.rect.origin.x += amount
        //right?.rect.size.width -= amount
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
    Iterates through the text in the text view using properties of the text view's attribtued text,
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
            
            if isFirstCharacter
            {
                fragmentStartIndex = i
                currentFragmentRect = fragmentRect
            }
            
            if needsNewLine
            {
                if ( fragmentText != " " && !isSpace )
                {
                    output.append( VTextFragment(
                        text: fragmentText,
                        rect:currentFragmentRect, range: fragmentRange,
                        isCallout: calloutIndex >= 0,
                        isNewLine: isNewLine )
                    )
                }
                isNewLine = true
                fragmentStartIndex = i
                currentFragmentRect = fragmentRect
            }
            
            if calloutIndex >= 0 && lastCalloutIndex != calloutIndex && !isLastCharacter
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
            else if calloutIndex < 0 && lastCalloutIndex >= 0 && !isLastCharacter
            {
                output.append( VTextFragment(
                    text: fragmentText,
                    rect:currentFragmentRect,
                    range: fragmentRange,
                    isCallout: calloutIndex >= 0,
                    isNewLine: isNewLine  )
                )
                isNewLine = false
                fragmentStartIndex = i
                currentFragmentRect = fragmentRect
            }
            
            currentFragmentRect.size.width = CGRectGetMaxX( fragmentRect ) - currentFragmentRect.origin.x
            
            if isLastCharacter
            {
                output.append( VTextFragment(
                    text: fragmentText,
                    rect:currentFragmentRect,
                    range: fragmentRange,
                    isCallout: calloutIndex >= 0,
                    isNewLine: isNewLine )
                )
            }
            
            lastCalloutIndex = calloutIndex
            lastFragmentRect = fragmentRect
        }
        
        self.printFragments( output )
        
        return output
    }
    
    func applySpacingToFragments( fragments: [VTextFragment], withOffsets offsets: VTextFragmentOffsets )
    {
        var fragmentPairs = [VTextFragmentPair]()
        for var i = -1; i <= fragments.count; i += 2
        {
            fragmentPairs.append( VTextFragmentPair(
                left: i < fragments.count-1 ? fragments[i+1] : nil,
                right: i < fragments.count-1 ? fragments[i+1] : nil
            ) )
        }
        
        //self.printPairs( fragmentPairs )
        
        for fragment in fragments
        {
            // Apply offsets and collect rects for output
            let original = fragment.rect
            fragment.rect = CGRect(
                x: original.origin.x + offsets.horizontalSpacing,
                y: original.origin.y + offsets.topInset,
                width: original.size.width - offsets.horizontalSpacing*2,
                height: original.size.height - offsets.bottomInset
            )
        }
        
        for pair in fragmentPairs
        {
            pair.applyOffset( -20 )
        }
    }
    
    /**
    Extracts the `rect` values from each of the provided fragments, applies the offset, spacing and insets
    according to the VTextFragmentOffsets provided and returns those frames.
    */
    func rectsFromFragments( fragments: [VTextFragment] ) -> [CGRect]
    {
        var output = [CGRect]()
        for fragment in fragments
        {
            output.append( fragment.rect )
        }
        return output
    }
    
    // MARK: - Private helpers
    
    private func indexOfCalloutRangeContainingIndex( index: Int, calloutRanges: [NSRange] ) -> Int?
    {
        if calloutRanges.count == 0
        {
            return nil
        }
        for i in 0...calloutRanges.count-1
        {
            let range = calloutRanges[i]
            if index >= range.location && index < range.location + range.length
            {
                return i
            }
        }
        return nil
    }
    
    private func printFragments( fragments: [VTextFragment] )
    {
        for fragment in fragments
        {
            println( "\"\(fragment.text)\"" )
        }
        println( "------" )
    }
    
    private func printPairs( fragmentPairs: [VTextFragmentPair] )
    {
        for pair in fragmentPairs
        {
            println( "\(pair.left?.text) :: \(pair.left?.text)" )
        }
        println( "------" )
    }
}
