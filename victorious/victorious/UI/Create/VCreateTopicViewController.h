//
//  VCreateTopicViewController.h
//  victorious
//
//  Created by David Keegan on 1/9/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VCreateSequenceDelegate.h"

#import "VCreateViewController.h"

@interface VCreateTopicViewController : VCreateViewController

- (instancetype)initWithDelegate:(id<VCreateSequenceDelegate>)delegate;

@end
