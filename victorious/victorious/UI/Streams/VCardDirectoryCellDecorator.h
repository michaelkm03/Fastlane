//
//  VCardDirectoryCellDecorator.h
//  victorious
//
//  Created by Patrick Lynch on 3/4/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

@class VDependencyManager, VCardDirectoryCell, VStreamItem, VCardSeeMoreDirectoryCell;

@interface VCardDirectoryCellDecorator : NSObject

- (void)applyStyleToCell:(VCardDirectoryCell *)cell withDependencyManager:(VDependencyManager *)dependencyManager;

- (void)populateCell:(VCardDirectoryCell *)cell withStreamItem:(VStreamItem *)streamItem;

- (void)applyStyleToSeeMoreCell:(VCardSeeMoreDirectoryCell *)cell withDependencyManager:(VDependencyManager *)dependencyManager;

- (void)highlightTagsInCell:(VCardDirectoryCell *)cell withTagColor:(UIColor *)tagColor;

@end
