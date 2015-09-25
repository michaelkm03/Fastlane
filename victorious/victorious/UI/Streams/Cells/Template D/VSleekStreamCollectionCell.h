//
//  VSleekStreamCollectionCell.h
//  victorious
//
//  Created by Sharif Ahmed on 3/13/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import "VBaseCollectionViewCell.h"
#import "VHasManagedDependencies.h"
#import "VBackgroundContainer.h"
#import "VStreamCellSpecialization.h"
#import "VCellFocus.h"
#import "VStreamCellTracking.h"
#import "VHighlightContainer.h"

@class VSequence, VStream, StreamCellContext;

/**
 * VSleekStreamCollectionCell is a stream cell component more commonly known as 
 *  template D or Hera. It represents a sequence.
 */
@interface VSleekStreamCollectionCell : VBaseCollectionViewCell <VHasManagedDependencies, VBackgroundContainer, VStreamCellComponentSpecialization, VCellFocus, VStreamCellTracking, VHighlighting>

/**
 *  Sizing method. All parameters are required.
 */
+ (CGSize)actualSizeWithCollectionViewBounds:(CGRect)bounds
                                    sequence:(VSequence *)sequence
                           dependencyManager:(VDependencyManager *)dependencyManager;

- (void)purgeSizeCacheValue;

/**
 *  The sequence for this VSleekStreamCollectionCell to represent.
 */
@property (nonatomic, strong) VSequence *sequence;

/**
 *  Set to YES to signal that this cell's size should be
 *  refreshed the next time it's displayed.
 */
@property (nonatomic, readonly) BOOL needsRefresh;

/*
 *  The stream that this VSleekStreamCollectionCell is in.
 */
@property (nonatomic, strong) VStream *stream;

/*
 * A context object used for tracking purposes.
 */
@property (nonatomic, strong) StreamCellContext *context;

@end
