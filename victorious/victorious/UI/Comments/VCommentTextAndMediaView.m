//
//  VCommentTextAndMediaView.m
//  victorious
//
//  Created by Cody Kolodziejzyk on 7/29/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VCommentTextAndMediaView.h"
#import "VTagSensitiveTextView.h"
#import "VComment+Fetcher.h"

@implementation VCommentTextAndMediaView

- (void)setComment:(VComment *)comment
{
    if (_comment == comment)
    {
        return;
    }
    
    _comment = comment;
    
    // Set up proper media URL to use in lightbox
    self.mediaURLForLightbox = [comment properMediaURLGivenContentType];
    
    [self.mediaAttachmentView removeFromSuperview];
    self.mediaAttachmentView = [MediaAttachmentView mediaViewWithComment:comment];
}

+ (CGFloat)estimatedHeightWithWidth:(CGFloat)width comment:(VComment *)comment
{
    return [self estimatedHeightWithWidth:width comment:comment andFont:nil];
}

+ (CGFloat)estimatedHeightWithWidth:(CGFloat)width comment:(VComment *)comment andFont:(UIFont *)font
{
    NSString *text = comment.text;
    
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
    CGFloat mediaSize = comment.hasMediaAttachment ? width + mediaSpacing : 0.0f;
    return VCEIL(CGRectGetHeight(boundingRect)) + mediaSize;
}

@end
