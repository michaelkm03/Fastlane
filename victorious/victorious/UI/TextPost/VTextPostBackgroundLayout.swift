//
//  VTextLayoutHelper.swift
//  victorious
//
//  Created by Patrick Lynch on 4/13/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

struct VTextFragment
{
    let text: String
    let rect: CGRect
    let range: NSRange
    let isCallout: Bool
    let isNewLine: Bool
}

@objc class VTextPostBackgroundLayout: NSObject
{
    /**
    The main method that calculated the background frames required to meet the
    design of the text post test.
    
    @param textView A VTextPostTextView instances that provides the custom drawing
    routines necessary to render the background frames that will be calculated,
    as well as a destination for the modified text.
    @param calloutRanges An array of character ranges for fragments that will be separated
    or "called out" into individual background frames, separate from the background frame
    rendered for each line.
    */
    func updateTextViewBackground( textView: VTextPostTextView, calloutRangeObjects: NSArray )
    {
        let calloutRanges: [NSRange] = self.calloutRangesFromObjectArray( calloutRangeObjects )
        
        textView.textContainer.size = CGSizeMake( textView.bounds.size.width, CGFloat.max )
        
        var fragments = self.fragmentsInTextView( textView, calloutDelimeters: ["#"] )
        let backgroundFrames = self.rectsFromFragments( fragments )
        
        textView.backgroundFrameColor = UIColor.whiteColor()
        textView.backgroundFrames = self.valueObjectsFromRects( backgroundFrames )
    }
    
    func valueObjectsFromRects( rects: [CGRect] ) -> [NSValue]
    {
        var valueObjects = [NSValue]()
        for rect in rects
        {
            valueObjects.append( NSValue( CGRect: rect ) )
        }
        return valueObjects
    }
    
    func calloutRangesFromObjectArray( objectArray: NSArray ) -> [NSRange]
    {
        var ranges = [NSRange]()
        for valueObject in objectArray
        {
            ranges.append( valueObject.rangeValue )
        }
        return ranges
    }
    
    func rectsFromFragments( fragments: [VTextFragment] ) -> [CGRect]
    {
        var output = [CGRect]()
        
        let offsetSpace: CGFloat = 6.0
        let rectSpace: CGFloat = 1.0
        
        for i in 0...fragments.count-1
        {
            var fragment: VTextFragment = fragments[i]
            var lastFragment: VTextFragment? = i > 0 ? fragments[i-1] : nil
            var nextFragment: VTextFragment? = i < fragments.count-1 ? fragments[i+1] : nil
            
            var offsetX1: CGFloat = rectSpace
            var offsetX2: CGFloat = -rectSpace*2
            
            // Callout spacing
            if fragment.isCallout && !fragment.isNewLine && lastFragment != nil
            {
                offsetX1 -= offsetSpace
                offsetX2 += offsetSpace
            }
            if let next = nextFragment where next.isCallout && !next.isNewLine
            {
                offsetX2 -= offsetSpace
            }
            
            // New line spacing
            if fragment.isNewLine
            {
                offsetX1 -= offsetSpace
                offsetX2 += offsetSpace
            }
            if nextFragment == nil
            {
                offsetX2 += offsetSpace
            }
            
            let original = fragment.rect
            output.append( CGRect(
                x: original.origin.x + offsetX1,
                y: original.origin.y + 14, // + CGFloat( arc4random() % 6 ),
                width: original.size.width + offsetX2,
                height: original.size.height - 3
            ) )
            lastFragment = fragment
            
            println( "\"\(fragment.text)\" (\(fragment.isCallout), \(fragment.isNewLine))" )
        }
        println( "===" )
        return output
    }
    
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
            let fragmentRange = NSMakeRange( fragmentStartIndex, i - fragmentStartIndex )
            let fragmentText = text.substringWithRange( fragmentRange )
            let isCalloutDelimeter = contains( calloutDelimeters, currentCharacter )
            let isSpace = currentCharacter == " "
            let needsNewLine = i > 0 && fragmentRect.origin.y > lastFragmentRect.origin.y
            let isEndOfCallout = isSpace && isCalloutFragment
            let isLastCharacter = i == text.length-1
            let isFirstCharacter = i == 0
            let isMinCalloutLength = i < text.length-2
            
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
            else if isCalloutDelimeter && isMinCalloutLength
            {
                if count(fragmentText) > 0
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
}
