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
 Divides a text string into lines using all of its size properties when
 styled with the provided attributes that fits within the provided maximum width.
 
 @return An array of strings each of which represents one line of text when
 rendered according to the supplied parameters.
 */
- (NSArray *)textLinesFromText:(NSString *)text
                withAttributes:(NSDictionary *)attributes
                      maxWidth:(CGFloat)maxWidth;

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
- (void)updateTextViewBackground:(VTextPostTextView *)textView
                   calloutRanges:(NSArray *)calloutRanges;

/**
 Text with callout ranges will have background frames that are rendered separately
 from the background frame of the full text of the line in which it exists.  This method
 adjusts the kerning in the text attributes to provide enough space between callout and
 non-callout words to match the design.
 */
- (void)addWordPaddingWithVaule:(NSInteger)wordPadding
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
