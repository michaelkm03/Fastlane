//
//  VTextFragment.swift
//  victorious
//
//  Created by Patrick Lynch on 4/29/15.
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