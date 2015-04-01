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

- (void)addWordPaddingWithVaule:(NSInteger)wordPadding
             toAttributedString:(NSMutableAttributedString *)attributedString
                withCalloutRanges:(NSArray *)calloutRanges
{
    //NSRange previousRange = NSMakeRange( 0, 0 );
    for ( NSValue *rangeValueObject in calloutRanges )
    {
        NSRange range = rangeValueObject.rangeValue;
        if ( range.location > 0 )  //< Exclude first word
        {
            NSRange startRange = NSMakeRange( range.location - 1, 1 );
            CGFloat padding = wordPadding;
            /*if ( previousRange.length > 0 ) //< If we have a value form the last loop
            {
                NSInteger numberOfSpacesFromLastCallout = range.location - (previousRange.location + previousRange.length);
                if ( numberOfSpacesFromLastCallout == 0 )
                {
                    padding = wordPadding * 2.0;
                }
            }*/
            [attributedString addAttribute:NSKernAttributeName value:@(padding) range:startRange];
        }
        NSRange endRange = NSMakeRange( range.location - 1 + range.length, 1 );
        [attributedString addAttribute:NSKernAttributeName value:@(wordPadding) range:endRange];
        
        //previousRange = range;
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
    [textView.layoutManager enumerateLineFragmentsForGlyphRange:fullRange usingBlock:^( CGRect rect,
                                                                                       CGRect usedRect,
                                                                                       NSTextContainer *textContainer,
                                                                                       NSRange glyphRange, BOOL *stop )
     {
         CGRect lineRect = [self lineRectFromLineRect:usedRect adjustedForSpacesAtEndofTextView:textView withGlyphRange:glyphRange];
         [lineFragmentRects addObject:[NSValue valueWithCGRect:lineRect]];
     }];
    
    if ( didAddSpaceCharacterToEmptyTextView )
    {
        textView.text = @"";
    }
    
    __block NSMutableArray *backgroundLineFrames = [[NSMutableArray alloc] init];
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
    
    NSMutableArray *calloutRects = [[NSMutableArray alloc] initWithCapacity:numLines];
    for ( NSUInteger i = 0; i < numLines; i++ )
    {
        [calloutRects addObject:[[NSMutableArray alloc] init]];
    }
    
    const CGFloat spaceOffset = (self.viewModel.calloutWordPadding + self.viewModel.horizontalSpacing) * 0.5f;
    for ( NSValue *rangeValueObject in calloutRanges )
    {
        NSRange range = [rangeValueObject rangeValue];
        textView.textContainer.size = CGSizeMake( textView.bounds.size.width, CGFLOAT_MAX );
        CGRect rect = [textView.layoutManager boundingRectForGlyphRange:range inTextContainer:textView.textContainer];
        rect.origin.y += rect.size.height * self.viewModel.lineOffsetMultiplier;
        rect.size.height = singleCharRect.size.height - self.viewModel.verticalSpacing;
        rect.origin.x -= spaceOffset;
        rect.size.width += spaceOffset;
        
        NSUInteger lineNumber = CGRectGetMinY(rect) / totalRect.size.height * numLines;
       [[calloutRects objectAtIndex:lineNumber] addObject:[NSValue valueWithCGRect:rect]];
    }
    
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
