//
//  VTextPostTextView.m
//  victorious
//
//  Created by Patrick Lynch on 3/24/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VTextPostTextView.h"

#define DRAW_DEBUG_COLORS 0

@implementation VTextPostTextView

- (void)setBackgroundFrames:(NSArray *)backgroundFrames
{
    _backgroundFrames = backgroundFrames;
    
    [self setNeedsLayout];
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
#if DRAW_DEBUG_COLORS
    NSArray *debugColors = @[ [UIColor redColor], [UIColor yellowColor], [UIColor blueColor] ];
    NSUInteger i = 0;
#endif

    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect( context, rect );
    
    self.clipsToBounds = NO;
    
    for ( NSValue *value in self.backgroundFrames )
    {
        CGRect frame = [value CGRectValue];
        CGContextAddRect( context, frame );
#if DRAW_DEBUG_COLORS
        CGContextSetFillColorWithColor( context, ([(UIColor *)[debugColors objectAtIndex:i] colorWithAlphaComponent:0.5f]).CGColor );
        i = i+1 > debugColors.count-1 ? 0 : i+1;
#else
        CGContextSetFillColorWithColor( context, self.backgroundFrameColor.CGColor );
#endif
        CGContextFillRect( context, frame );
    }
}

- (CGRect)boundingRectForCharacterRange:(NSRange)range
{
    NSTextStorage *textStorage = [[NSTextStorage alloc] initWithAttributedString:self.attributedText];
    NSLayoutManager *layoutManager = [[NSLayoutManager alloc] init];
    [textStorage addLayoutManager:layoutManager];
    NSTextContainer *textContainer = [[NSTextContainer alloc] initWithSize:CGSizeMake(self.bounds.size.width, CGFLOAT_MAX)];
    textContainer.lineFragmentPadding = 0;
    textContainer.lineBreakMode = NSLineBreakByCharWrapping;
    [layoutManager addTextContainer:textContainer];
    
    NSRange glyphRange;
    [layoutManager characterRangeForGlyphRange:range actualGlyphRange:&glyphRange];
    return [layoutManager boundingRectForGlyphRange:glyphRange inTextContainer:textContainer];
}

@end
