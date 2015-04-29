//
//  VTextCalloutFormatter.swift
//  victorious
//
//  Created by Patrick Lynch on 4/13/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

import UIKit

/**
Some helper methods for formatting callout text using NSAttributedStrings
*/
@objc class VTextCalloutFormatter: NSObject
{
    /**
    Applies attributes to mutable attributed string within the specified callout ranges
    */
    func applyAttributes( attributes: NSDictionary, toText attributedString: NSMutableAttributedString, inCalloutRanges calloutRanges: NSArray )
    {
        for rangeObject in calloutRanges
        {
            let range: NSRange = rangeObject.rangeValue
            attributedString.addAttributes( attributes as [NSObject : AnyObject], range: range )
            let calloutLinkValue = (attributedString.string as NSString).substringWithRange( range )
            attributedString.addAttribute( CCHLinkAttributeName, value: calloutLinkValue, range: range )
        }
    }
    
    /**
    Adds specified kerning to the last character and character before the fist character of each of the provided ranges
    */
    func setKerning( kerning: CGFloat, toText attributedString: NSMutableAttributedString, withCalloutRanges calloutRanges: NSArray )
    {
        for rangeObject in calloutRanges
        {
            let range: NSRange = rangeObject.rangeValue
            if range.location > 0
            {
                let firstCharacterRange = NSMakeRange( range.location - 1, 1 )
                attributedString.addAttribute( NSKernAttributeName, value: kerning, range: firstCharacterRange )
            }
            if ( range.location + range.length < attributedString.length )
            {
                let lastCharacterRange = NSMakeRange( range.location - 1 + range.length, 1 )
                attributedString.addAttribute( NSKernAttributeName, value: kerning, range: lastCharacterRange )
            }
        }
    }
}
