//
//  VStreamCollectionViewDataSource.h
//  victorious
//
//  Created by Will Long on 9/8/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const VStreamCollectionDataSourceDidChangeNotification;

@class VAbstractFilter, VStream, VStreamItem, VStreamCollectionViewDataSource;

/**
 *  Data delegate for the VStreamCollectionViewDataSource.
 */
@protocol VStreamCollectionDataDelegate <NSObject>

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

@end

@interface VStreamCollectionViewDataSource : NSObject <UICollectionViewDataSource>

@property (nonatomic, weak) id<VStreamCollectionDataDelegate> delegate;
@property (nonatomic, weak) UICollectionView *collectionView; ///< The UICollectionView object to which the receiver is providing data
@property (nonatomic, strong) VAbstractFilter *filter;///< The filter object used to keep track of pagination
@property (nonatomic, strong) VStream *stream;///< The stream object used to populate the collectionView
@property (nonatomic) BOOL hasHeaderCell;///<If set to YES it will insert a section at index 0 with 1 row for the Marquee stream.

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
- (void)refreshWithSuccess:(void(^)(void))successBlock failure:(void(^)(NSError *error))failureBlock; ///<Refresh the stream items on self.stream
- (void)loadNextPageWithSuccess:(void(^)(void))successBlock failure:(void(^)(NSError *error))failureBlock;///<Grab next page of stream items
- (BOOL)isFilterLoading; ///< Returns YES if the filter is currently being loaded from the server

@end
