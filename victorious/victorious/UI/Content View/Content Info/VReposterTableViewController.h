//
//  VReposterTableViewController.h
//  victorious
//
//  Created by Will Long on 7/29/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class VSequence, VDependencyManager, SequenceRepostersOperation;

@interface VReposterTableViewController : UITableViewController

- (instancetype)initWithSequence:(VSequence *)sequence dependencyManager:(VDependencyManager *)dependencyManager;

@property (nonatomic, strong) VSequence *sequence;

@property (nonatomic, strong, nullable) SequenceRepostersOperation *repostersOperation;

@end

NS_ASSUME_NONNULL_END
