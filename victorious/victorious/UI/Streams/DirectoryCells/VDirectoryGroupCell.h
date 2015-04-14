//
//  VDirectoryGroupCell.h
//  victorious
//
//  Created by Sharif Ahmed on 2/20/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VBaseCollectionViewCell.h"
#import "VDependencyManager.h"
#import "VDirectoryCellFactory.h"

@class VStreamItem, VDirectoryGroupCell, VStream, VSequence;

@protocol VDirectoryGroupCellDelegate <NSObject>

- (void)streamDirectoryGroupCell:(VDirectoryGroupCell *)groupCell didSelectItemAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface VDirectoryGroupCell : VBaseCollectionViewCell

@property (nonatomic, strong) VDependencyManager *dependencyManager;

/**
    The item cell delegate that will respond to selections made within the collectionView contained in this cell
 */
@property (nonatomic, weak) id <VDirectoryGroupCellDelegate> delegate;

/**
 *  The VStream used to populate fields on the cell.
 */
@property (nonatomic, strong) VStream *stream;

/**
 *  The directoryCellFactory that will dictate what and how cells are displayed within the collectionView in this cell
 */
@property (nonatomic, strong) NSObject <VDirectoryCellFactory> *directoryCellFactory;

@end
