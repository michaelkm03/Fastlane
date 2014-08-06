//
//  UITextView+Size.m
//  victorious
//
//  Created by Will Long on 8/5/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "UITextView+Size.h"

@implementation UITextView (Size)

#define kMaxFieldHeight 100
-(BOOL)sizeFontToFitMinSize:(float)aMinFontSize maxSize:(float)aMaxFontSize
{
    
    float fudgeFactor = 16.0;
    float fontSize = aMaxFontSize;
    
    self.font = [self.font fontWithSize:fontSize];
    
    CGSize tallerSize = CGSizeMake(self.frame.size.width-fudgeFactor,kMaxFieldHeight);
    CGSize stringSize = [self.attributedText boundingRectWithSize:tallerSize options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading context:nil].size;
                         
//                         sizeWithFont:self.font constrainedToSize:tallerSize lineBreakMode:NSLineBreakByWordWrapping];
    
    while (stringSize.height >= self.frame.size.height) {
        
        if (fontSize <= aMinFontSize) // it just won't fit, ever
            return NO;
        
        fontSize -= 1.0;
        self.font = [self.font fontWithSize:fontSize];
        tallerSize = CGSizeMake(self.frame.size.width-fudgeFactor,kMaxFieldHeight);
        stringSize = [self.attributedText boundingRectWithSize:tallerSize options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading context:nil].size;
    }
    
    return YES; 
}

@end
