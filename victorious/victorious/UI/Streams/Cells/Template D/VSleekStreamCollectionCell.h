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
#import "VFocusable.h"
#import "VStreamCellTracking.h"
#import "VHighlightContainer.h"
#import "victorious-Swift.h"

@class VSequence, VStream, StreamCellContext, VSequencePreviewView;

/**
 * VSleekStreamCollectionCell is a stream cell component more commonly known as 
 *  template D or Hera. It represents a sequence.
 */
@interface VSleekStreamCollectionCell : VBaseCollectionViewCell <VHasManagedDependencies, VBackgroundContainer, VStreamCellComponentSpecialization, VFocusable, VStreamCellTracking, VHighlighting, VContentPreviewViewProvider>

/**
 *  Sizing method. All parameters are required.
 */
+ (CGSize)actualSizeWithCollectionViewBounds:(CGRect)bounds
                                    sequence:(VSequence *)sequence
                           dependencyManager:(VDependencyManager *)dependencyManager;

/**
 *  Removes the cached size value for the sequence represented by this cell.
 */
- (void)purgeSizeCacheValue;

/**
 *  Hides the player of this cell's preview view if currently displaying a video.
 */
- (void)makeVideoContentHidden:(BOOL)hidden;

/**
 *  The sequence for this VSleekStreamCollectionCell to represent.
 */
@property (nonatomic, strong) VSequence *sequence;

/**
 *  Set to YES to signal that this cell's size should be
 *  refreshed the next time it's displayed.
 */
@property (nonatomic, readonly) BOOL needsRefresh;

/**
 *  The stream that this VSleekStreamCollectionCell is in.
 */
@property (nonatomic, strong) VStream *stream;

/**
 *  A context object used for tracking purposes.
 */
@property (nonatomic, strong) StreamCellContext *context;

/**
 *  The preview view currently displaying content in this cell.
 */
@property (nonatomic, readonly) VSequencePreviewView *previewView;

@end
