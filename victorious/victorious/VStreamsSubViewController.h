//
//  VStreamsSubViewController.h
//  victorious
//
//  Created by David Keegan on 1/11/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VConversationSubViewController.h"

@class VSequence;

@interface VStreamsSubViewController : VConversationSubViewController
@property (nonatomic, strong) VSequence* sequence;
@end
