//
//  VContentVideoCell.h
//  victorious
//
//  Created by Michael Sena on 9/15/14.
//  Copyright (c) 2014 Victorious. All rights reserved.
//

#import "VBaseCollectionViewCell.h"

@class VContentVideoCell;

@import AVFoundation;

@protocol VContentVideoCellDelgetate <NSObject>

- (void)videoCell:(VContentVideoCell *)videoCell
    didPlayToTime:(CMTime)time
        totalTime:(CMTime)time;

@end

@interface VContentVideoCell : VBaseCollectionViewCell

@property (nonatomic, copy) NSURL *videoURL;

@property (nonatomic, weak) id <VContentVideoCellDelgetate> delegate;

@end
