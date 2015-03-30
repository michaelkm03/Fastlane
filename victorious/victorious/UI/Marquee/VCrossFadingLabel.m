//
//  VCrossFadingLabel.m
//  victorious
//
//  Created by Sharif Ahmed on 3/28/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VCrossFadingLabel.h"

@interface VCrossFadingLabel ()

@property (nonatomic, readwrite) NSArray *strings;

@end

@implementation VCrossFadingLabel

- (void)setupWithStrings:(NSArray *)strings andTextAttributes:(NSDictionary *)textAttributes
{
    self.strings = strings;
    self.textAttributes = textAttributes;
    self.offset = 0.0f;
}

- (void)setOffset:(CGFloat)offset
{
    NSInteger targetIndex = floorf(offset + 0.5f);
    if ( targetIndex <= 0 )
    {
        targetIndex = 0;
    }
    else if ( targetIndex >= (NSInteger)self.strings.count )
    {
        targetIndex = self.strings.count;
    }
    
    NSString *desiredText = self.strings[targetIndex];
    
    if ( desiredText != nil && ![self.text isEqualToString:desiredText] )
    {
        //Text has changed!
        [self updateToString:desiredText withAttributes:self.textAttributes];
    }
    
    CGFloat maxOffset = (CGFloat)( self.strings.count - 1 );
    if ( offset < 0.0f )
    {
        offset = 0.0f;
    }
    else if ( offset >= maxOffset )
    {
        offset = maxOffset;
    }
    
    _offset = offset;
    
    CGFloat alpha = offset - floorf(offset);
    alpha -= 0.5f; //Move the whole signal down to get it in range [-0.5, 0.5]
    alpha = fabs(alpha); //Take the abs value to get it in range [0, 0.5] with peaks where remainder was, originally, 0 or 1
    alpha *= 2; //Multiply by 2 to get the proper scale [0, 1]
    self.alpha = alpha;
}

- (void)setTextAttributes:(NSDictionary *)textAttributes
{
    _textAttributes = textAttributes;
    if ( self.text != nil )
    {
        [self updateToString:self.text withAttributes:textAttributes];
    }
}

- (void)updateToString:(NSString *)string withAttributes:(NSDictionary *)attributes
{
    [self setAttributedText:[[NSAttributedString alloc] initWithString:string attributes:attributes]];
}

@end
