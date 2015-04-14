//
//  VTextLayoutHelper.m
//  victorious
//
//  Created by Patrick Lynch on 3/11/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VTextLayoutHelper.h"
#import "VDependencyManager.h"
#import "VTextPostTextView.h"
#import "VTextPostViewModel.h"
#import "NSArray+VMap.h"

@interface VTextLayoutHelper()

@property (nonatomic, strong) IBOutlet VTextPostViewModel *viewModel;

@end

@implementation VTextLayoutHelper

- (void)setAdditionalKerningWithVaule:(CGFloat)additionalKerning
                   toAttributedString:(NSMutableAttributedString *)attributedString
                    withCalloutRanges:(NSArray *)calloutRanges
{
    for ( NSValue *rangeValueObject in calloutRanges )
    {
        NSRange range = rangeValueObject.rangeValue;
        if ( range.location > 0 )  //< Exclude first word
        {
            NSRange startRange = NSMakeRange( range.location - 1, 1 );
            CGFloat padding = additionalKerning;
            [attributedString addAttribute:NSKernAttributeName value:@(padding) range:startRange];
        }
        NSRange endRange = NSMakeRange( range.location - 1 + range.length, 1 );
        if ( endRange.location + endRange.length < attributedString.length )
        {
            [attributedString addAttribute:NSKernAttributeName value:@(additionalKerning) range:endRange];
        }
    }
}

- (NSString *)stringByRemovingEmptySpacesInText:(NSString *)text betweenCalloutRanges:(NSArray *)calloutRanges
{
    if ( calloutRanges.count == 0 || text.length == 0 )
    {
        return text;
    }
    
    NSMutableArray *rangesToReplace = [[NSMutableArray alloc] init];
    
    for ( NSUInteger i = 0; i < calloutRanges.count-1; i++ )
    {
        NSRange currentRange = ((NSValue *)[calloutRanges objectAtIndex:i]).rangeValue;
        NSRange nextRange = ((NSValue *)[calloutRanges objectAtIndex:i+1]).rangeValue;
        NSRange spaceRange = NSMakeRange( currentRange.location + currentRange.length, nextRange.location - (currentRange.location + currentRange.length) );
        NSString *textBetweenCallotus = [text substringWithRange:spaceRange];
        if ( [textBetweenCallotus isEqualToString:@" "] )
        {
            [rangesToReplace addObject:[NSValue valueWithRange:spaceRange]];
        }
    }
    
    NSMutableString *output = [text mutableCopy];
    int offset = 0;
    for ( NSUInteger i = 0; i < rangesToReplace.count - offset; i++ )
    {
        NSUInteger offsetIndex = i - offset;
        NSRange spaceRange = ((NSValue *)[rangesToReplace objectAtIndex:offsetIndex]).rangeValue;
        [output replaceCharactersInRange:spaceRange withString:@""];
        offset += spaceRange.length;
    }
    
    return output;
}

- (CGRect)lineRectFromLineRect:(CGRect)lineRect adjustedForSpacesAtEndofTextView:(VTextPostTextView *)textView withGlyphRange:(NSRange)glyphRange
{
    CGRect output = lineRect;
    if ( glyphRange.location + glyphRange.length <= textView.text.length )
    {
        NSString *lineText = [textView.text substringWithRange:glyphRange];
        NSRange lastCharacterInLineRange = NSMakeRange( lineText.length-1, 1 );
        while ( [[lineText substringWithRange:lastCharacterInLineRange] isEqualToString:@" "] )
        {
            NSRange lastCharacterGlobalRange = NSMakeRange( glyphRange.location + lastCharacterInLineRange.location, 1 );
            CGRect lastCharacterRect = [textView boundingRectForCharacterRange:lastCharacterGlobalRange];
            output.size.width -= lastCharacterRect.size.width;
            if ( lastCharacterInLineRange.location == 0 )
            {
                break;
            }
            lastCharacterInLineRange.location -= 1;
        }
    }
    return output;
}

