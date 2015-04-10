//
//  VMultiplePickerSelection.h
//  victorious
//
//  Created by Patrick Lynch on 3/30/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 A helper class that manages the state of multiple selections, designed to
 work well with UICollectionView, UITableView or any other type of collection
 of views that uses index paths.
 */
@interface VMultiplePickerSelection : NSObject

/**
 Clear any currently held state about which index paths are selected.
 */
- (void)resetSelectedIndexPaths;

/**
 Internally records and tracks the selection of the specified index path.
 */
- (void)indexPathWasSelected:(NSIndexPath *)indexPath;

/**
 Internally records and tracks the deselection of the specified index path.
 */
- (void)indexPathWasDeselected:(NSIndexPath *)indexPath;

/**
 Returns YES if the specified indexPath was ever marked as selected using
 `indexPathWasSelected:` and has yet to be deselected using `indexPathWasDeselected:`
 or `resetSeletedIndexPaths`.
 */
- (BOOL)isIndexPathSelected:(NSIndexPath *)indexPath;

@end
