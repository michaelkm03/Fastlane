//
//  VHashTagContainerViewController.h
//  victorious
//
//  Created by Lawrence Leach on 7/22/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VAnimation.h"
#import "VTableContainerViewController.h"

@class VSequence;

@interface VHashTagContainerViewController : VTableContainerViewController
@property (nonatomic, strong) VSequence *sequence;
@property (nonatomic, strong) NSString *hashTag;
+ (instancetype)hashTagContainerView;

@end
