//
//  VDirectoryCellDecorator.h
//  victorious
//
//  Created by Patrick Lynch on 3/4/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VDependencyManager, VDirectoryItemCell, VStreamItem, VDirectorySeeMoreItemCell;

@interface VDirectoryCellDecorator : NSObject

- (void)applyStyleToCell:(VDirectoryItemCell *)cell withDependencyManager:(VDependencyManager *)dependencyManager;

- (void)populateCell:(VDirectoryItemCell *)cell withStreamItem:(VStreamItem *)streamItem;

- (void)applyStyleToSeeMoreCell:(VDirectorySeeMoreItemCell *)cell withDependencyManager:(VDependencyManager *)dependencyManager;

@end
