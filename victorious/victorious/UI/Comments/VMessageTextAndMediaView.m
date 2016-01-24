//
//  VMessageTextAndMediaView.m
//  victorious
//
//  Created by Cody Kolodziejzyk on 7/29/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VMessageTextAndMediaView.h"
#import "VTagSensitiveTextView.h"
#import "VMessage+Fetcher.h"
#import "victorious-Swift.h"

static UIEdgeInsets const kTextInsets = { 2.0f, 0.0f, 2.0f, 0.0f };

@implementation VMessageTextAndMediaView

- (void)setMessage:(VMessage *)message
{
    if (_message == message)
    {
        return;
    }
    
    _message = message;
    
    // Set up proper media URL to use in lightbox
    self.mediaURLForLightbox = [NSURL URLWithString:message.mediaUrl];
    
    // For calculating intrinsic content size
    self.hasMedia = [message hasMediaAttachment];
    
    [self.mediaAttachmentView removeFromSuperview];
    self.mediaAttachmentView = [MediaAttachmentView mediaViewWithMessage:message];
    self.mediaAttachmentView.clipsToBounds = YES;
    
    self.textView.textContainerInset = UIEdgeInsetsMake(1.0f, 0.0f, 0.0f, 0.0f);
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
    
    CGFloat totalTextHeight = 0.0f;
    CGFloat totalMediaHeight = 0.0f;
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
        totalTextHeight = VCEIL(CGRectGetHeight(boundingRect)) + kTextInsets.top + kTextInsets.bottom;
    }

    if ([message hasMediaAttachment])
    {
        CGFloat aspectRatio = [message mediaAspectRatio];
        totalMediaHeight = (width * aspectRatio) + mediaSpacing;
    }
    
    return  totalTextHeight + totalMediaHeight;
}

@end
