//
//  VAnnouncementViewController.h
//  victorious
//
//  Created by Patrick Lynch on 11/5/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VWebContentViewController.h"

@class VSequence;

@interface VAnnouncementViewController : VWebContentViewController

- (instancetype)initWithSequence:(VSequence *)sequence;

@end
