//
//  VThumbnailCell.h
//  victorious
//
//  Created by Michael Sena on 12/31/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VBaseCollectionViewCell.h"

@interface VThumbnailCell : VBaseCollectionViewCell

/**
 *  A CMTime wrapped in an NSValue for this cell.
 */
@property (nonatomic, strong) NSValue *valueForThumbnail;

/**
 *  The thumbnail for this cell.
 */
@property (nonatomic, strong) UIImage *thumbnail;

@end