- (void)updateTextViewBackground:(VTextPostTextView *)textView
                   calloutRanges:(NSArray *)calloutRanges
{
    textView.backgroundFrameColor = self.viewModel.backgroundColor;
    
    // When the text is actually empty, we will need to draw a background frame of a certain size
    // to prevent having no background frame or undefined background frame behavior caused by using
    // a text rectangle with 0 width.  So, if we have empty text, we'll just work with a single space
    BOOL didAddSpaceCharacterToEmptyTextView = NO;
    if ( textView.text.length == 0 )
    {
        textView.text = @" ";
        didAddSpaceCharacterToEmptyTextView = YES;
    }
    
    // Calculate the actual line count
    CGRect singleCharRect = [textView boundingRectForCharacterRange:NSMakeRange( 0, 1 )];
    CGRect totalRect = [textView boundingRectForCharacterRange:NSMakeRange( 0, textView.attributedText.string.length)];
    totalRect.size = [textView sizeThatFits:CGSizeMake( textView.bounds.size.width, CGFLOAT_MAX )];
    totalRect.size.width = textView.bounds.size.width;
    
    // Use this function of text storange to get the usedRect of each line fragment
    NSRange fullRange = NSMakeRange( 0, textView.attributedText.string.length );
    __block NSMutableArray *lineFragmentRects = [[NSMutableArray alloc] init];
    __block NSMutableArray *lineFragmentGlyphRanges = [[NSMutableArray alloc] init];
    [textView.layoutManager enumerateLineFragmentsForGlyphRange:fullRange usingBlock:^( CGRect rect,
                                                                                       CGRect usedRect,
                                                                                       NSTextContainer *textContainer,
                                                                                       NSRange glyphRange, BOOL *stop )
     {
         CGRect lineRect = [self lineRectFromLineRect:usedRect adjustedForSpacesAtEndofTextView:textView withGlyphRange:glyphRange];
         [lineFragmentRects addObject:[NSValue valueWithCGRect:lineRect]];
         [lineFragmentGlyphRanges addObject:[NSValue valueWithRange:glyphRange]];
     }];
    
    // If started with empty text and had to add a space character, we should now revert back to
    // empty text.  The calculations before this point depending on a non-zero width of text,
    // but going forward we can and should handle the zero width.
    if ( didAddSpaceCharacterToEmptyTextView )
    {
        textView.text = @"";
    }
    
    // We're going to create an array of rectangles, each of which is sized to encompass a
    // line of text.  We'll store that in `backgroundLinesFrames`.
    __block NSMutableArray *backgroundLineFrames = [[NSMutableArray alloc] init];
    textView.textContainer.size = CGSizeMake( textView.bounds.size.width, CGFLOAT_MAX );
    NSUInteger numLines = totalRect.size.height / singleCharRect.size.height;
    for ( NSUInteger i = 0; i < numLines; i++ )
    {
        // Calculate individual rects for each line to draw in the background of text view
        CGRect lineRect = totalRect;
        lineRect.size.height = singleCharRect.size.height - self.viewModel.verticalSpacing;
        lineRect.origin.y = singleCharRect.size.height * i + singleCharRect.size.height * self.viewModel.lineOffsetMultiplier;
        if ( i < lineFragmentRects.count )
        {
            // If this is the last line, use the line fragment rects collected above
            lineRect.size.width = ((NSValue *)lineFragmentRects[i]).CGRectValue.size.width;
            if ( lineRect.size.width == 0 )
            {
                //NSRange lineRange = ((NSValue *)lineFragmentGlyphRanges[i]).rangeValue;
                //CGRect rect = [textView.layoutManager boundingRectForGlyphRange:lineRange inTextContainer:textView.textContainer];
                //lineRect.size.width = rect.size.width;
                
                // Sometimes the line fragment rect will give is 0 width for a singel word overhanging on the next line
                // So, we'll take that last word and calcualte its width to get a proper value for the line's background rect
                NSString *lastWord = [textView.attributedText.string componentsSeparatedByString:@" "].lastObject;
                NSRange lastWordRange = [textView.attributedText.string rangeOfString:lastWord];
                CGRect lastWordBoundingRect = [textView boundingRectForCharacterRange:lastWordRange];
                lineRect.size.width = lastWordBoundingRect.size.width + lastWordBoundingRect.size.height * 0.3;
            }
        }
        if ( textView.textAlignment == NSTextAlignmentCenter )
        {
            lineRect.origin.x = (CGRectGetWidth(textView.frame) - CGRectGetWidth(lineRect)) * 0.5f;
        }
        [backgroundLineFrames addObject:[NSValue valueWithCGRect:lineRect]];
    }
    
    // Creates a mutable array that contains another mutable array for each line.
    // Each of these subarrays will contains callout rectangles for the callouts on that line.
    NSMutableArray *calloutRects = [[NSMutableArray alloc] initWithCapacity:numLines];
    for ( NSUInteger i = 0; i < numLines; i++ )
    {
        [calloutRects addObject:[[NSMutableArray alloc] init]];
    }
    
    // Now we'll process each callout, apply some special calculations for formatting and
    // mixing into with the background line frames.  See comments within the following loop
    // for more information on how this is being done
    const CGFloat spaceOffset = (self.viewModel.calloutWordKerning + self.viewModel.horizontalSpacing) * 0.5f;
    for ( NSUInteger i = 0; i < calloutRanges.count; i++ )
    {
        NSValue *rangeValueObject = calloutRanges[i];
        NSRange range = [rangeValueObject rangeValue];
        
        // Callout ranges can span onto multiple lines, which generate callout rectangles that are
        // too large, and whose min and max X values no longer line up with the beginning and ends of the actual text.
        // So, we'll need to detect any callout ranges that will span onto multiple lines and break them apart
        // into as many subranges distributed across those multiple lines
        NSMutableArray *calloutLineRanges = [[NSMutableArray alloc] init];
        NSRange currentLineRange = NSMakeRange( range.location, 1 );
        NSRange totalRange = NSMakeRange( range.location, 1 );
        NSUInteger currentCalloutLine = 1;
        const NSUInteger len = range.location + range.length;
        for ( NSUInteger r = range.location; r < len; r++ )
        {
            CGRect calloutRect = [textView.layoutManager boundingRectForGlyphRange:totalRange inTextContainer:textView.textContainer];
            NSUInteger lineOfCurrentSingleCharacter = ceil( calloutRect.size.height / singleCharRect.size.height );
            
            // If the `calloutRect` extends onto a new line, we'll add the current subrange and
            // continue iterating to build another subrange starting on the new line
            if ( lineOfCurrentSingleCharacter > currentCalloutLine )
            {
                [calloutLineRanges addObject:[NSValue valueWithRange:NSMakeRange( currentLineRange.location, currentLineRange.length-1)]];
                currentLineRange = NSMakeRange( r, 1 );
                currentCalloutLine = lineOfCurrentSingleCharacter;
            }
            
            // If we've reach the end of the loop before hitting a new line, add the current
            // subrange that we've been build since the last line
            if ( r == len-1 )
            {
                [calloutLineRanges addObject:[NSValue valueWithRange:currentLineRange]];
            }
            
            // Keep expanding the total range and current line range on each loop
            // moving forward character by character to detect an additionally required line
            totalRange.length++;
            currentLineRange.length++;
        }
        
        // Now we can calculate the callout rectangles and apply some edits to their
        // dimensions to be sized and spaces as we expect for the design
        for ( NSValue *value in calloutLineRanges )
        {
            NSRange calloutRange = value.rangeValue;
            CGRect rect = [textView.layoutManager boundingRectForGlyphRange:calloutRange inTextContainer:textView.textContainer];
            rect.origin.y += singleCharRect.size.height * self.viewModel.lineOffsetMultiplier;
            rect.size.height = singleCharRect.size.height - self.viewModel.verticalSpacing;
            rect.origin.x -= spaceOffset;
            rect.size.width += spaceOffset;
            
            NSUInteger lineNumber = CGRectGetMinY(rect) / totalRect.size.height * numLines;
            [[calloutRects objectAtIndex:lineNumber] addObject:[NSValue valueWithCGRect:rect]];
        }
    }
    
    // Now we have `backgroundLineFrames`, each element of which contains a frame that encompasses the text of each line,
    // as well as `calloutRects`, each element of which is an array that contains callouts for each line.
    // Using `separatedRectsFromRect:withCalloutRects`, we shall divide the background frame into
    // smaller rectangles that fill the gaps between the callout rectangles, giving us the effect required to match the intended design.
    NSMutableArray *allFrames = [[NSMutableArray alloc] init];
    for ( NSUInteger i = 0; i < backgroundLineFrames.count; i++ )
    {
        CGRect backgroundFrame = ((NSValue *)backgroundLineFrames[i]).CGRectValue;
        NSArray *calloutsForLine = calloutRects[i];
        NSArray *lineRects = [self separatedRectsFromRect:backgroundFrame withCalloutRects:calloutsForLine];
        [allFrames addObjectsFromArray:lineRects];
    }
    
    textView.backgroundFrames = [NSArray arrayWithArray:allFrames];
}

