//
//  VMessageTextAndMediaView.m
//  victorious
//
//  Created by Cody Kolodziejzyk on 7/29/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VMessageTextAndMediaView.h"
#import "VTagSensitiveTextView.h"

@implementation VMessageTextAndMediaView

- (void)setMessage:(VMessage *)message
{
    if (_message == message)
    {
        return;
    }
    
    _message = message;
    
    // Set up proper media URL to use in lightbox
    self.mediaURLForLightbox = [NSURL URLWithString:message.mediaPath];
    
    [self.mediaAttachmentView removeFromSuperview];
    self.mediaAttachmentView = [MediaAttachmentView mediaViewWithMessage:message];
}

+ (CGFloat)estimatedHeightWithWidth:(CGFloat)width message:(VMessage *)message
{
    return [self estimatedHeightWithWidth:width message:message andFont:nil];
}

+ (CGFloat)estimatedHeightWithWidth:(CGFloat)width message:(VMessage *)message andFont:(UIFont *)font
{
    NSString *text = message.text;
    
    if (!text)
    {
        return 0;
    }
    
    __block CGRect boundingRect = CGRectZero;
    CGFloat mediaSpacing = 0.0f;
    if ( ![text isEqualToString:@""] )
    {
        NSDictionary *attributes = font != nil ? [self attributesForTextWithFont:font] : [self attributesForText];
        [VTagSensitiveTextView displayFormattedStringFromDatabaseFormattedText:text tagAttributes:attributes andDefaultAttributes:attributes toCallbackBlock:^(VTagDictionary *foundTags, NSAttributedString *displayFormattedString)
         {
             boundingRect = [displayFormattedString boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                                                 options:NSStringDrawingUsesLineFragmentOrigin
                                                                 context:[[NSStringDrawingContext alloc] init]];
         }];
        mediaSpacing = kSpacingBetweenTextAndMedia;
    }
    CGFloat mediaSize = (message.mediaPath != nil && message.mediaPath.length > 0) ? width + mediaSpacing : 0.0f;
    return VCEIL(CGRectGetHeight(boundingRect)) + mediaSize;
}

@end
