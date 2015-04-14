//
//  VTextLayoutHelper.swift
//  victorious
//
//  Created by Patrick Lynch on 4/13/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

struct VWord
{
    var text: String
    var rect: CGRect
    
    var isCallout: Bool
    {
        return count(self.text) > 0 && (self.text as NSString).substringWithRange(NSMakeRange( 0, 1 )) == "#"
    }
}

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
        let calloutRanges: [NSRange] = self.calloutRangesFromObjectArray( calloutRangeObjects )
        
        textView.textContainer.size = CGSizeMake( textView.bounds.size.width, CGFloat.max )
        
        var words = self.wordsInTextView( textView )
        let backgroundFrames = self.rectsFromWords( words )
        
        textView.backgroundFrameColor = UIColor.whiteColor()
        textView.backgroundFrames = self.valueObjectsFromRects( backgroundFrames )
    }
    
    func rectsFromWords( words: [VWord] ) -> [CGRect]
    {
        var output = [CGRect]()
        for word in words
        {
            println( word.text )
            let calloutSpace: CGFloat = word.isCallout ? 15 : 0
            let original = word.rect
            output.append( CGRect(
                x: original.origin.x - 6 + calloutSpace,
                y: original.origin.y + 14,
                width: original.size.width + 12 - calloutSpace * 2,
                height: original.size.height - 3
            ) )
        }
        return output
    }
    
    func wordsInTextView( textView: UITextView ) -> [VWord]
    {
        var output = [VWord]()
        
        let text: NSString = count(textView.attributedText.string) == 0 ? " " : textView.attributedText.string
        textView.textContainer.size = CGSizeMake( textView.bounds.size.width, CGFloat.max )
        
        var currentRect = CGRectZero
        var lastWordRect = CGRectZero
        var wasSpace = false
        
        var selectedRangeLocation = 0
        var wordStartIndex = 0
        for i in 0...text.length-1
        {
            let glyphRange = NSMakeRange( i, 1 )
            let wordRect = textView.layoutManager.boundingRectForGlyphRange( glyphRange, inTextContainer: textView.textContainer )
            
            if (wasSpace && i > 0) || CGRectEqualToRect( currentRect, CGRectZero )
            {
                wordStartIndex = i
                currentRect = wordRect
            }
            
            let currentCharacter = text.substringWithRange( glyphRange )
            
            let isCallout = currentCharacter == "#" // pass in character
            
            let isNewLine = wordRect.origin.y > lastWordRect.origin.y
            if isNewLine || isCallout
            {
                let wordText = text.substringWithRange( NSMakeRange( wordStartIndex, i - wordStartIndex ) )
                output.append( VWord( text: wordText, rect:currentRect  ) )
                wordStartIndex = i
                currentRect = wordRect
            }
            
            let isSpace = currentCharacter == " "
            if isSpace && text.length > 0
            {
                let wordText = text.substringWithRange( NSMakeRange( wordStartIndex, i - wordStartIndex ) )
                output.append( VWord( text: wordText, rect:currentRect  ) )
            }
            else
            {
                currentRect.size.width = CGRectGetMaxX( wordRect ) - currentRect.origin.x
                
                let isEnd = i == text.length-1
                if isEnd
                {
                    let wordText = text.substringWithRange( NSMakeRange( wordStartIndex, i - wordStartIndex ) )
                    output.append( VWord( text: wordText, rect:currentRect  ) )
                }
            }
            
            lastWordRect = wordRect
            wasSpace = isSpace
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
    
    // TODO: Remove this if not used
    func stringByAddingSurroundingSpacesToCallouts( text: NSString, calloutRangeObjects: NSArray ) -> NSString
    {
        let calloutRanges: [NSRange] = self.calloutRangesFromObjectArray( calloutRangeObjects )
        var output = NSMutableString(string: text)
        
        for range in calloutRanges
        {
            if range.location > 0
            {
                let startRange = NSMakeRange( range.location-1, 1 )
                let characterBeforeCallout = output.substringWithRange( startRange )
                if characterBeforeCallout != " "
                {
                    output.replaceCharactersInRange( startRange, withString: " \(characterBeforeCallout)" )
                }
            }
        }
        return NSString(string: output) as String
    }
}
