//
//  VAnnouncementViewController.m
//  victorious
//
//  Created by Patrick Lynch on 11/5/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VAnnouncementViewController.h"
#import "VSequence.h"
#import "VSequence+Fetcher.h"

@interface VAnnouncementViewController()

@property (nonatomic, strong) VSequence *sequence;

@end

@implementation VAnnouncementViewController

- (instancetype)initWithSequence:(VSequence *)sequence
{
    self = [super init];
    if (self)
    {
        self.sequence = sequence;
        self.urlToView = [NSURL URLWithString:self.sequence.announcementUrl];
    }
    return self;
}

@end
