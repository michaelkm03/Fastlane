//
//  VHashTagContainerViewController.h
//  victorious
//
//  Created by Lawrence Leach on 7/22/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VAnimation.h"
#import "VTableContainerViewController.h"
#import "VStreamContainerViewController.h"

@class VSequence, VHashTagStreamViewController;

@interface VHashTagContainerViewController : VStreamContainerViewController
@property (nonatomic, strong) VSequence *sequence;
@property (nonatomic, strong) NSString *hashTag;
@property (nonatomic, strong) IBOutlet VHashTagStreamViewController *streamViewController;
@end
