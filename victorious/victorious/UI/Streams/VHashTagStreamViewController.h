//
//  VHashTagStreamViewController.h
//  victorious
//
//  Created by Lawrence Leach on 7/21/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VStreamContainerViewController.h"

@class VSequence;

@interface VHashTagStreamViewController : VStreamTableViewController

@property (nonatomic, strong) VSequence *sequence;
@property (nonatomic, strong) NSString *hashTag;

- (id)initWithHashTag:(NSString *)hashTag;

@end
