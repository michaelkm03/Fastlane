//
//  VTextPostTextView.m
//  victorious
//
//  Created by Patrick Lynch on 3/24/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VTextPostTextView.h"

@implementation VTextPostTextView

- (void)setBackgroundFrames:(NSArray *)backgroundFrames
{
    _backgroundFrames = backgroundFrames;
    
    [self setNeedsLayout];
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextClearRect( context, rect );
    
    self.clipsToBounds = NO;
    
    for ( NSValue *value in self.backgroundFrames )
    {
        CGRect frame = [value CGRectValue];
        if ( self.textAlignment == NSTextAlignmentCenter )
        {
            frame.origin.x = (CGRectGetWidth(self.frame) - CGRectGetWidth(frame)) * 0.5f;
        }
        CGContextAddRect( context, frame );
        CGContextSetFillColorWithColor( context, self.backgroundFrameColor.CGColor );
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
