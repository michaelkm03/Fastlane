//
//  VTextLayoutHelper.h
//  victorious
//
//  Created by Patrick Lynch on 3/11/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VDependencyManager, VTextPostViewModel, VTextPostTextView;

/**
 A helper class for rendering text posts according to their customized style.
 The bulk of the work of drawing the custom background frames and separating
 individual "callout" frames (e.g. for hashtags and user tags) is done here.
 */
@interface VTextLayoutHelper : NSObject

/**
 Text with callout ranges will have background frames that are rendered separately
 from the background frame of the full text of the line in which it exists.  This method
 adjusts the kerning in the text attributes to provide enough space between callout and
 non-callout words to match the design.
 */
- (void)setAdditionalKerningWithVaule:(CGFloat)additionalKerning
                   toAttributedString:(NSMutableAttributedString *)attributedString
                    withCalloutRanges:(NSArray *)calloutRanges;

/**
 Checks a string for single sapces between two strings that will be rendered as callouts
 and removes that space so that an empty background frame will not be drawn between them.
 This is an edge case required to meet the intended design.
 */
- (NSString *)stringByRemovingEmptySpacesInText:(NSString *)text
                           betweenCalloutRanges:(NSArray *)calloutRanges;

@end
