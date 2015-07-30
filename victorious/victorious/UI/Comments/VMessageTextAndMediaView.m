//
//  VMessageTextAndMediaView.m
//  victorious
//
//  Created by Cody Kolodziejzyk on 7/29/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VMessageTextAndMediaView.h"

@interface VMessageTextAndMediaView ()

@property (nonatomic, strong) MediaAttachmentView *mediaAttachmentView;

@end

@implementation VMessageTextAndMediaView

@synthesize mediaAttachmentView = _mediaAttachmentView;

- (void)setMessage:(VMessage *)message
{
    if (_message == message)
    {
        return;
    }
    
    _message = message;
    // TODO: uncomment
    //    self.hasMedia = message.hasMedia
    [self.mediaAttachmentView removeFromSuperview];
    self.mediaAttachmentView = [MediaAttachmentView mediaViewWithMessage:message];
    if (self.mediaAttachmentView != nil)
    {
        self.mediaAttachmentView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:self.mediaAttachmentView];
        [self setNeedsUpdateConstraints];
    }
}

@end
