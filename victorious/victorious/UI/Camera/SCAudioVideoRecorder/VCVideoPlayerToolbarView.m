//
//  VCVideoPlayerToolbarView.m
//  victorious
//
//  Created by Josh Hinman on 5/9/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VCVideoPlayerToolbarView.h"

@implementation VCVideoPlayerToolbarView

+ (instancetype)toolbarFromNibWithOwner:(VCVideoPlayerViewController *)filesOwner
{
    UINib *nib = [UINib nibWithNibName:NSStringFromClass(self) bundle:[NSBundle bundleForClass:self]];
    NSArray *objects = [nib instantiateWithOwner:filesOwner options:nil];
    for (id object in objects)
    {
        if ([object isKindOfClass:self])
        {
            return object;
        }
    }
    return nil;
}

- (void)awakeFromNib
{
    UIImage *pauseButton = [self.playButton imageForState:(UIControlStateSelected)];
    [self.playButton   setImage:pauseButton      forState:(UIControlStateSelected | UIControlStateHighlighted)];
}

@end
