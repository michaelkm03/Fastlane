//
//  VMenuCollectionViewCell.h
//  victorious
//
//  Created by Josh Hinman on 11/13/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VBaseCollectionViewCell.h"
#import "VNavigationMenuItemCell.h"

#import <UIKit/UIKit.h>

@class VDependencyManager;

/**
 A cell in the main menu collection view
 */
@interface VMenuCollectionViewCell : VBaseCollectionViewCell <VNavigationMenuItemCell>

/**
 An instance of VDependencyManager for supplying theme colors and fonts
 */
@property (nonatomic, strong) VDependencyManager *dependencyManager;

@end
