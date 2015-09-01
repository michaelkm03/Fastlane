//
//  CHTCollectionViewWaterfallLayout+ColumnAccessor.h
//  victorious
//
//  Created by Sharif Ahmed on 8/31/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

@import CHTCollectionViewWaterfallLayout;

@interface CHTCollectionViewWaterfallLayout (ColumnAccessor)

/**
 *  Returns an array of NSNumbers that represent the heights of the columns in the provided section.
 *  This function is part of Victorious's extended implementation.
 *
 *  @param section The section whose column heights should be returned
 *
 *  @return An array of NSNumbers that represent the heights of the columns in the provided section.
 */
- (NSArray *)heightsForColumnsInSection:(NSUInteger)section;

/**
 *  An array of arrays containing NSNumbers that represent the heights of each column in a section.
 *  This property is used to expose an otherwise private property from CHTCollectionViewWaterfallLayout.
 *  The getter for this is accessed dynamically and, as such, will break if the name of the private property changes.
 */
@property (nonatomic, readonly) NSMutableArray *columnHeights;

@end
