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

@property (nonatomic, strong) VStreamItem *streamItem; ///< Stream item to display
@property (nonatomic, weak) IBOutlet UIImageView *previewImageView; ///< The primary imageView containing a previewImage of the content this cell is representing
@property (nonatomic, weak) IBOutlet UIImageView *pollOrImageView; ///< The imageView containing the or icon that is displayed for polls in the marquee
@property (nonatomic, strong) VDependencyManager *dependencyManager; ///< The dependencyManager that is used to style the cell and the content it displays

@end
