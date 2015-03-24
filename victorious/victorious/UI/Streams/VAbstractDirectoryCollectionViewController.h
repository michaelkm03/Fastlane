//
//  VAbstractDirectoryCollectionViewController.h
//  victorious
//
//  Created by Sharif Ahmed on 3/24/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VAbstractStreamCollectionViewController.h"

@class VDependencyManager;

@interface VAbstractDirectoryCollectionViewController : VAbstractStreamCollectionViewController

- (NSString *)cellIdentifier;
- (UINib *)cellNib;

+ (instancetype)streamDirectoryForStream:(VStream *)stream dependencyManager:(VDependencyManager *)dependencyManager;

@property (nonatomic, strong) VDependencyManager *dependencyManager;

@end
