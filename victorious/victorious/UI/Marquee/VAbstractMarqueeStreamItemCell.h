//
//  VAbstractMarqueeStreamItemCell.h
//  victorious
//
//  Created by Sharif Ahmed on 3/25/15.
//  Copyright (c) 2015 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VBaseCollectionViewCell.h"

@class VStreamItem, VUser, VAbstractMarqueeStreamItemCell, VDependencyManager;

/**
    A collection view cell that displays stream item content in a marquee
 */
@interface VAbstractMarqueeStreamItemCell : VBaseCollectionViewCell

- (void)updatePreviewViewForStreamItem:(VStreamItem *)streamItem;

@property (nonatomic, strong) VStreamItem *streamItem; ///< Stream item to display
@property (nonatomic, strong) IBOutlet UIView *previewContainer; ///< The view that will be filled with a VSequencePreviewView to display 
@property (nonatomic, strong) VDependencyManager *dependencyManager; ///< The dependencyManager that is used to style the cell and the content it displays

@end
