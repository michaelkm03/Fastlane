//
//  VStreamCollectionViewDataSource.h
//  victorious
//
//  Created by Will Long on 9/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "VAbstractFilter+RestKit.h"

NS_ASSUME_NONNULL_BEGIN

@protocol PaginatedDataSourceDelegate;
@class VStream, VStreamItem, VStreamCollectionViewDataSource, StreamOperation, PaginatedDataSource;

/**
 *  Data delegate for the VStreamCollectionViewDataSource.
 */
@protocol VStreamCollectionDataDelegate <PaginatedDataSourceDelegate>

@required

/**
 *  Fetches a UICollectionViewCell for a VStreamItem
 *
 *  @param dataSource the dataSource requesting a cell
 *  @param streamItem The VStreamItem object that needs to be displayed
 *
 *  @return an appropriate UICollectionViewCell for the given streamItem
 */
- (UICollectionViewCell *)dataSource:(VStreamCollectionViewDataSource *)dataSource cellForIndexPath:(NSIndexPath *)indexPath;

@optional

/**
 *  Allows a delegate to control the number of sections for the provided dataSource.
 *
 *  @param dataSource The dataSource whose content will be displayed.
 *
 *  @return The number of sections that should be displayed for the dataSource.
 */
- (NSInteger)numberOfSectionsForDataSource:(VStreamCollectionViewDataSource *)dataSource;

/**
 *  Allows a delegate to control the number of rows in a section for the provided dataSource.
 *
 *  @param dataSource The dataSource whose content will be displayed.
 *  @param section The section that will contain the number of rows returned from this method.
 *
 *  @return The number of rows that should be displayed for the dataSource in the provided section.
 */
- (NSInteger)dataSource:(VStreamCollectionViewDataSource *)dataSource numberOfRowsInSection:(NSUInteger)section;

/**
 *  Notifies the data delgate that the datasource has received new stream
 *  items and it should prepare to display cells for each of the stream items.
 */
- (void)dataSource:(VStreamCollectionViewDataSource *)dataSource
 hasNewStreamItems:(NSArray *)streamItems;

/**
 *  Allows a view controller implementation to specify if conditions of the calling code
 *  context required that an activity indivator footer view be generated by the data source
 *  and shown in the collection view.
 *
 *  @return YES to create and supply the footer the collection view, or NO if footer is not required.
 */
- (BOOL)shouldDisplayActivityViewFooterForCollectionView:(UICollectionView *)collectionView inSection:(NSInteger)section;

@end

@interface VStreamCollectionViewDataSource : NSObject <UICollectionViewDataSource>

@property (nonatomic, weak) id<VStreamCollectionDataDelegate> delegate;
@property (nonatomic, strong) VStream *stream;///< The stream object used to populate the collectionView
@property (nonatomic) BOOL hasHeaderCell;///< If set to YES it will insert a section at index 0 with 1 row for the Marquee stream.
@property (nonatomic) BOOL suppressShelves; ///< When YES, shelves from the stream will not be displayed.
@property (nonatomic, nonnull, strong) PaginatedDataSource *paginatedDataSource;
@property (nonatomic, strong) NSOrderedSet *visibleItems;
@property (nonatomic, readonly) BOOL isLoading;
@property (nonatomic, readonly) BOOL hasLoadedLastPage;

/**
 *  Initializes the data source with a default stream.
 *
 *  @param stream The stream used to populate the data source
 *
 *  @return A VStreamCollectionViewDataSource
 */
- (instancetype)initWithStream:(VStream *)stream;

/**
 *  Returns the VStreamItem location at the index path in the stream
 *
 *  @param indexPath The location of the index path
 *
 *  @return a VStreamItem in self.stream
 */
- (VStreamItem *)itemAtIndexPath:(NSIndexPath *)indexPath;

/**
 *  Returns the index path of a streamItem
 *
 *  @param streamItem A VstreamItem
 *
 *  @return The IndexPath of the streamItem in self.stream
 */
- (NSIndexPath *)indexPathForItem:(VStreamItem *)streamItem;

- (NSUInteger)count; ///< Number of VStreamItems in self.stream

- (NSInteger)sectionIndexForContent; ///< Returns either 0 or 1 depending on whether a header cell is present

@end

NS_ASSUME_NONNULL_END
