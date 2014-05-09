//
//  VCVideoPlayerToolbarView.m
//  victorious
//
//  Created by Josh Hinman on 5/9/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "UIImage+VSolidColor.h"
#import "VCVideoPlayerToolbarView.h"

@implementation VCVideoPlayerToolbarView

+ (instancetype)toolbarFromNibWithOwner:(VCVideoPlayerView *)filesOwner
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
    
    [self.slider setThumbImage:[[UIImage imageNamed:@"player-handle"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]
                      forState:UIControlStateNormal];
    [self.slider setMinimumTrackImage:[UIImage v_imageWithColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0]]
                             forState:UIControlStateNormal];
    [self.slider setMaximumTrackImage:[UIImage v_imageWithColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0]]
                             forState:UIControlStateNormal];
}

@end
