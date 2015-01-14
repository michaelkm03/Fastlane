//
//  VThumbnailCell.h
//  victorious
//
//  Created by Michael Sena on 12/31/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VBaseCollectionViewCell.h"

@interface VThumbnailCell : VBaseCollectionViewCell

@property (nonatomic, strong) NSValue *valueForThumbnail;
@property (nonatomic, strong) UIImage *thumbnail;

@end
