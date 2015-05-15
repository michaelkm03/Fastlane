//
//  VFullscreenMarqueeCollectionCell.h
//  victorious
//
//  Created by Will Long on 10/7/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "VAbstractMarqueeCollectionViewCell.h"

@interface VFullscreenMarqueeCollectionCell : VAbstractMarqueeCollectionViewCell

/**
 Toggles display of poster's profile image in the center of the marquee content. This
    is automatically updated when it is set on the marquee controller managing this cell
 */
@property (nonatomic, assign) BOOL hideMarqueePosterImage;

@end
