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
#import "VTextPostConfiguration.h"
#import "NSArray+VMap.h"

@interface VTextLayoutHelper()

@property (nonatomic, strong) IBOutlet VTextPostConfiguration *configuration;

@end

@implementation VTextLayoutHelper

- (void)addWordPaddingWithVaule:(NSInteger)wordPadding
             toAttributedString:(NSMutableAttributedString *)attributedString
                withCalloutRanges:(NSArray *)calloutRanges
{
    for ( NSValue *rangeValueObject in calloutRanges )
    {
        NSRange range = rangeValueObject.rangeValue;
        NSNumber *padding = @( wordPadding );
        [attributedString addAttribute:NSKernAttributeName value:padding range:NSMakeRange( range.location - 1, 1 )];
        [attributedString addAttribute:NSKernAttributeName value:padding range:NSMakeRange( range.location - 1 + range.length, 1 )];
    }
}

- (NSArray *)textLinesFromText:(NSString *)text
                withAttributes:(NSDictionary *)attributes
                      maxWidth:(CGFloat)maxWidth
{
    NSMutableArray *lines = [[NSMutableArray alloc] init];
    NSMutableArray *allWords = [NSMutableArray arrayWithArray:[text componentsSeparatedByString:@" "]];
    
    NSInteger maxIterations = allWords.count;
    for ( NSInteger i = 0; i < maxIterations && allWords.count > 0; i++ )
    {
        NSMutableString *currentLine = [[NSMutableString alloc] init];
        while ( [[currentLine stringByAppendingFormat:@" %@", allWords.firstObject] sizeWithAttributes:attributes].width < maxWidth )
        {
            [currentLine appendFormat:@" %@", allWords.firstObject];
            [allWords removeObjectAtIndex:0];
            if ( allWords.count == 0 )
            {
                break;
            }
        }
        [lines addObject:currentLine];
    }
    
    return [NSArray arrayWithArray:lines];
}

- (void)updateTextViewBackground:(VTextPostTextView *)textView
                   calloutRanges:(NSArray *)calloutRanges
{
    textView.backgroundFrameColor = self.configuration.backgroundColor;
    //textView.backgroundFrameColor = [self.configuration.backgroundColor colorWithAlphaComponent:0.5f];
    
    // Calculate the actual line count a bit differently, since the one above is not as accurate while typing
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
         [lineFragmentRects addObject:[NSValue valueWithCGRect:usedRect]];
     }];
    
    __block NSMutableArray *backgroundLineFrames = [[NSMutableArray alloc] init];
    NSUInteger numLines = totalRect.size.height / singleCharRect.size.height;
    for ( NSUInteger i = 0; i < numLines; i++ )
    {
        // Calculate individual rects for each line to draw in the background of text view
        CGRect lineRect = totalRect;
        lineRect.size.height = singleCharRect.size.height - self.configuration.verticalSpacing;
        lineRect.origin.y = singleCharRect.size.height * i + singleCharRect.size.height * self.configuration.lineOffsetMultiplier;
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
    
    const CGFloat spaceOffset = (self.configuration.calloutWordPadding + self.configuration.horizontalSpacing) * 0.5f;
    for ( NSValue *rangeValueObject in calloutRanges )
    {
        NSRange range = [rangeValueObject rangeValue];
        textView.textContainer.size = CGSizeMake( textView.bounds.size.width, CGFLOAT_MAX );
        CGRect rect = [textView.layoutManager boundingRectForGlyphRange:range inTextContainer:textView.textContainer];
        rect.origin.y += rect.size.height * self.configuration.lineOffsetMultiplier;
        rect.size.height = singleCharRect.size.height - self.configuration.verticalSpacing;
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
    const CGFloat space = self.configuration.horizontalSpacing;
    
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
