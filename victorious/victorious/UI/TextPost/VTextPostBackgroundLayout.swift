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
        var backgroundFrames = [CGRect]()
        
        var currentRect = CGRectZero
        var lastWordRect = CGRectZero
        
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
                    if isNewLine || CGRectEqualToRect( currentRect, CGRectZero )
                    {
                        currentRect = wordRect
                    }
                    
                    let isSpace = text.substringWithRange( glyphRange ) == " "
                    let isEnd = i == text.length-1
                    if isSpace
                    {
                        backgroundFrames.append( currentRect )
                        currentRect = wordRect
                    }
                    else
                    {
                        currentRect.size.width = CGRectGetMaxX( wordRect ) - currentRect.origin.x
                        if isEnd
                        {
                            backgroundFrames.append( currentRect )
                        }
                    }
                    
                    lastWordRect = wordRect
            }
        }
        
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
}
