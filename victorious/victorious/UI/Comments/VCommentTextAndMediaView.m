//
//  VCommentTextAndMediaView.m
//  victorious
//
//  Created by Cody Kolodziejzyk on 7/29/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VCommentTextAndMediaView.h"
#import "VTagSensitiveTextView.h"

@interface VCommentTextAndMediaView ()

@property (nonatomic, strong) MediaAttachmentView *mediaAttachmentView;

@end

@implementation VCommentTextAndMediaView

@synthesize mediaAttachmentView = _mediaAttachmentView;

- (void)setComment:(VComment *)comment
{
    if (_comment == comment)
    {
        return;
    }
    
    _comment = comment;
    self.hasMedia = [comment hasMediaAttachment];
    [self.mediaAttachmentView removeFromSuperview];
    self.mediaAttachmentView = [MediaAttachmentView mediaViewWithComment:comment];
    if (self.mediaAttachmentView != nil)
    {
        self.mediaAttachmentView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.mediaAttachmentView];
        [self setNeedsUpdateConstraints];
    }
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
