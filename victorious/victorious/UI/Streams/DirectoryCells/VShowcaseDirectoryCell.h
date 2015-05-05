//
//  VShowcaseDirectoryCell.h
//  victorious
//
//  Created by Sharif Ahmed on 2/20/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VBaseCollectionViewCell.h"
#import "VDirectoryCellFactory.h"

@class VStreamItem, VStream, VSequence, VDependencyManager, VShowcaseDirectoryCell;

@protocol VShowcaseDirectorySelection <NSObject>

- (void)showcaseDirectoryCell:(VShowcaseDirectoryCell *)showcaseDirectoryCell didSelectStreamItem:(VStreamItem *)streamItem;

@end

@interface VShowcaseDirectoryCell : VBaseCollectionViewCell

@property (nonatomic, strong) VDependencyManager *dependencyManager;

/**
 *  The VStream used to populate fields on the cell.
 */
@property (nonatomic, strong) VStream *stream;

@end
