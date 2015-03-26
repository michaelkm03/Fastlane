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
#import "VTextPostConfiguration.h"f dsa

@implementation VTextLayoutHelper

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

- (void)updateTextViewBackground:(VTextPostTextView *)textView configuraiton:(VTextPostConfiguration *)configuration
{
    textView.backgroundFrameColor = configuration.backgroundColor;
    
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
    
    // Calculate the actual line count a bit differently, since the one above is not as accurate while typing
    CGRect singleCharRect = [textView boundingRectForCharacterRange:NSMakeRange( 0, 1 )];
    CGRect totalRect = [textView boundingRectForCharacterRange:NSMakeRange( 0, textView.attributedText.string.length)];
    totalRect.size = [textView sizeThatFits:CGSizeMake( textView.bounds.size.width, CGFLOAT_MAX )];
    totalRect.size.width = textView.bounds.size.width;
    
    __block NSMutableArray *backgroundFrames = [[NSMutableArray alloc] init];
    NSInteger numLines = totalRect.size.height / singleCharRect.size.height;
    for ( NSInteger i = 0; i < numLines; i++ )
    {
        // Calculate individual rects for each line to draw in the background of text view
        CGRect lineRect = totalRect;
        lineRect.size.height = singleCharRect.size.height - configuration.verticalSpacing;
        lineRect.origin.y = singleCharRect.size.height * i + singleCharRect.size.height * configuration.lineOffsetMultiplier;
        //if ( i == numLines - 1 )
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
        [backgroundFrames addObject:[NSValue valueWithCGRect:lineRect]];
    }
    
    textView.backgroundFrames = [NSArray arrayWithArray:backgroundFrames];
}

@end
