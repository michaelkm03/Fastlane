//
//  VTextLayoutHelper.swift
//  victorious
//
//  Created by Patrick Lynch on 4/13/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

@objc class VTextPostBackgroundLayout: NSObject
{
    /**
    The main method that calculated the background frames required to meet the
    design of the text post test.
    
    @param textView A VTextPostTextView instances that provides the custom drawing
    routines necessary to render the background frames that will be calculated,
    as well as a destination for the modified text.
    @param calloutRanges An array of character ranges for words that will be separated
    or "called out" into individual background frames, separate from the background frame
    rendered for each line.
    */
    func updateTextViewBackground( textView: VTextPostTextView, calloutRangeObjects: NSArray )
    {
        let text: NSString = textView.attributedText.string
        if text.length == 0
        {
            return
        }
        
        textView.textContainer.size = CGSizeMake( textView.bounds.size.width, CGFloat.max )
        
        let calloutRanges: [NSRange] = self.calloutRangesFromObjectArray( calloutRangeObjects )
        
        let rectsDividedByWord = self.rectsDividedByWord( textView )
        let rectsWithSpacingApplied = self.rectsWithSpacingApplied( rectsDividedByWord )
        var backgroundFrames = rectsWithSpacingApplied
        
        textView.backgroundFrameColor = UIColor.whiteColor()
        textView.backgroundFrames = self.valueObjectsFromRects( backgroundFrames )
    }
    
    func rectsWithSpacingApplied( rects: [CGRect] ) -> [CGRect]
    {
        var output = [CGRect]()
        
        for original in rects
        {
            let rect = CGRect(
                x: original.origin.x - 6, // + 3,
                y: original.origin.y + 14,
                width: original.size.width + 12, //  - 6,
                height: original.size.height - 3
            )
            output.append( rect )
        }
        
        return output
    }
    
    func rectsDividedByWord( textView: UITextView ) -> [CGRect]
    {
        var output = [CGRect]()
        
        let text: NSString = textView.attributedText.string
        textView.textContainer.size = CGSizeMake( textView.bounds.size.width, CGFloat.max )
        
        var currentRect = CGRectZero
        var lastWordRect = CGRectZero
        var wasNewLine = false
        
        var selectedRangeLocation = 0
        for i in 0...text.length-1
        {
            let glyphRange = NSMakeRange( i, 1 )
            let selectedGlphyRange = NSMakeRange( selectedRangeLocation, text.length )
            textView.layoutManager.enumerateEnclosingRectsForGlyphRange( glyphRange,
                withinSelectedGlyphRange: selectedGlphyRange,
                inTextContainer: textView.textContainer)
                { ( wordRect, stop ) -> Void in
                    
                    let isNewLine = wordRect.origin.y > lastWordRect.origin.y
                    println( "\(wordRect.origin.y) < \(lastWordRect.origin.y) = \(isNewLine)" )
                    if isNewLine || CGRectEqualToRect( currentRect, CGRectZero )
                    {
                        currentRect = wordRect
                    }
                    
                    if wasNewLine
                    {
                        let lastCharRange = NSMakeRange( glyphRange.location-1, 1 )
                        let lastCharRect = textView.layoutManager.boundingRectForGlyphRange( lastCharRange,
                            inTextContainer: textView.textContainer
                        )
                        currentRect.origin.x = wordRect.origin.x - lastCharRect.size.width
                    }
                    
                    let isSpace = text.substringWithRange( glyphRange ) == " "
                    let isEnd = i == text.length-1
                    if isSpace
                    {
                        output.append( currentRect )
                        currentRect = wordRect
                    }
                    else
                    {
                        currentRect.size.width = CGRectGetMaxX( wordRect ) - currentRect.origin.x
                        if isEnd
                        {
                            output.append( currentRect )
                        }
                    }
                    
                    lastWordRect = wordRect
                    wasNewLine = isNewLine
            }
        }
        
        return output
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
}
