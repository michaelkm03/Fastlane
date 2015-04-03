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

/**
 *  The identifier for directory cells that will be registered with the collectionView during viewDidLoad. This MUST be overridden by subclasses.
 *
 *  @return an NSString that corresponds with the provided cellNib to register a cell during viewDidLoad
 */
- (NSString *)cellIdentifier;

/**
 *  The nib for directory cells that will be registered with the collectionView during viewDidLoad. This MUST be overridden by subclasses.
 *
 *  @return a UINib that corresponds with the provided cellIdentifier to register a cell during viewDidLoad
 */
- (UINib *)cellNib;

/**
 *  Creates a new directory with the given stream and dependencyManager
 *
 *  @return a new instance of a directoryViewController that subclasses this class, setup with the given stream and dependencyManager
 */
+ (instancetype)streamDirectoryForStream:(VStream *)stream dependencyManager:(VDependencyManager *)dependencyManager;

/**
 *  The dependencyManager used to style the directory and its cells
 */
@property (nonatomic, strong) VDependencyManager *dependencyManager;

@end
