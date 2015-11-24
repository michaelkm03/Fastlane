//
//  VReposterTableViewController.h
//  victorious
//
//  Created by Will Long on 7/29/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VSequence, VDependencyManager;

@interface VReposterTableViewController : UITableViewController

- (id)initWithDependencyManager:(VDependencyManager *)dependencyManager;

- (void)setHasReposters:(BOOL)hasReposters;

@property (nonatomic, strong) VSequence *sequence;

@end
