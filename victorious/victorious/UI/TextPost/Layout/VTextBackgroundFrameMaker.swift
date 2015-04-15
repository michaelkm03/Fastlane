//
//  VTextBackgroundFrameMaker.swift
//  victorious
//
//  Created by Patrick Lynch on 4/13/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

/**
Generates background rectangles to be rendered behind a text view to provide an enclosed or "label maker" effect.
Text within the specified callout ranges is given a special treatment that provides separate background frames
that are broken apart or "called out" from the main rectangle of the surrounding line of text.
*/
@objc class VTextBackgroundFrameMaker: NSObject
{
    let fragmentsBuilder = VTextFragmentsBuilder()
    
    /**
    Creates an array of background frames as CGRects for using properies of the provided text view.
    This will not automatically set the background frames to be renered.  That is the reponsibility
    of calling code.
    */
    func createBackgroundFramesForTextView( textView: UITextView, calloutRangeObjects: NSArray ) -> NSArray
    {
        let calloutRanges: [NSRange] = self.calloutRangesFromObjectArray( calloutRangeObjects )
        
        textView.textContainer.size = CGSizeMake( textView.bounds.size.width, CGFloat.max )
        
        var fragments = self.fragmentsBuilder.fragmentsInTextView( textView, calloutRanges: calloutRanges )
        let offsets = VTextFragmentOffsets(horizontalOffset: 6.0, horizontalSpacing: 1.0, topInset: 14.0, bottomInset: 3.0 )
        self.fragmentsBuilder.applySpacingToFragments( fragments, withOffsets: offsets )
        let backgroundFrames = self.fragmentsBuilder.rectsFromFragments( fragments )
        
        return self.valueFromRects( backgroundFrames ) as NSArray
    }
    
    // MARK: - NSArray to Swift array convertions
    
    private func valueFromRects( rects: [CGRect] ) -> [NSValue]
    {
        var valueObjects = [NSValue]()
        for rect in rects
        {
            valueObjects.append( NSValue( CGRect: rect ) )
        }
        return valueObjects
    }
    
    private func calloutRangesFromObjectArray( objectArray: NSArray ) -> [NSRange]
    {
        var ranges = [NSRange]()
        for valueObject in objectArray
        {
            ranges.append( valueObject.rangeValue )
        }
        return ranges
    }
   
}
