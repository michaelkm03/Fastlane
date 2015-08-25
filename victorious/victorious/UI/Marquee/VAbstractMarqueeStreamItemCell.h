//
//  VAbstractMarqueeStreamItemCell.h
//  victorious
//
//  Created by Sharif Ahmed on 3/25/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VBaseCollectionViewCell.h"
#import "VStreamCellSpecialization.h"
#import "VHighlightContainer.h"
#import "VStreamCellTracking.h"

@class VStreamItem, VUser, VAbstractMarqueeStreamItemCell, VDependencyManager, VStreamItemPreviewView, StreamCellContext;

/**
    A collection view cell that displays stream item content in a marquee
 */
@interface VAbstractMarqueeStreamItemCell : VBaseCollectionViewCell <VStreamCellComponentSpecialization, VHighlighting, VStreamCellTracking>

/**
    Internally just sets the streamItem to the provided object. Subclasses can
        override to support the display of editorialized content, but must call super.
 
    @param streamItem The stream item who's content will be displayed in the stream item cell.
    @param apiPath The api path of the stream containing this stream item.
 */
- (void)setupWithStreamItem:(VStreamItem *)streamItem fromStreamWithApiPath:(NSString *)apiPath;

@property (nonatomic, readonly) VStreamItem *streamItem; ///< Stream item to display
@property (nonatomic, strong) IBOutlet UIView *previewContainer; ///< The view that will be filled with a VSequencePreviewView to display 
@property (nonatomic, strong) VDependencyManager *dependencyManager; ///< The dependencyManager that is used to style the cell and the content it displays
@property (nonatomic, strong) VStreamItemPreviewView *previewView;
@property (nonatomic, strong) UIView *dimmingContainer;

/*
 * A context object used for tracking purposes.
 */
@property (nonatomic, strong) StreamCellContext *context;

@end
