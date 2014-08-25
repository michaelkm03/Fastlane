//
//  VPublishShareController.m
//  victorious
//
//  Created by Josh Hinman on 8/22/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VPublishShareController.h"
#import "VPublishShareView.h"

@interface VPublishShareController ()

@property (nonatomic, strong, readwrite) VPublishShareView *shareView;

@end

@implementation VPublishShareController

- (id)init
{
    self = [super init];
    if (self)
    {
        self.shareView = [[VPublishShareView alloc] init];
        typeof(self) __weak weakSelf = self;
        self.shareView.selectionBlock = ^{ [weakSelf shareButtonTapped]; };
    }
    return self;
}

- (void)shareButtonTapped
{
}

- (BOOL)isSelected
{
    return self.shareView.selectedState == VShareViewSelectedStateSelected;
}

@end
