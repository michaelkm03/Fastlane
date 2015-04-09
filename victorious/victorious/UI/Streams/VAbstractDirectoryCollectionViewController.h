//
//  VAbstractDirectoryCollectionViewController.h
//  victorious
//
//  Created by Sharif Ahmed on 3/24/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VAbstractStreamCollectionViewController.h"

@class VDependencyManager, VAbstractMarqueeController;

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
 *  Called when a streamItem is selected from a directory cell or marquee. This MUST be overridden by subclasses
 *
 *  @param streamItem The streamItem selected from a marquee or directoryCell
 */
- (void)navigateToDisplayStreamItem:(VStreamItem *)streamItem;

/**
 *  Creates a new directory with the given stream and dependencyManager
 *
 *  @return a new instance of a directoryViewController that subclasses this class, setup with the given stream and dependencyManager
 */
+ (instancetype)streamDirectoryForStream:(VStream *)stream dependencyManager:(VDependencyManager *)dependencyManager;

/**
 *  A helpful accessor for determining whether or not the section in question has been added to display a marquee
 *
 *  @param section The section that could be displaying marquee content
 *
 *  @return YES if the section in question has been added to display a marquee, NO otherwise
 */
- (BOOL)isMarqueeSection:(NSUInteger)section;

/**
 *  Determines whether or not the hasHeaderCell property of the streamDataSource will be updated if marquee content is available.
 *      The default implementation returns YES
 *
 *  @return YES to allow this class to manipulate the hasHeaderCell property of the streamDataSource or NO to turn off this behavior
 */
- (BOOL)canShowMarquee;

/**
 *  The dependencyManager used to style the directory and its cells
 */
@property (nonatomic, strong) VDependencyManager *dependencyManager;

/**
 *  The marquee controller that will provide and manage marquee cells when a marquee is displayed
 */
@property (nonatomic, strong) VAbstractMarqueeController *marqueeController;

@end