- (NSArray *)separatedRectsFromRect:(CGRect)sourceRect withCalloutRects:(NSArray *)calloutRects
{
    const CGFloat space = self.viewModel.horizontalSpacing;
    
    if ( calloutRects.count == 0 )
    {
        return @[ [NSValue valueWithCGRect:sourceRect] ];
    }
    
    CGRect currentSourceRect = sourceRect;
    NSMutableArray *rects = [[NSMutableArray alloc] init];
    for ( NSValue *value in calloutRects )
    {
        CGRect calloutRect = [value CGRectValue];
        
        CGRect leftSlice;
        CGRect middleRemainder;
        CGFloat amount = CGRectGetMinX(calloutRect) - CGRectGetMinX(currentSourceRect);
        CGRectDivide( currentSourceRect, &leftSlice, &middleRemainder, amount, CGRectMinXEdge );
        [rects addObject:[NSValue valueWithCGRect:leftSlice]];
        
        CGRect middleSlice;
        CGRect rightSlice;
        amount = CGRectGetMaxX(calloutRect) - CGRectGetMinX(middleRemainder);
        CGRectDivide( middleRemainder, &middleSlice, &rightSlice, amount, CGRectMinXEdge );
        [rects addObject:[NSValue valueWithCGRect:middleSlice]];
        
        currentSourceRect = rightSlice;
    }
    [rects addObject:[NSValue valueWithCGRect:currentSourceRect]];
    
    // Filter out any small fragment rects that couldn't contain even a character,
    // which ussually occur when a callout was the last word on the line
    const CGFloat cleanupMargin = 10;
    NSPredicate *filterPredicate = [NSPredicate predicateWithBlock:^BOOL(NSValue *rectValue, NSDictionary *bindings)
                                    {
                                        CGRect rect = rectValue.CGRectValue;
                                        return CGRectGetWidth(rect) > cleanupMargin;
                                    }];
    NSArray *output = [rects filteredArrayUsingPredicate:filterPredicate];
    
    // Add spacing in between slices
    __block NSUInteger i = 0;
    return [output v_map:^NSValue *(NSValue *value)
            {
                CGRect rect = value.CGRectValue;
                if ( i > 0 )
                {
                    rect.origin.x += space * 0.5f;
                }
                if ( i < rects.count )
                {
                    rect.size.width -= space;
                }
                
                i++;
                
                return [NSValue valueWithCGRect:rect];
            }];
}

@end
