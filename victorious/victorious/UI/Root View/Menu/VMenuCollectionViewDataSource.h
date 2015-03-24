//
//  VMenuCollectionViewDataSource.h
//  victorious
//
//  Created by Josh Hinman on 11/13/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VHasManagedDependencies.h"

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class VDependencyManager, VNavigationMenuItem;

/**
 A collection view data source for menus
 */
@interface VMenuCollectionViewDataSource : NSObject <UICollectionViewDataSource, VHasManagedDependencies>

@property (nonatomic, strong) VDependencyManager *dependencyManager; ///< An instance of VDependencyManager for supplying theme colors and fonts
@property (nonatomic, copy, readonly) NSArray *menuSections; ///< Array of Arrays of VNavigationMenuItems
@property (nonatomic, copy, readonly) NSString *cellReuseID; ///< This reuse ID will be used to dequeue cells from the collection view
@property (nonatomic, copy) NSString *sectionHeaderReuseID; ///< If set, this reuse ID will be used to dequeue a supplementary view for section headers
@property (nonatomic, copy) NSString *sectionFooterReuseID; ///< If set, this reuse ID will be used to dequeue a supplementary view for section footers
@property (nonatomic) NSInteger badgeTotal; ///< The total of all the badge numbers in this data source. KVO compliant.

/**
 Initializes a new instance of the data source
 
 @param cellReuseID A reuse ID to use when dequeuing cells from 
                    the collection view. Cells should conform
                    to the VNavigationMenuItemCell protocol.
 @param menuSections An array of arrays of VNavigationMenuItem objects
 */
- (instancetype)initWithCellReuseID:(NSString *)cellReuseID sectionsOfMenuItems:(NSArray /* NSArrays of VNavigationMenuItem */ *)menuSections NS_DESIGNATED_INITIALIZER;

/**
 Returns the menu item at the given index path
 */
- (VNavigationMenuItem *)menuItemAtIndexPath:(NSIndexPath *)indexPath;

@end
